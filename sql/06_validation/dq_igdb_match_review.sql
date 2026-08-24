CREATE OR REPLACE VIEW dq_igdb_match_review AS
WITH latest_result AS (
    SELECT
        GAIASGameID,
        SearchTitle,
        SearchPlatform,
        FetchStatus,
        IGDBID,
        IGDBName,
        ReleaseDate,
        FetchedAt,
        ROW_NUMBER() OVER (
            PARTITION BY GAIASGameID, SearchPlatform
            ORDER BY FetchedAt DESC
        ) AS row_num
    FROM stg_igdb_game_raw
)

SELECT
    GAIASGameID,
    SearchTitle,
    SearchPlatform,
    FetchStatus,
    IGDBID,
    IGDBName,
    ReleaseDate,
    FetchedAt
FROM latest_result
WHERE row_num = 1
  AND FetchStatus IN (
      'NO_EXACT_MATCH',
      'AMBIGUOUS',
      'UNSUPPORTED_PLATFORM'
  );