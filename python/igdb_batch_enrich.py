from collections import Counter
from datetime import datetime
from pathlib import Path

import duckdb

from igdb_matcher import IGDBMatcher
from igdb_stage_writer import write_match_to_staging


DB_PATH = "gaias.duckdb"
BATCH_SIZE = 200
LOG_DIR = Path("logs")


def main():
    LOG_DIR.mkdir(exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_path = LOG_DIR / f"igdb_batch_{timestamp}.txt"

    connection = duckdb.connect(DB_PATH)
    matcher = IGDBMatcher()

    rows = connection.execute(
        """
        SELECT
            g.GameID,
            g.GameTitle,
            p.PlatformName,
            a.AcquisitionSourceName
        FROM Game g
        JOIN UserGameRecord ugr
            ON ugr.GameID = g.GameID
        JOIN GameEntitlement ge
            ON ge.UserGameRecordID = ugr.UserGameRecordID
        JOIN AcquisitionSource a
            ON a.AcquisitionSourceID = ge.AcquisitionSourceID
        JOIN GameEdition ged
            ON ged.GameEditionID = ge.GameEditionID
        JOIN Platform p
            ON p.PlatformID = ged.PlatformID
        WHERE p.PlatformName IN (
            'PlayStation 4',
            'PlayStation 5',
            'Wii U'
        )
        AND NOT EXISTS (
            SELECT 1
            FROM stg_igdb_game_raw s
            WHERE s.GAIASGameID = g.GameID
              AND s.SearchPlatform =
                    CASE p.PlatformName
                        WHEN 'PlayStation 4' THEN 'PS4'
                        WHEN 'PlayStation 5' THEN 'PS5'
                        WHEN 'Wii U' THEN 'WIIU'
                    END
        )
        ORDER BY g.GameID
        LIMIT ?
        """,
        [BATCH_SIZE],
    ).fetchall()

    connection.close()

    print(f"Games selected: {len(rows)}")
    print(f"Full log: {log_path}")
    print()

    status_counts = Counter()
    unresolved = []

    with log_path.open(
        "w",
        encoding="utf-8",
    ) as log_file:

        log_file.write(
            f"Games selected: {len(rows)}\n\n"
        )

        for (
            game_id,
            title,
            platform_name,
            acquisition_source,
        ) in rows:

            platform_code = {
                "PlayStation 4": "PS4",
                "PlayStation 5": "PS5",
                "Wii U": "WIIU",
            }[platform_name]

            log_file.write(
                f"Processing GameID {game_id}: "
                f"{title} [{platform_code}] "
                f"Source={acquisition_source}\n"
            )

            result = matcher.match_game(
                title=title,
                platform_code=platform_code,
                gaias_game_id=game_id,
                acquisition_source=acquisition_source,
            )

            status = result["status"]
            status_counts[status] += 1

            log_file.write(
                f"Match status: {status}\n"
            )

            if result.get("match"):
                match = result["match"]

                log_file.write(
                    f"IGDB: {match['id']} - "
                    f"{match['name']}\n"
                )

            if status in {
                "AMBIGUOUS",
                "NO_EXACT_MATCH",
                "UNSUPPORTED_PLATFORM",
            }:
                unresolved.append(
                    {
                        "game_id": game_id,
                        "title": title,
                        "platform_code": platform_code,
                        "acquisition_source": acquisition_source,
                        "status": status,
                    }
                )

            write_match_to_staging(
                gaias_game_id=game_id,
                search_title=title,
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
                f"{status}: {status_counts[status]}\n"
            )

        log_file.write(
            f"Total processed: {len(rows)}\n"
        )

        log_file.write(
            f"Unresolved: {len(unresolved)}\n"
        )

        if unresolved:
            log_file.write("\nUNRESOLVED RECORDS\n")
            log_file.write("=" * 70 + "\n")

            for item in unresolved:
                log_file.write(
                    f"{item['game_id']} | "
                    f"{item['title']} | "
                    f"{item['platform_code']} | "
                    f"{item['acquisition_source']} | "
                    f"{item['status']}\n"
                )

    print("Batch summary")
    print("=" * 50)

    for status in sorted(status_counts):
        print(
            f"{status}: {status_counts[status]}"
        )

    print(f"Total processed: {len(rows)}")
    print(f"Unresolved: {len(unresolved)}")

    if unresolved:
        print()
        print("Unresolved records")
        print("=" * 50)

        for item in unresolved:
            print(
                f"{item['game_id']} | "
                f"{item['title']} | "
                f"{item['platform_code']} | "
                f"{item['acquisition_source']} | "
                f"{item['status']}"
            )


if __name__ == "__main__":
    main()