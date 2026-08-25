from pathlib import Path
import csv
import sys


PROJECT_ROOT = Path(__file__).resolve().parents[1]

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


def parse_cycle():
    if len(sys.argv) != 2:
        raise SystemExit(
            "Usage: "
            "python python/build_playability_seed_fragment.py <cycle_number>"
        )

    cycle = sys.argv[1].strip()

    if not cycle.isdigit():
        raise SystemExit(
            f"ERROR: Cycle must be a positive integer. Received: {cycle}"
        )

    cycle_number = int(cycle)

    if cycle_number < 1:
        raise SystemExit(
            "ERROR: Cycle must be 1 or greater."
        )

    return cycle_number


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


def load_rows(input_csv):
    if not input_csv.exists():
        raise SystemExit(
            f"ERROR: Decision file not found:\n{input_csv}"
        )

    with input_csv.open(
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
    game_id = int(
        row["GameID"]
    )

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
    cycle = parse_cycle()

    input_csv = (
        PROJECT_ROOT
        / "source"
        / f"playability_review_decisions_cycle{cycle}.csv"
    )

    output_sql = (
        PROJECT_ROOT
        / "source"
        / f"playability_review_seed_fragment_cycle{cycle}.sql"
    )

    rows = load_rows(
        input_csv
    )

    game_ids = [
        int(row["GameID"])
        for row in rows
    ]

    seen = set()
    duplicates = set()

    for game_id in game_ids:
        if game_id in seen:
            duplicates.add(
                game_id
            )

        seen.add(
            game_id
        )

    if duplicates:
        raise SystemExit(
            "ERROR: Duplicate GameIDs found: "
            f"{sorted(duplicates)}"
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
        f"-- Playability review queue decisions - Cycle {cycle}",
        (
            "-- Generated from "
            f"source/playability_review_decisions_cycle{cycle}.csv"
        ),
        "-- ============================================================",
        "",
    ]

    for index, sql_row in enumerate(
        sql_rows
    ):
        prefix = "," if index > 0 else ""

        lines.append(
            f"{prefix}{sql_row}"
        )

    output_sql.write_text(
        "\n".join(lines) + "\n",
        encoding="utf-8",
    )

    print(
        f"Cycle: {cycle}"
    )
    print(
        f"Created: {output_sql}"
    )
    print(
        f"Rows: {len(sql_rows)}"
    )
    print(
        f"Unique GameIDs: {len(set(game_ids))}"
    )


if __name__ == "__main__":
    main()