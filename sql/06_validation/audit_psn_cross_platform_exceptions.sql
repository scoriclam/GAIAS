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

cross_platform AS (
    SELECT
        psn.GameName,
        psn.NormalizedGameName,
        psn.Platform AS PSNPlatform,
        psn.Membership,
        psn.TitleID,
        psn.ProductID

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
        COUNT(DISTINCT Platform) AS PSNPlatformCount

    FROM std_psn_library_normalized

    GROUP BY
        NormalizedGameName
)

SELECT
    cp.GameName,
    cp.PSNPlatform,
    ge.PlatformName AS GAIASPlatform,
    cp.Membership,
    cp.TitleID,
    cp.ProductID

FROM cross_platform AS cp

JOIN psn_platform_counts AS pc
    ON pc.NormalizedGameName =
       cp.NormalizedGameName

JOIN gaias_editions AS ge
    ON ge.NormalizedGameTitle =
       cp.NormalizedGameName

WHERE pc.PSNPlatformCount = 1

ORDER BY
    cp.PSNPlatform,
    cp.GameName;