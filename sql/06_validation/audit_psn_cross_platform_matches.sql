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
        psn.Platform AS PSNPlatform,
        psn.Membership

    FROM std_psn_library_normalized AS psn

    LEFT JOIN gaias_editions AS exact_match
        ON exact_match.NormalizedGameTitle =
           psn.NormalizedGameName
       AND exact_match.PlatformName =
           psn.Platform

    WHERE exact_match.GameID IS NULL
)

SELECT
    u.PSNPlatform,
    ge.PlatformName AS GAIASPlatform,
    COUNT(*) AS Rows

FROM unmatched AS u

JOIN gaias_editions AS ge
    ON ge.NormalizedGameTitle =
       u.NormalizedGameName

GROUP BY
    u.PSNPlatform,
    ge.PlatformName

ORDER BY
    u.PSNPlatform,
    ge.PlatformName;