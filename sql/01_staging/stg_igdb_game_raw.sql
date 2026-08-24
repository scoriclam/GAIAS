CREATE TABLE IF NOT EXISTS stg_igdb_game_raw (
    GAIASGameID INTEGER,
    SearchTitle VARCHAR,
    SearchPlatform VARCHAR,
    IGDBID BIGINT,
    IGDBName VARCHAR,
    ReleaseDate DATE,
    GenresRaw VARCHAR,
    ThemesRaw VARCHAR,
    GameModesRaw VARCHAR,
    PlayerPerspectivesRaw VARCHAR,
    RawPayload JSON,
    FetchStatus VARCHAR,
    FetchedAt TIMESTAMP
);