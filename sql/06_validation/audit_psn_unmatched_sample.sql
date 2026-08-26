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
)

SELECT
    psn.GameName,
    psn.NormalizedGameName,
    psn.Platform,
    psn.Membership,
    psn.TitleID,
    psn.ProductID

FROM std_psn_library_normalized AS psn

LEFT JOIN gaias_editions AS ge
    ON ge.NormalizedGameTitle =
       psn.NormalizedGameName
   AND ge.PlatformName =
       psn.Platform

WHERE ge.GameID IS NULL

ORDER BY
    psn.Platform,
    psn.GameName

LIMIT 150;