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
        psn.GameName,
        psn.NormalizedGameName,
        psn.Platform,
        psn.Membership,
        psn.TitleID,
        psn.ProductID

    FROM std_psn_library_normalized AS psn

    LEFT JOIN gaias_titles AS gt
        ON gt.NormalizedGameTitle =
           psn.NormalizedGameName

    WHERE gt.NormalizedGameTitle IS NULL
)

SELECT
    *

FROM unmatched

ORDER BY
    Platform,
    GameName

LIMIT 200;