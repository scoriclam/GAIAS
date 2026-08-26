CREATE OR REPLACE VIEW std_psn_gameedition_candidates AS

WITH all_games AS (
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

gaias_editions AS (
    SELECT DISTINCT
        g.GameID,
        g.GameTitle,
        p.PlatformName,
        g.NormalizedGameTitle

    FROM all_games AS g

    JOIN GameEdition AS ge
        ON ge.GameID = g.GameID

    JOIN Platform AS p
        ON p.PlatformID = ge.PlatformID

    WHERE p.PlatformName IN (
        'PS4',
        'PS5'
    )
),

psn_platform_counts AS (
    SELECT
        NormalizedGameName,
        COUNT(DISTINCT Platform) AS PSNPlatformCount

    FROM std_psn_library_normalized

    GROUP BY
        NormalizedGameName
),

cross_platform_candidates AS (
    SELECT
        psn.EntitlementID,
        psn.ProductID,
        psn.TitleID,
        psn.ConceptID,

        existing.GameID,
        existing.GameTitle AS GAIASGameTitle,
        psn.GameName AS PSNGameName,

        existing.PlatformName AS ExistingGAIASPlatform,
        psn.Platform AS ProposedPlatform,

        psn.Membership,

        'ADD_MISSING_PLAYSTATION_EDITION'
            AS CandidateType,

        CASE
            WHEN pc.PSNPlatformCount = 2
                THEN 'PSN_BOTH_PLATFORMS'
            ELSE 'PSN_SINGLE_PLATFORM'
        END AS EvidenceStrength,

        psn.IsActive,
        psn.IsDownloadable,
        psn.IsPreOrder,
        psn.FetchedAt

    FROM std_psn_library_normalized AS psn

    JOIN gaias_editions AS existing
        ON existing.NormalizedGameTitle =
           psn.NormalizedGameName
       AND existing.PlatformName <>
           psn.Platform

    JOIN psn_platform_counts AS pc
        ON pc.NormalizedGameName =
           psn.NormalizedGameName

    LEFT JOIN gaias_editions AS exact_match
        ON exact_match.NormalizedGameTitle =
           psn.NormalizedGameName
       AND exact_match.PlatformName =
           psn.Platform

    WHERE exact_match.GameID IS NULL
),

first_playstation_candidates AS (
    SELECT
        psn.EntitlementID,
        psn.ProductID,
        psn.TitleID,
        psn.ConceptID,

        g.GameID,
        g.GameTitle AS GAIASGameTitle,
        psn.GameName AS PSNGameName,

        CAST(NULL AS VARCHAR)
            AS ExistingGAIASPlatform,

        psn.Platform AS ProposedPlatform,

        psn.Membership,

        'ADD_FIRST_PLAYSTATION_EDITION'
            AS CandidateType,

        'PSN_PLATFORM_ENTITLEMENT'
            AS EvidenceStrength,

        psn.IsActive,
        psn.IsDownloadable,
        psn.IsPreOrder,
        psn.FetchedAt

    FROM std_psn_library_normalized AS psn

    JOIN all_games AS g
        ON g.NormalizedGameTitle =
           psn.NormalizedGameName

    WHERE NOT EXISTS (
        SELECT 1

        FROM gaias_editions AS ge

        WHERE ge.NormalizedGameTitle =
              psn.NormalizedGameName
    )
)

SELECT DISTINCT *
FROM cross_platform_candidates

UNION ALL

SELECT DISTINCT *
FROM first_playstation_candidates;