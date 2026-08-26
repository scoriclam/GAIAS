CREATE OR REPLACE VIEW std_psn_unmatched_titles AS

WITH gaias_titles AS (
    SELECT DISTINCT
        TRIM(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    LOWER(GameTitle),
                    '[™®©]',
                    '',
                    'g'
                ),
                '[^a-z0-9]+',
                ' ',
                'g'
            )
        ) AS NormalizedGameTitle

    FROM Game
),

unmatched AS (
    SELECT
        psn.*

    FROM std_psn_library_normalized AS psn

    LEFT JOIN gaias_titles AS g
        ON g.NormalizedGameTitle =
           psn.NormalizedGameName

    WHERE g.NormalizedGameTitle IS NULL
)

SELECT
    NormalizedGameName,

    MIN(GameName) AS RepresentativePSNName,

    COUNT(*) AS EntitlementCount,

    COUNT(DISTINCT Platform)
        AS PlatformCount,

    MAX(
        CASE
            WHEN Platform = 'PS4'
                THEN 1
            ELSE 0
        END
    )::BOOLEAN AS HasPS4,

    MAX(
        CASE
            WHEN Platform = 'PS5'
                THEN 1
            ELSE 0
        END
    )::BOOLEAN AS HasPS5,

    MAX(
        CASE
            WHEN Membership = 'PS_PLUS'
                THEN 1
            ELSE 0
        END
    )::BOOLEAN AS HasPSPlusEntitlement,

    MAX(FetchedAt) AS FetchedAt

FROM unmatched

GROUP BY
    NormalizedGameName;