WITH gaias_titles AS (
    SELECT DISTINCT
        TRIM(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    LOWER(g.GameTitle),
                    '[™®©]',
                    '',
                    'g'
                ),
                '[^a-z0-9]+',
                ' ',
                'g'
            )
        ) AS NormalizedGameTitle

    FROM Game AS g
),

unmatched AS (
    SELECT
        psn.EntitlementID,
        psn.NormalizedGameName,
        psn.GameName,
        psn.Platform

    FROM std_psn_library_normalized AS psn

    LEFT JOIN gaias_titles AS gt
        ON gt.NormalizedGameTitle =
           psn.NormalizedGameName

    WHERE gt.NormalizedGameTitle IS NULL
),

title_summary AS (
    SELECT
        NormalizedGameName,
        COUNT(*) AS EntitlementRows,
        COUNT(DISTINCT Platform) AS PlatformCount

    FROM unmatched

    GROUP BY
        NormalizedGameName
)

SELECT
    (
        SELECT COUNT(*)
        FROM unmatched
    ) AS UnmatchedEntitlementRows,

    COUNT(*) AS DistinctUnmatchedTitles,

    SUM(
        CASE
            WHEN PlatformCount = 2 THEN 1
            ELSE 0
        END
    ) AS TitlesOnBothPS4AndPS5,

    SUM(
        CASE
            WHEN PlatformCount = 1 THEN 1
            ELSE 0
        END
    ) AS TitlesOnOnePlatformOnly

FROM title_summary;