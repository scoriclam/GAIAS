CREATE OR REPLACE VIEW std_psn_fuzzy_match_candidates AS

WITH unresolved_base AS (
    SELECT
        u.NormalizedGameName,
        u.RepresentativePSNName,

        TRIM(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    u.NormalizedGameName,
                    '(^| )(ps4|ps5)( |$)',
                    ' ',
                    'g'
                ),
                '(^| )[0-9]{4}( |$)',
                ' ',
                'g'
            )
        ) AS MatchTitle

    FROM std_psn_unmatched_titles AS u

    LEFT JOIN std_psn_non_game_exclusions AS e
        ON e.NormalizedGameName =
           u.NormalizedGameName

    WHERE e.NormalizedGameName IS NULL
),

unresolved AS (
    SELECT
        NormalizedGameName,
        RepresentativePSNName,
        MatchTitle,

        CASE
            WHEN REGEXP_MATCHES(
                MatchTitle,
                '[0-9]+'
            )
                THEN REGEXP_EXTRACT(
                    MatchTitle,
                    '([0-9]+)',
                    1
                )

            WHEN REGEXP_MATCHES(
                MatchTitle,
                '(^| )(i|ii|iii|iv|v|vi|vii|viii|ix|x)( |$)'
            )
                THEN
                    CASE REGEXP_EXTRACT(
                        MatchTitle,
                        '(^| )(i|ii|iii|iv|v|vi|vii|viii|ix|x)( |$)',
                        2
                    )
                        WHEN 'i' THEN '1'
                        WHEN 'ii' THEN '2'
                        WHEN 'iii' THEN '3'
                        WHEN 'iv' THEN '4'
                        WHEN 'v' THEN '5'
                        WHEN 'vi' THEN '6'
                        WHEN 'vii' THEN '7'
                        WHEN 'viii' THEN '8'
                        WHEN 'ix' THEN '9'
                        WHEN 'x' THEN '10'
                    END

            ELSE NULL
        END AS SequenceMarker

    FROM unresolved_base
),

gaias_base AS (
    SELECT DISTINCT
        g.GameID,
        g.GameTitle,

        TRIM(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
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
                    ),
                    '(^| )(ps4|ps5)( |$)',
                    ' ',
                    'g'
                ),
                '(^| )[0-9]{4}( |$)',
                ' ',
                'g'
            )
        ) AS MatchTitle

    FROM Game AS g
),

gaias_titles AS (
    SELECT
        GameID,
        GameTitle,
        MatchTitle,

        CASE
            WHEN REGEXP_MATCHES(
                MatchTitle,
                '[0-9]+'
            )
                THEN REGEXP_EXTRACT(
                    MatchTitle,
                    '([0-9]+)',
                    1
                )

            WHEN REGEXP_MATCHES(
                MatchTitle,
                '(^| )(i|ii|iii|iv|v|vi|vii|viii|ix|x)( |$)'
            )
                THEN
                    CASE REGEXP_EXTRACT(
                        MatchTitle,
                        '(^| )(i|ii|iii|iv|v|vi|vii|viii|ix|x)( |$)',
                        2
                    )
                        WHEN 'i' THEN '1'
                        WHEN 'ii' THEN '2'
                        WHEN 'iii' THEN '3'
                        WHEN 'iv' THEN '4'
                        WHEN 'v' THEN '5'
                        WHEN 'vi' THEN '6'
                        WHEN 'vii' THEN '7'
                        WHEN 'viii' THEN '8'
                        WHEN 'ix' THEN '9'
                        WHEN 'x' THEN '10'
                    END

            ELSE NULL
        END AS SequenceMarker

    FROM gaias_base
),

eligible_candidates AS (
    SELECT
        u.NormalizedGameName,
        u.RepresentativePSNName,
        u.SequenceMarker AS PSNSequenceMarker,

        g.GameID,
        g.GameTitle,
        g.SequenceMarker AS GAIASSequenceMarker,

        JARO_WINKLER_SIMILARITY(
            u.MatchTitle,
            g.MatchTitle
        ) AS SimilarityScore

    FROM unresolved AS u

    CROSS JOIN gaias_titles AS g

    WHERE
        (
            u.SequenceMarker IS NULL
            AND g.SequenceMarker IS NULL
        )
        OR
        (
            u.SequenceMarker IS NOT NULL
            AND g.SequenceMarker =
                u.SequenceMarker
        )
),

ranked AS (
    SELECT
        *,

        ROW_NUMBER() OVER (
            PARTITION BY NormalizedGameName

            ORDER BY
                SimilarityScore DESC,
                GameID
        ) AS MatchRank

    FROM eligible_candidates
)

SELECT
    NormalizedGameName,
    RepresentativePSNName,
    GameID AS CandidateGameID,
    GameTitle AS CandidateGameTitle,
    PSNSequenceMarker,
    GAIASSequenceMarker,
    SimilarityScore

FROM ranked

WHERE MatchRank = 1;