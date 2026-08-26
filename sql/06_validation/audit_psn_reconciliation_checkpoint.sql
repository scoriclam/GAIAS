WITH exact_matches AS (
    SELECT COUNT(*) AS Rows

    FROM std_psn_library_normalized AS psn

    JOIN (
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
    ) AS ge
        ON ge.NormalizedGameTitle =
           psn.NormalizedGameName
       AND ge.PlatformName =
           psn.Platform
),

edition_candidates AS (
    SELECT COUNT(*) AS Rows
    FROM std_psn_gameedition_candidates
),

approved_fuzzy AS (
    SELECT COUNT(*) AS Rows
    FROM std_psn_reviewed_matches
    WHERE MatchDecision = 'APPROVED'
),

review_required AS (
    SELECT COUNT(*) AS Rows
    FROM std_psn_reviewed_matches
    WHERE MatchDecision = 'REVIEW_REQUIRED'
),

non_game AS (
    SELECT COUNT(*) AS Rows
    FROM std_psn_non_game_exclusions
)

SELECT
    (SELECT Rows FROM exact_matches)
        AS ExactTitlePlatformMatches,

    (SELECT Rows FROM edition_candidates)
        AS GameEditionCandidates,

    (SELECT Rows FROM approved_fuzzy)
        AS ApprovedFuzzyMatches,

    (SELECT Rows FROM review_required)
        AS ReviewRequired,

    (SELECT Rows FROM non_game)
        AS NonGameExclusions;