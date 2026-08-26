import argparse
import subprocess
import sys
from pathlib import Path

import duckdb


DB_PATH = Path("gaias.duckdb")
PYTHON_DIR = Path("python")

SQL_FILES = {
    "map_classification": (
        Path("sql/02_standardization")
        / "map_igdb_classification.sql"
    ),
    "classification_ready": (
        Path("sql/02_standardization")
        / "std_igdb_classification_ready.sql"
    ),
    "release_ready": (
        Path("sql/02_standardization")
        / "std_igdb_release_ready.sql"
    ),
    "inventory_release_ready": (
        Path("sql/02_standardization")
        / "std_inventory_release_ready.sql"
    ),
    "match_review": (
        Path("sql/06_validation")
        / "dq_igdb_match_review.sql"
    ),
    "release_source_dq": (
        Path("sql/06_validation")
        / "dq_release_date_conflicts.sql"
    ),
    "classification_promotion": (
        Path("sql/03_core")
        / "insert_igdb_classifications.sql"
    ),
    "release_promotion": (
        Path("sql/03_core")
        / "update_gameedition_release_dates_from_igdb.sql"
    ),
    "dim_classification": (
        Path("sql/04_dimensional")
        / "refresh_DimClassification.sql"
    ),
    "dim_bridge": (
        Path("sql/04_dimensional")
        / "refresh_BridgeGameClassification.sql"
    ),
}


def execute_sql_file(connection, path):
    print(f"Running SQL: {path}")

    sql = path.read_text(
        encoding="utf-8",
    )

    connection.execute(sql)


def run_python_script(script_name):
    path = PYTHON_DIR / script_name

    print()
    print(f"Running Python: {path}")
    print("=" * 70)

    result = subprocess.run(
        [
            sys.executable,
            str(path),
        ],
        check=False,
    )

    if result.returncode != 0:
        raise RuntimeError(
            f"{path} failed with exit code "
            f"{result.returncode}"
        )


def rebuild_igdb_views(connection):
    print()
    print("Rebuilding IGDB views")
    print("=" * 70)

    for key in (
        "map_classification",
        "classification_ready",
        "release_ready",
        "inventory_release_ready",
        "match_review",
        "release_source_dq",
    ):
        execute_sql_file(
            connection,
            SQL_FILES[key],
        )


def get_unstaged_count(connection):
    return connection.execute(
        """
        SELECT COUNT(*)
        FROM (
            SELECT DISTINCT
                g.GameID,

                CASE p.PlatformName
                    WHEN 'PS4' THEN 'PS4'
                    WHEN 'PS5' THEN 'PS5'
                    WHEN 'Wii U' THEN 'WIIU'
                END AS SearchPlatform

            FROM Game AS g

            JOIN UserGameRecord AS ugr
                ON ugr.GameID = g.GameID

            JOIN GameEntitlement AS ent
                ON ent.UserGameRecordID =
                   ugr.UserGameRecordID

            JOIN GameEdition AS ge
                ON ge.GameEditionID =
                   ent.GameEditionID

            JOIN Platform AS p
                ON p.PlatformID =
                   ge.PlatformID

            WHERE p.PlatformName IN (
                'PS4',
                'PS5',
                'Wii U'
            )

            AND NOT EXISTS (
                SELECT 1
                FROM stg_igdb_game_raw AS s
                WHERE s.GAIASGameID =
                      g.GameID

                  AND s.SearchPlatform =
                      CASE p.PlatformName
                          WHEN 'PS4' THEN 'PS4'
                          WHEN 'PS5' THEN 'PS5'
                          WHEN 'Wii U' THEN 'WIIU'
                      END
            )
        ) AS unstaged
        """
    ).fetchone()[0]


def run_new_game_batches():
    while True:
        connection = duckdb.connect(
            str(DB_PATH),
            read_only=True,
        )

        try:
            remaining = get_unstaged_count(
                connection
            )
        finally:
            connection.close()

        print()
        print(
            "Unstaged IGDB game/platform rows: "
            f"{remaining}"
        )

        if remaining == 0:
            break

        run_python_script(
            "igdb_batch_enrich.py"
        )


def promote_safe_data(connection):
    print()
    print("Promoting validated IGDB data")
    print("=" * 70)

    execute_sql_file(
        connection,
        SQL_FILES[
            "classification_promotion"
        ],
    )

    execute_sql_file(
        connection,
        SQL_FILES[
            "release_promotion"
        ],
    )


def refresh_dimensions(connection):
    print()
    print("Refreshing classification dimensions")
    print("=" * 70)

    execute_sql_file(
        connection,
        SQL_FILES[
            "dim_classification"
        ],
    )

    execute_sql_file(
        connection,
        SQL_FILES[
            "dim_bridge"
        ],
    )


