from pathlib import Path
import re
import shutil
from datetime import datetime


PROJECT_ROOT = Path(__file__).resolve().parents[1]

SEED_FILE = (
    PROJECT_ROOT
    / "sql"
    / "03_core"
    / "seed_GamePlayabilityProfile.sql"
)

FRAGMENT_FILE = (
    PROJECT_ROOT
    / "source"
    / "playability_review_seed_fragment_cycle2.sql"
)


def extract_game_id(sql_tuple):
    match = re.match(
        r"\(\s*(\d+)\s*,",
        sql_tuple.strip(),
    )

    if not match:
        raise ValueError(
            f"Could not determine GameID from:\n{sql_tuple}"
        )

    return int(match.group(1))


def extract_tuples(text):
    tuples = []

    depth = 0
    start = None
    in_string = False
    i = 0

    while i < len(text):
        char = text[i]

        if char == "'":
            if in_string:
                if (
                    i + 1 < len(text)
                    and text[i + 1] == "'"
                ):
                    i += 2
                    continue

                in_string = False

            else:
                in_string = True

        elif not in_string:
            if char == "(":
                if depth == 0:
                    start = i

                depth += 1

            elif char == ")":
                if depth == 0:
                    raise ValueError(
                        "Unbalanced closing parenthesis."
                    )

                depth -= 1

                if depth == 0 and start is not None:
                    tuples.append(
                        text[start:i + 1].strip()
                    )
                    start = None

        i += 1

    if in_string:
        raise ValueError(
            "Unterminated SQL string literal."
        )

    if depth != 0:
        raise ValueError(
            "Unbalanced SQL parentheses."
        )

    return tuples


def find_seed_sections(seed_text):
    insert_match = re.search(
        r"""
        INSERT
        \s+INTO
        \s+(?:\w+\.)?
        GamePlayabilityProfile
        \s*
        \(
        .*?
        \)
        \s*
        VALUES
        """,
        seed_text,
        flags=(
            re.IGNORECASE
            | re.DOTALL
            | re.VERBOSE
        ),
    )

    if not insert_match:
        raise SystemExit(
            "ERROR: Could not locate "
            "INSERT INTO GamePlayabilityProfile (...) VALUES."
        )

    values_match = re.search(
        r"\bVALUES\b",
        insert_match.group(0),
        flags=re.IGNORECASE,
    )

    if not values_match:
        raise SystemExit(
            "ERROR: INSERT statement found, "
            "but VALUES could not be located."
        )

    values_end = (
        insert_match.start()
        + values_match.end()
    )

    conflict_match = re.search(
        r"\bON\s+CONFLICT\b",
        seed_text[values_end:],
        flags=re.IGNORECASE,
    )

    if not conflict_match:
        raise SystemExit(
            "ERROR: Could not find ON CONFLICT "
            "after seed VALUES."
        )

    conflict_start = (
        values_end
        + conflict_match.start()
    )

    prefix = seed_text[:values_end]
    values_body = seed_text[
        values_end:conflict_start
    ]
    suffix = seed_text[
        conflict_start:
    ]

    return prefix, values_body, suffix


def rows_by_game_id(tuples, source_name):
    rows = {}

    for sql_tuple in tuples:
        game_id = extract_game_id(
            sql_tuple
        )

        if game_id in rows:
            raise SystemExit(
                f"ERROR: Duplicate GameID {game_id} "
                f"in {source_name}."
            )

        rows[game_id] = sql_tuple

    return rows


def main():
    if not SEED_FILE.exists():
        raise SystemExit(
            f"ERROR: Seed file not found:\n{SEED_FILE}"
        )

    if not FRAGMENT_FILE.exists():
        raise SystemExit(
            f"ERROR: Fragment file not found:\n{FRAGMENT_FILE}"
        )

    seed_text = SEED_FILE.read_text(
        encoding="utf-8"
    )

    fragment_text = FRAGMENT_FILE.read_text(
        encoding="utf-8"
    )

    prefix, existing_values, suffix = (
        find_seed_sections(seed_text)
    )

    existing_tuples = extract_tuples(
        existing_values
    )

    fragment_tuples = extract_tuples(
        fragment_text
    )

    existing_rows = rows_by_game_id(
        existing_tuples,
        "existing seed",
    )

    new_rows = rows_by_game_id(
        fragment_tuples,
        "review fragment",
    )

    overlap = sorted(
        set(existing_rows)
        & set(new_rows)
    )

    merged_rows = dict(
        existing_rows
    )

    merged_rows.update(
        new_rows
    )

    expected_total = (
        len(existing_rows)
        + len(new_rows)
        - len(overlap)
    )

    if len(merged_rows) != expected_total:
        raise SystemExit(
            "ERROR: Unexpected row-count mismatch "
            "during merge."
        )

    ordered_ids = sorted(
        merged_rows
    )

    formatted_rows = []

    for index, game_id in enumerate(
        ordered_ids
    ):
        row = merged_rows[
            game_id
        ]

        if index < len(ordered_ids) - 1:
            formatted_rows.append(
                f"    {row},"
            )
        else:
            formatted_rows.append(
                f"    {row}"
            )

    merged_sql = (
        prefix.rstrip()
        + "\n"
        + "\n".join(formatted_rows)
        + "\n"
        + suffix.lstrip()
    )

    _, final_values, _ = (
        find_seed_sections(
            merged_sql
        )
    )

    final_tuples = extract_tuples(
        final_values
    )

    final_rows = rows_by_game_id(
        final_tuples,
        "final merged seed",
    )

    if len(final_rows) != expected_total:
        raise SystemExit(
            "ERROR: Final validation row count failed."
        )

    timestamp = datetime.now().strftime(
        "%Y%m%d_%H%M%S"
    )

    backup_file = SEED_FILE.with_name(
        f"{SEED_FILE.stem}"
        f".backup_{timestamp}.sql"
    )

    shutil.copy2(
        SEED_FILE,
        backup_file,
    )

    SEED_FILE.write_text(
        merged_sql,
        encoding="utf-8",
    )

    print(
        f"Existing seed rows: {len(existing_rows)}"
    )
    print(
        f"Fragment rows: {len(new_rows)}"
    )
    print(
        f"Overlapping GameIDs: {len(overlap)}"
    )
    print(
        f"Final seed rows: {len(final_rows)}"
    )
    print(
        f"Unique GameIDs: {len(final_rows)}"
    )
    print(
        f"Backup: {backup_file}"
    )
    print(
        f"Updated: {SEED_FILE}"
    )


if __name__ == "__main__":
    main()