CREATE OR REPLACE VIEW std_igdb_release_ready AS
WITH latest_result AS (
    SELECT
        GAIASGameID,
        SearchPlatform,
        IGDBID,
        IGDBName,
        ReleaseDate AS IGDBReleaseDate,
        FetchStatus,
        FetchedAt,
        ROW_NUMBER() OVER (
            PARTITION BY GAIASGameID, SearchPlatform
            ORDER BY FetchedAt DESC
        ) AS row_num
    FROM stg_igdb_game_raw
),

latest_success AS (
    SELECT
        GAIASGameID,
        SearchPlatform,
        IGDBID,
        IGDBName,
        IGDBReleaseDate,
        FetchStatus
    FROM latest_result
    WHERE row_num = 1
      AND FetchStatus IN (
          'MATCHED',
          'MATCHED_OVERRIDE'
      )
)

SELECT
    g.GameID,
    g.GameTitle,
    ge.GameEditionID,
    p.PlatformName,
    ge.ReleaseDate AS ExistingReleaseDate,
    ls.IGDBReleaseDate,
    ls.IGDBID,
    ls.IGDBName,
    ls.FetchStatus,
    CASE
        WHEN ge.ReleaseDate IS NULL
             AND ls.IGDBReleaseDate IS NOT NULL
            THEN 'READY_TO_FILL'

        WHEN ge.ReleaseDate IS NOT NULL
             AND ls.IGDBReleaseDate IS NOT NULL
             AND ge.ReleaseDate <> ls.IGDBReleaseDate
            THEN 'CONFLICT'

        WHEN ge.ReleaseDate = ls.IGDBReleaseDate
            THEN 'ALIGNED'

        WHEN ls.IGDBReleaseDate IS NULL
            THEN 'NO_IGDB_DATE'

        ELSE 'NO_ACTION'
    END AS ReleaseDateStatus
FROM latest_success ls
JOIN Game g
    ON g.GameID = ls.GAIASGameID
JOIN GameEdition ge
    ON ge.GameID = g.GameID
JOIN Platform p
    ON p.PlatformID = ge.PlatformID
WHERE ls.SearchPlatform = CASE p.PlatformName
    WHEN 'PS4' THEN 'PS4'
    WHEN 'PS5' THEN 'PS5'
    WHEN 'Wii U' THEN 'WIIU'
END;