def get_audit_results(connection):
    return {
        "Unresolved IGDB matches":
            connection.execute(
                """
                SELECT COUNT(*)
                FROM dq_igdb_match_review
                """
            ).fetchone()[0],

        "Unmapped IGDB classifications":
            connection.execute(
                """
                SELECT COUNT(*)
                FROM std_igdb_classification_ready
                WHERE MappingStatus <> 'READY'
                """
            ).fetchone()[0],

        "Release dates ready to fill":
            connection.execute(
                """
                SELECT COUNT(*)
                FROM std_igdb_release_ready
                WHERE ReleaseDateStatus =
                      'READY_TO_FILL'
                """
            ).fetchone()[0],

        "Invalid PS5 dates ready to repair":
            connection.execute(
                """
                SELECT COUNT(*)
                FROM std_igdb_release_ready
                WHERE ReleaseDateStatus =
                      'READY_TO_REPAIR_INVALID_PS5'
                """
            ).fetchone()[0],

        "Invalid core PS5 dates":
            connection.execute(
                """
                SELECT COUNT(*)
                FROM GameEdition AS ge

                JOIN Platform AS p
                    ON p.PlatformID =
                       ge.PlatformID

                WHERE p.PlatformName = 'PS5'
                  AND ge.ReleaseDate <
                      DATE '2020-11-12'
                """
            ).fetchone()[0],

        "Core classifications":
            connection.execute(
                """
                SELECT COUNT(*)
                FROM GameClassification
                """
            ).fetchone()[0],

        "Dimensional classifications":
            connection.execute(
                """
                SELECT COUNT(*)
                FROM DimClassification
                """
            ).fetchone()[0],

        "Core classification bridges":
            connection.execute(
                """
                SELECT COUNT(*)
                FROM GameClassificationBridge
                """
            ).fetchone()[0],

        "Dimensional classification bridges":
            connection.execute(
                """
                SELECT COUNT(*)
                FROM BridgeGameClassification
                """
            ).fetchone()[0],

        "Source-level PS5 date anomalies":
            connection.execute(
                """
                SELECT COUNT(*)
                FROM dq_release_date_conflicts
                """
            ).fetchone()[0],
    }


def print_audit(results):
    print()
    print("Final IGDB audit")
    print("=" * 70)

    for label, value in results.items():
        print(
            f"{label}: {value}"
        )


def validate_audit(results):
    failures = []

    zero_required = (
        "Unresolved IGDB matches",
        "Unmapped IGDB classifications",
        "Release dates ready to fill",
        "Invalid PS5 dates ready to repair",
        "Invalid core PS5 dates",
    )

    for label in zero_required:
        if results[label] != 0:
            failures.append(
                f"{label}: {results[label]}"
            )

    if (
        results["Core classifications"]
        != results[
            "Dimensional classifications"
        ]
    ):
        failures.append(
            "Core and dimensional "
            "classification counts differ"
        )

    if (
        results[
            "Core classification bridges"
        ]
        != results[
            "Dimensional classification bridges"
        ]
    ):
        failures.append(
            "Core and dimensional "
            "classification bridge counts differ"
        )

    if failures:
        print()
        print("PIPELINE VALIDATION FAILED")
        print("=" * 70)

        for failure in failures:
            print(f"- {failure}")

        raise RuntimeError(
            "IGDB pipeline completed processing "
            "but failed final governance checks."
        )


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Run the governed GAIAS IGDB "
            "enrichment pipeline."
        )
    )

    parser.add_argument(
        "--retry",
        action="store_true",
        help=(
            "Retry rows currently surfaced by "
            "dq_igdb_match_review."
        ),
    )

    parser.add_argument(
        "--refresh-releases",
        action="store_true",
        help=(
            "Refresh missing release dates and "
            "invalid pre-launch PS5 dates."
        ),
    )

    args = parser.parse_args()

    print("GAIAS IGDB PIPELINE")
    print("=" * 70)

    run_new_game_batches()

    connection = duckdb.connect(
        str(DB_PATH)
    )

    try:
        rebuild_igdb_views(
            connection
        )
    finally:
        connection.close()

    if args.retry:
        run_python_script(
            "igdb_retry_enrich.py"
        )

    if args.refresh_releases:
        run_python_script(
            "igdb_release_refresh.py"
        )

    connection = duckdb.connect(
        str(DB_PATH)
    )

    try:
        rebuild_igdb_views(
            connection
        )

        promote_safe_data(
            connection
        )

        rebuild_igdb_views(
            connection
        )

        refresh_dimensions(
            connection
        )

        results = get_audit_results(
            connection
        )

        print_audit(
            results
        )

        validate_audit(
            results
        )

        connection.execute(
            "FORCE CHECKPOINT"
        )

    finally:
        connection.close()

    print()
    print(
        "IGDB pipeline completed successfully."
    )


if __name__ == "__main__":
    main()