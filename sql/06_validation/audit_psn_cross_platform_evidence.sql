WITH gaias_editions AS (
    SELECT DISTINCT
        g.GameID,
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

cross_platform AS (
    SELECT
        psn.EntitlementID,
        psn.GameName,
        psn.NormalizedGameName,
        psn.Platform AS PSNPlatform

    FROM std_psn_library_normalized AS psn

    LEFT JOIN gaias_editions AS exact_match
        ON exact_match.NormalizedGameTitle =
           psn.NormalizedGameName
       AND exact_match.PlatformName =
           psn.Platform

    WHERE exact_match.GameID IS NULL

      AND EXISTS (
          SELECT 1
          FROM gaias_editions AS ge
          WHERE ge.NormalizedGameTitle =
                psn.NormalizedGameName
      )
),

psn_platform_counts AS (
    SELECT
        NormalizedGameName,
        COUNT(
            DISTINCT Platform
        ) AS PSNPlatformCount

    FROM std_psn_library_normalized

    GROUP BY
        NormalizedGameName
)

SELECT
    cp.PSNPlatform,

    CASE
        WHEN pc.PSNPlatformCount = 2
            THEN 'PSN_HAS_BOTH_PLATFORMS'
        ELSE 'PSN_HAS_ONLY_MISSING_PLATFORM'
    END AS EvidenceCategory,

    COUNT(*) AS Rows

FROM cross_platform AS cp

JOIN psn_platform_counts AS pc
    ON pc.NormalizedGameName =
       cp.NormalizedGameName

GROUP BY
    cp.PSNPlatform,
    EvidenceCategory

ORDER BY
    cp.PSNPlatform,
    EvidenceCategory;