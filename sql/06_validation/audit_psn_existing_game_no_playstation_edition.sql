WITH all_gaias_titles AS (
    SELECT DISTINCT
        g.GameID,
        g.GameTitle,

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

playstation_titles AS (
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
    psn.GameName AS PSNGameName,
    psn.Platform AS PSNPlatform,
    psn.Membership,
    psn.TitleID,
    psn.ProductID,
    g.GameID,
    g.GameTitle AS GAIASGameTitle

FROM std_psn_library_normalized AS psn

JOIN all_gaias_titles AS g
    ON g.NormalizedGameTitle =
       psn.NormalizedGameName

LEFT JOIN playstation_titles AS pt
    ON pt.NormalizedGameTitle =
       psn.NormalizedGameName

WHERE pt.NormalizedGameTitle IS NULL

ORDER BY
    psn.GameName,
    psn.Platform;