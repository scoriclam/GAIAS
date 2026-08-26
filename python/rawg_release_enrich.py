import json
from collections import Counter
from datetime import datetime, timezone
from difflib import SequenceMatcher
from pathlib import Path

import duckdb

from rawg_client import RAWGClient


DB_PATH = "gaias.duckdb"
LOG_DIR = Path("logs")
PS5_PLATFORM_NAME = "PlayStation 5"


def normalize_title(value):
    return " ".join(
        str(value or "")
        .casefold()
        .replace(":", " ")
        .replace("-", " ")
        .replace("'", "")
        .split()
    )


def title_similarity(left, right):
    return SequenceMatcher(
        None,
        normalize_title(left),
        normalize_title(right),
    ).ratio()


def get_ps5_release_date(game):
    for item in game.get("platforms") or []:
        platform = item.get("platform") or {}

        if platform.get("name") != PS5_PLATFORM_NAME:
            continue

        return item.get("released_at")

    return None


def choose_match(title, search_results):
    candidates = []

    for game in search_results:
        similarity = title_similarity(
            title,
            game.get("name"),
        )

        ps5_present = any(
            (item.get("platform") or {}).get("name")
            == PS5_PLATFORM_NAME
            for item in game.get("platforms") or []
        )

        if not ps5_present:
            continue

        candidates.append(
            (
                similarity,
                game,
            )
        )

    if not candidates:
        return {
            "status": "NO_PS5_MATCH",
            "match": None,
        }

    candidates.sort(
        key=lambda item: item[0],
        reverse=True,
    )

    best_similarity, best_game = candidates[0]

    if best_similarity < 0.80:
        return {
            "status": "LOW_CONFIDENCE",
            "match": None,
        }

    if (
        len(candidates) > 1
        and candidates[1][0] >= best_similarity - 0.03
    ):
        return {
            "status": "AMBIGUOUS",
            "match": None,
        }

    return {
        "status": "MATCHED",
        "match": best_game,
    }


def get_verification_queue():
    con = duckdb.connect(
        DB_PATH,
        read_only=True,
    )

    try:
        return con.execute(
            """
            SELECT
                GameEditionID,
                GameID,
                GameTitle,
                PlatformName
            FROM dq_release_external_verification_queue
            ORDER BY GameEditionID
            """
        ).fetchall()

    finally:
        con.close()


def write_staging_row(
    game_edition_id,
    game_id,
    search_title,
    search_platform,
    rawg_id,
    rawg_name,
    release_date,
    raw_payload,
    fetch_status,
):
    con = duckdb.connect(DB_PATH)

    try:
        con.execute(
            """
            INSERT INTO stg_rawg_release_raw (
                GameEditionID,
                GameID,
                SearchTitle,
                SearchPlatform,
                RAWGID,
                RAWGName,
                ReleaseDate,
                RawPayload,
                FetchStatus,
                FetchedAt
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                game_edition_id,
                game_id,
                search_title,
                search_platform,
                rawg_id,
                rawg_name,
                release_date,
                raw_payload,
                fetch_status,
                datetime.now(timezone.utc),
            ],
        )

    finally:
        con.close()


def main():
    LOG_DIR.mkdir(exist_ok=True)

    timestamp = datetime.now().strftime(
        "%Y%m%d_%H%M%S"
    )

    log_path = (
        LOG_DIR
        / f"rawg_release_enrich_{timestamp}.txt"
    )

    client = RAWGClient()
    rows = get_verification_queue()

    print(f"Queue rows: {len(rows)}")
    print(f"Full log: {log_path}")
    print()

    status_counts = Counter()

    with log_path.open(
        "w",
        encoding="utf-8",
    ) as log_file:

        for (
            game_edition_id,
            game_id,
            title,
            platform_name,
        ) in rows:

            print(
                f"Processing {game_id}: "
                f"{title} [{platform_name}]"
            )

            search_results = client.search_games(
                title,
                page_size=10,
            )

            decision = choose_match(
                title,
                search_results,
            )

            status = decision["status"]
            match = decision["match"]

            rawg_id = None
            rawg_name = None
            release_date = None
            raw_payload = json.dumps(
                search_results
            )

            if match:
                rawg_id = match.get("id")
                rawg_name = match.get("name")

                detail = client.get_game(
                    rawg_id
                )

                release_date = (
                    get_ps5_release_date(
                        detail
                    )
                )

                raw_payload = json.dumps(
                    detail
                )

                if release_date:
                    status = "MATCHED_WITH_DATE"
                else:
                    status = "MATCHED_NO_DATE"

            status_counts[status] += 1

            write_staging_row(
                game_edition_id=game_edition_id,
                game_id=game_id,
                search_title=title,
                search_platform=platform_name,
                rawg_id=rawg_id,
                rawg_name=rawg_name,
                release_date=release_date,
                raw_payload=raw_payload,
                fetch_status=status,
            )

            log_file.write(
                f"{game_edition_id} | "
                f"{game_id} | "
                f"{title} | "
                f"{platform_name} | "
                f"{status} | "
                f"{rawg_id} | "
                f"{rawg_name} | "
                f"{release_date}\n"
            )

    print()
    print("RAWG enrichment summary")
    print("=" * 50)

    for status in sorted(status_counts):
        print(
            f"{status}: "
            f"{status_counts[status]}"
        )

    print(f"Total processed: {len(rows)}")


if __name__ == "__main__":
    main()
