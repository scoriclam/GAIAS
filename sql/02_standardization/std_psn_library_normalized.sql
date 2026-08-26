CREATE OR REPLACE VIEW std_psn_library_normalized AS

SELECT
    *,
    TRIM(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                LOWER(GameName),
                '[™®©]',
                '',
                'g'
            ),
            '[^a-z0-9]+',
            ' ',
            'g'
        )
    ) AS NormalizedGameName

FROM std_psn_library_latest;