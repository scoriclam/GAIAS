from collections import Counter
from datetime import datetime
from pathlib import Path

import duckdb

from igdb_matcher import IGDBMatcher
from igdb_stage_writer import write_match_to_staging


DB_PATH = "gaias.duckdb"
LOG_DIR = Path("logs")


def get_missing_release_dates():
    con = duckdb.connect(DB_PATH, read_only=True)

    try:
        rows = con.execute(
            """
            SELECT DISTINCT
                g.GameID,
                g.GameTitle,
                p.PlatformName,
                acq.AcquisitionSourceName
            FROM GameEdition ge

            JOIN Game g
                ON g.GameID = ge.GameID

            JOIN Platform p
                ON p.PlatformID = ge.PlatformID

            JOIN GameEntitlement ent
                ON ent.GameEditionID = ge.GameEditionID

            JOIN AcquisitionSource acq
                ON acq.AcquisitionSourceID =
                   ent.AcquisitionSourceID

            WHERE ge.ReleaseDate IS NULL

              AND p.PlatformName IN (
                  'PS4',
                  'PS5',
                  'Wii U'
              )

            ORDER BY
                g.GameID,
                p.PlatformName
            """
        ).fetchall()

        return rows

    finally:
        con.close()


def main():
    LOG_DIR.mkdir(exist_ok=True)

    timestamp = datetime.now().strftime(
        "%Y%m%d_%H%M%S"
    )

    log_path = (
        LOG_DIR
        / f"igdb_release_refresh_{timestamp}.txt"
    )

    matcher = IGDBMatcher()

    games = get_missing_release_dates()

    print(
        f"Missing release-date editions selected: "
        f"{len(games)}"
    )
    print(f"Full log: {log_path}")
    print()

    status_counts = Counter()

    with log_path.open(
        "w",
        encoding="utf-8",
    ) as log_file:

        log_file.write(
            "IGDB PLATFORM-SPECIFIC RELEASE REFRESH\n"
        )
        log_file.write("=" * 70 + "\n")
        log_file.write(
            f"Editions selected: {len(games)}\n\n"
        )

        for (
            game_id,
            game_title,
            platform_name,
            acquisition_source,
        ) in games:

            platform_code = {
                "PS4": "PS4",
                "PS5": "PS5",
                "Wii U": "WIIU",
            }[platform_name]

            print(
                f"Refreshing GameID {game_id}: "
                f"{game_title} "
                f"[{platform_code}]"
            )

            result = matcher.match_game(
                title=game_title,
                platform_code=platform_code,
                gaias_game_id=game_id,
                acquisition_source=acquisition_source,
            )

            status = result["status"]
            status_counts[status] += 1

            log_file.write(
                f"GameID {game_id} | "
                f"{game_title} | "
                f"{platform_code} | "
                f"{acquisition_source}\n"
            )

            log_file.write(
                f"Match status: {status}\n"
            )

            if result.get("match"):
                match = result["match"]

                log_file.write(
                    f"IGDB: "
                    f"{match.get('id')} - "
                    f"{match.get('name')}\n"
                )

            write_match_to_staging(
                gaias_game_id=game_id,
                search_title=game_title,
                search_platform=platform_code,
                match_result=result,
            )

            log_file.write(
                "-" * 70 + "\n"
            )

        log_file.write("\nSUMMARY\n")
        log_file.write("=" * 70 + "\n")

        for status in sorted(status_counts):
            log_file.write(
                f"{status}: "
                f"{status_counts[status]}\n"
            )

        log_file.write(
            f"Total processed: {len(games)}\n"
        )

    print()
    print("Refresh summary")
    print("=" * 50)

    for status in sorted(status_counts):
        print(
            f"{status}: "
            f"{status_counts[status]}"
        )

    print(f"Total processed: {len(games)}")


if __name__ == "__main__":
    main()
