CREATE TABLE IF NOT EXISTS stg_rawg_release_raw (
    GameEditionID INTEGER NOT NULL,
    GameID INTEGER NOT NULL,
    SearchTitle VARCHAR NOT NULL,
    SearchPlatform VARCHAR NOT NULL,
    RAWGID INTEGER,
    RAWGName VARCHAR,
    ReleaseDate DATE,
    RawPayload JSON,
    FetchStatus VARCHAR NOT NULL,
    FetchedAt TIMESTAMP NOT NULL
);