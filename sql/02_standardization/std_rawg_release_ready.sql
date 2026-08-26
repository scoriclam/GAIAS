CREATE OR REPLACE VIEW std_rawg_release_ready AS

WITH latest_result AS (
    SELECT
        GameEditionID,
        GameID,
        SearchTitle,
        SearchPlatform,
        RAWGID,
        RAWGName,
        ReleaseDate AS RAWGReleaseDate,
        FetchStatus,
        FetchedAt,

        ROW_NUMBER() OVER (
            PARTITION BY GameEditionID
            ORDER BY FetchedAt DESC
        ) AS rn

    FROM stg_rawg_release_raw
)

SELECT
    lr.GameEditionID,
    lr.GameID,
    lr.SearchTitle,
    lr.SearchPlatform,
    lr.RAWGID,
    lr.RAWGName,
    ge.ReleaseDate AS ExistingReleaseDate,
    lr.RAWGReleaseDate,
    lr.FetchStatus,

    CASE
        WHEN lr.FetchStatus = 'MATCHED_WITH_DATE'
         AND lr.RAWGReleaseDate IS NOT NULL
         AND EXTRACT(MONTH FROM lr.RAWGReleaseDate) = 12
         AND EXTRACT(DAY FROM lr.RAWGReleaseDate) = 31
            THEN 'POSSIBLE_PLACEHOLDER'

        WHEN lr.FetchStatus = 'MATCHED_WITH_DATE'
         AND lr.RAWGReleaseDate IS NOT NULL
         AND ge.ReleaseDate IS NULL
            THEN 'READY_TO_FILL'

        WHEN lr.FetchStatus = 'MATCHED_WITH_DATE'
         AND lr.RAWGReleaseDate IS NOT NULL
         AND ge.ReleaseDate = lr.RAWGReleaseDate
            THEN 'ALIGNED'

        WHEN lr.FetchStatus = 'MATCHED_WITH_DATE'
         AND lr.RAWGReleaseDate IS NOT NULL
         AND ge.ReleaseDate IS NOT NULL
         AND ge.ReleaseDate <> lr.RAWGReleaseDate
            THEN 'CONFLICT'

        WHEN lr.FetchStatus = 'MATCHED_NO_DATE'
            THEN 'CONFIRMED_NO_DATE'

        WHEN lr.FetchStatus IN (
            'LOW_CONFIDENCE',
            'NO_PS5_MATCH',
            'AMBIGUOUS'
        )
            THEN 'MATCH_REVIEW'

        ELSE 'NO_ACTION'
    END AS ReleaseDateStatus

FROM latest_result lr

JOIN GameEdition ge
    ON ge.GameEditionID = lr.GameEditionID

WHERE lr.rn = 1;