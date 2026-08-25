from pathlib import Path
import csv


PROJECT_ROOT = Path(__file__).resolve().parents[1]

INPUT_CSV = (
    PROJECT_ROOT
    / "source"
    / "playability_review_decisions_cycle2.csv"
)

OUTPUT_SQL = (
    PROJECT_ROOT
    / "source"
    / "playability_review_seed_fragment_cycle2.sql"
)

REQUIRED_FIELDS = [
    "GameID",
    "ControlSchemeRisk",
    "SpecialAccessoryRequired",
    "RhythmFlag",
    "SHMUPFlag",
    "SoulslikeFlag",
    "MitigationAvailable",
    "PlayabilityNotes",
]


def sql_quote(value):
    return "'" + value.replace("'", "''") + "'"


def normalize_bool(value):
    value = value.strip().upper()

    if value == "TRUE":
        return "TRUE"

    if value == "FALSE":
        return "FALSE"

    raise ValueError(
        f"Invalid boolean value: {value}"
    )


def load_rows():
    with INPUT_CSV.open(
        "r",
        encoding="utf-8-sig",
        newline="",
    ) as f:
        rows = list(csv.DictReader(f))

    if not rows:
        raise SystemExit(
            "ERROR: Decision file is empty."
        )

    for row in rows:
        for field in REQUIRED_FIELDS:
            if not row.get(field, "").strip():
                raise SystemExit(
                    f"ERROR: GameID {row.get('GameID', '?')} "
                    f"is missing required field: {field}"
                )

    return rows


def build_sql_row(row):
    game_id = int(row["GameID"])

    control_risk = sql_quote(
        row["ControlSchemeRisk"].strip()
    )

    accessory = normalize_bool(
        row["SpecialAccessoryRequired"]
    )

    rhythm = normalize_bool(
        row["RhythmFlag"]
    )

    shmup = normalize_bool(
        row["SHMUPFlag"]
    )

    soulslike = normalize_bool(
        row["SoulslikeFlag"]
    )

    mitigation = normalize_bool(
        row["MitigationAvailable"]
    )

    notes = sql_quote(
        row["PlayabilityNotes"].strip()
    )

    return (
        f"({game_id}, "
        f"{accessory}, "
        f"{control_risk}, "
        f"{rhythm}, "
        f"{shmup}, "
        f"{soulslike}, "
        f"{mitigation}, "
        f"{notes})"
    )


def main():
    rows = load_rows()

    game_ids = [
        int(row["GameID"])
        for row in rows
    ]

    duplicates = sorted(
        {
            game_id
            for game_id in game_ids
            if game_ids.count(game_id) > 1
        }
    )

    if duplicates:
        raise SystemExit(
            f"ERROR: Duplicate GameIDs found: {duplicates}"
        )

    sql_rows = [
        build_sql_row(row)
        for row in sorted(
            rows,
            key=lambda r: int(r["GameID"]),
        )
    ]

    lines = [
        "-- ============================================================",
        "-- Playability review queue decisions - Cycle 2",
        "-- Generated from source/playability_review_decisions_cycle2.csv",
        "-- ============================================================",
        "",
    ]

    for index, sql_row in enumerate(sql_rows):
        prefix = "," if index > 0 else ""
        lines.append(
            f"{prefix}{sql_row}"
        )

    OUTPUT_SQL.write_text(
        "\n".join(lines) + "\n",
        encoding="utf-8",
    )

    print(
        f"Created: {OUTPUT_SQL}"
    )
    print(
        f"Rows: {len(sql_rows)}"
    )
    print(
        f"Unique GameIDs: {len(set(game_ids))}"
    )


if __name__ == "__main__":
    main()