import json
from datetime import datetime, timezone

import duckdb


DB_PATH = "gaias.duckdb"


def unix_timestamp_to_date(timestamp):
    if timestamp is None:
        return None

    return datetime.fromtimestamp(
        timestamp,
        tz=timezone.utc
    ).date()


def write_match_to_staging(
    gaias_game_id,
    search_title,
    search_platform,
    match_result,
):
    match = match_result.get("match")
    status = match_result.get("status")

    if match:
        genres = [
            item["name"]
            for item in match.get("genres", [])
        ]

        themes = [
            item["name"]
            for item in match.get("themes", [])
        ]

        game_modes = [
            item["name"]
            for item in match.get("game_modes", [])
        ]

        perspectives = [
            item["name"]
            for item in match.get("player_perspectives", [])
        ]

        igdb_id = match.get("id")
        igdb_name = match.get("name")

        release_date = unix_timestamp_to_date(
            match.get("first_release_date")
        )

        raw_payload = json.dumps(match)

    else:
        genres = []
        themes = []
        game_modes = []
        perspectives = []

        igdb_id = None
        igdb_name = None
        release_date = None

        raw_payload = json.dumps(
            match_result.get("candidates", [])
        )

    con = duckdb.connect(DB_PATH)

    try:
        con.execute(
            """
            INSERT INTO stg_igdb_game_raw (
                GAIASGameID,
                SearchTitle,
                SearchPlatform,
                IGDBID,
                IGDBName,
                ReleaseDate,
                GenresRaw,
                ThemesRaw,
                GameModesRaw,
                PlayerPerspectivesRaw,
                RawPayload,
                FetchStatus,
                FetchedAt
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                gaias_game_id,
                search_title,
                search_platform,
                igdb_id,
                igdb_name,
                release_date,
                json.dumps(genres),
                json.dumps(themes),
                json.dumps(game_modes),
                json.dumps(perspectives),
                raw_payload,
                status,
                datetime.now(timezone.utc),
            ],
        )

    finally:
        con.close()