import duckdb

from igdb_matcher import IGDBMatcher
from igdb_stage_writer import write_match_to_staging


DB_PATH = "gaias.duckdb"
BATCH_SIZE = 20


def get_games_for_retry():
    con = duckdb.connect(DB_PATH, read_only=True)

    try:
        rows = con.execute(
            """
            SELECT
                r.GAIASGameID,
                g.GameTitle,
                r.SearchPlatform,
                acq.AcquisitionSourceName
            FROM dq_igdb_match_review r
            JOIN Game g
                ON g.GameID = r.GAIASGameID
            JOIN UserGameRecord ugr
                ON ugr.GameID = g.GameID
            JOIN GameEntitlement ent
                ON ent.UserGameRecordID = ugr.UserGameRecordID
            JOIN AcquisitionSource acq
                ON acq.AcquisitionSourceID = ent.AcquisitionSourceID
            JOIN GameEdition ge
                ON ge.GameEditionID = ent.GameEditionID
            JOIN Platform p
                ON p.PlatformID = ge.PlatformID
            WHERE r.SearchPlatform = CASE p.PlatformName
                WHEN 'PlayStation 4' THEN 'PS4'
                WHEN 'PlayStation 5' THEN 'PS5'
                WHEN 'Wii U' THEN 'WIIU'
            END
            ORDER BY r.GAIASGameID
            LIMIT ?
            """,
            [BATCH_SIZE],
        ).fetchall()

        return rows

    finally:
        con.close()


def main():
    matcher = IGDBMatcher()

    games = get_games_for_retry()

    print(f"Games selected for retry: {len(games)}")
    print()

    for (
        game_id,
        game_title,
        platform_code,
        acquisition_source,
    ) in games:
        print(
            f"Retrying GameID {game_id}: "
            f"{game_title} [{platform_code}] "
            f"Source={acquisition_source}"
        )

        result = matcher.match_game(
            game_title,
            platform_code,
            gaias_game_id=game_id,
            acquisition_source=acquisition_source,
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