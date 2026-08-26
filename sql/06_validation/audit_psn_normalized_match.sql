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
)

SELECT
    COUNT(*) AS PSNRows,

    SUM(
        CASE
            WHEN ge.GameID IS NOT NULL
                THEN 1
            ELSE 0
        END
    ) AS NormalizedMatches,

    SUM(
        CASE
            WHEN ge.GameID IS NULL
                THEN 1
            ELSE 0
        END
    ) AS StillUnmatched,

    ROUND(
        100.0
        * SUM(
            CASE
                WHEN ge.GameID IS NOT NULL
                    THEN 1
                ELSE 0
            END
        )
        / COUNT(*),
        2
    ) AS NormalizedMatchPct

FROM std_psn_library_normalized AS psn

LEFT JOIN gaias_editions AS ge
    ON ge.NormalizedGameTitle =
       psn.NormalizedGameName
   AND ge.PlatformName =
       psn.Platform;