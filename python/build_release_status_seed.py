import duckdb


DB_PATH = "gaias.duckdb"
OUTPUT_PATH = "sql/03_core/seed_GameEditionReleaseStatus.sql"


def sql_value(value):
    if value is None:
        return "NULL"

    text = str(value).replace("'", "''")
    return f"'{text}'"


def main():
    con = duckdb.connect(
        DB_PATH,
        read_only=True,
    )

    try:
        rows = con.execute(
            """
            SELECT
                GameEditionID,
                ReleaseStatus,
                StatusReason,
                StatusSource
            FROM GameEditionReleaseStatus
            ORDER BY GameEditionID
            """
        ).fetchall()

    finally:
        con.close()

    with open(
        OUTPUT_PATH,
        "w",
        encoding="utf-8",
    ) as file:

        file.write(
            "-- Governed release-status assignments for "
            "GameEdition rows with NULL ReleaseDate.\n"
        )

        file.write(
            "-- Generated from the validated GAIAS "
            "database state.\n\n"
        )

        file.write(
            "INSERT INTO GameEditionReleaseStatus (\n"
            "    GameEditionID,\n"
            "    ReleaseStatus,\n"
            "    StatusReason,\n"
            "    StatusSource\n"
            ")\nVALUES\n"
        )

        values = []

        for (
            game_edition_id,
            release_status,
            status_reason,
            status_source,
        ) in rows:

            values.append(
                "    ("
                f"{game_edition_id}, "
                f"{sql_value(release_status)}, "
                f"{sql_value(status_reason)}, "
                f"{sql_value(status_source)}"
                ")"
            )

        file.write(",\n".join(values))

        file.write(
            "\nON CONFLICT (GameEditionID) "
            "DO UPDATE SET\n"
            "    ReleaseStatus = "
            "EXCLUDED.ReleaseStatus,\n"
            "    StatusReason = "
            "EXCLUDED.StatusReason,\n"
            "    StatusSource = "
            "EXCLUDED.StatusSource,\n"
"            LastReviewedAt = "
"now();\n"
        )

    print(f"Rows written: {len(rows)}")
    print(f"File: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()