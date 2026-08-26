WITH gaias_editions AS (
    SELECT DISTINCT
        g.GameID,
        g.GameTitle,
        p.PlatformName,

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

    FROM GameEdition AS ge

    JOIN Game AS g
        ON g.GameID = ge.GameID

    JOIN Platform AS p
        ON p.PlatformID = ge.PlatformID

    WHERE p.PlatformName IN (
        'PS4',
        'PS5'
    )
),

unmatched AS (
    SELECT
        psn.EntitlementID,
        psn.GameName,
        psn.NormalizedGameName,
        psn.Platform

    FROM std_psn_library_normalized AS psn

    LEFT JOIN gaias_editions AS exact_match
        ON exact_match.NormalizedGameTitle =
           psn.NormalizedGameName
       AND exact_match.PlatformName =
           psn.Platform

    WHERE exact_match.GameID IS NULL
),

classified AS (
    SELECT
        u.*,

        CASE
            WHEN EXISTS (
                SELECT 1
                FROM gaias_editions AS ge
                WHERE ge.NormalizedGameTitle =
                      u.NormalizedGameName
            )
                THEN 'TITLE_EXISTS_OTHER_PLATFORM'

            ELSE 'NO_NORMALIZED_TITLE_MATCH'
        END AS MatchCategory

    FROM unmatched AS u
)

SELECT
    MatchCategory,
    COUNT(*) AS Rows

FROM classified

GROUP BY MatchCategory

ORDER BY MatchCategory;