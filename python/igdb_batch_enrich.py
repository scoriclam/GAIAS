import duckdb

from igdb_matcher import IGDBMatcher
from igdb_stage_writer import write_match_to_staging


DB_PATH = "gaias.duckdb"
BATCH_SIZE = 20


PLATFORM_CODE_MAP = {
    "PlayStation 4": "PS4",
    "PlayStation 5": "PS5",
    "Wii U": "WIIU",
}


def get_games_for_enrichment():
    con = duckdb.connect(DB_PATH, read_only=True)

    try:
        rows = con.execute(
            """
            SELECT
                g.GameID,
                g.GameTitle,
                p.PlatformName
            FROM Game g
            JOIN GameEdition ge
                ON ge.GameID = g.GameID
            JOIN Platform p
                ON p.PlatformID = ge.PlatformID
            WHERE p.PlatformName IN (
                'PlayStation 4',
                'PlayStation 5',
                'Wii U'
            )
              AND NOT EXISTS (
                  SELECT 1
                  FROM stg_igdb_game_raw s
                  WHERE s.GAIASGameID = g.GameID
                    AND s.SearchPlatform = CASE p.PlatformName
                        WHEN 'PlayStation 4' THEN 'PS4'
                        WHEN 'PlayStation 5' THEN 'PS5'
                        WHEN 'Wii U' THEN 'WIIU'
                    END
                    AND s.FetchStatus IN (
                        'MATCHED',
                        'MATCHED_OVERRIDE',
                        'MATCHED_BACKCOMPAT'
                    )
              )
            ORDER BY g.GameID
            LIMIT ?
            """,
            [BATCH_SIZE],
        ).fetchall()

        return rows

    finally:
        con.close()


def main():
    matcher = IGDBMatcher()

    games = get_games_for_enrichment()

    print(f"Games selected: {len(games)}")
    print()

    for game_id, game_title, platform_name in games:
        platform_code = PLATFORM_CODE_MAP[platform_name]

        print(
            f"Processing GameID {game_id}: "
            f"{game_title} [{platform_code}]"
        )

        result = matcher.match_game(
            game_title,
            platform_code,
            gaias_game_id=game_id,
        )

        print(f"Match status: {result['status']}")

        if result["match"]:
            print(
                f"IGDB: {result['match']['id']} - "
                f"{result['match']['name']}"
            )

        write_match_to_staging(
            gaias_game_id=game_id,
            search_title=game_title,
            search_platform=platform_code,
            match_result=result,
        )

        print("-" * 70)


if __name__ == "__main__":
    main()