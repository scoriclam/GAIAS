import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

import duckdb


DB_PATH = "gaias.duckdb"
PSN_FETCH_SCRIPT = Path(
    "integrations/psn/fetch_library.mjs"
)


def fetch_psn_library():
    result = subprocess.run(
        [
            "node",
            str(PSN_FETCH_SCRIPT),
        ],
        capture_output=True,
        text=True,
        check=False,
    )

    if result.returncode != 0:
        raise RuntimeError(
            "PSN library fetch failed:\n"
            f"{result.stderr.strip()}"
        )

    return json.loads(
        result.stdout
    )


def main():
    games = fetch_psn_library()

    fetched_at = datetime.now(
        timezone.utc
    )

    rows = []

    for game in games:
        image = game.get("image") or {}

        rows.append(
            (
                game.get("entitlementId"),
                game.get("productId"),
                game.get("titleId"),
                game.get("conceptId"),
                game.get("name"),
                game.get("platform"),
                game.get("membership"),
                game.get("isActive"),
                game.get("isDownloadable"),
                game.get("isPreOrder"),
                image.get("url"),
                json.dumps(game),
                fetched_at,
            )
        )

    con = duckdb.connect(
        DB_PATH
    )

    try:
        con.executemany(
            """
            INSERT INTO stg_psn_library_raw (
                EntitlementID,
                ProductID,
                TitleID,
                ConceptID,
                GameName,
                Platform,
                Membership,
                IsActive,
                IsDownloadable,
                IsPreOrder,
                ImageURL,
                RawPayload,
                FetchedAt
            )
            VALUES (
                ?, ?, ?, ?, ?, ?, ?,
                ?, ?, ?, ?, ?, ?
            )
            """,
            rows,
        )

    finally:
        con.close()

    print(
        f"PSN rows staged: {len(rows)}"
    )
    print(
        f"Snapshot timestamp: "
        f"{fetched_at.isoformat()}"
    )


if __name__ == "__main__":
    main()