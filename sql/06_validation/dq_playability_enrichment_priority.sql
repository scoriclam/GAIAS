CREATE OR REPLACE VIEW dq_playability_enrichment_priority AS

WITH classification_flags AS (
    SELECT
        gcb.GameID,

        MAX(
            CASE
                WHEN gc.ClassificationType = 'Theme'
                 AND gc.ClassificationDescription = 'Virtual Reality'
                THEN 1
                ELSE 0
            END
        ) AS VirtualRealityFlag,

        MAX(
            CASE
                WHEN gc.ClassificationType = 'Genre'
                 AND gc.ClassificationDescription = 'Music'
                THEN 1
                ELSE 0
            END
        ) AS MusicGenreFlag,

        MAX(
            CASE
                WHEN gc.ClassificationType = 'Perspective'
                 AND gc.ClassificationDescription = 'Side View'
                THEN 1
                ELSE 0
            END
        ) AS SideViewFlag,

        MAX(
            CASE
                WHEN gc.ClassificationType = 'Genre'
                 AND gc.ClassificationDescription = 'Shooter'
                THEN 1
                ELSE 0
            END
        ) AS ShooterFlag

    FROM GameClassificationBridge gcb

    JOIN GameClassification gc
        ON gcb.GameClassificationID = gc.GameClassificationID

    GROUP BY
        gcb.GameID
),

base AS (
    SELECT
        p.GameID,
        p.GameTitle,
        p.final_recommendation_score,
        p.recommendation_status,

        CASE
            WHEN COALESCE(cf.VirtualRealityFlag, 0) = 1
                THEN TRUE
            ELSE FALSE
        END AS VirtualRealityFlag,

        CASE
            WHEN COALESCE(cf.MusicGenreFlag, 0) = 1
                THEN TRUE
            ELSE FALSE
        END AS MusicGenreFlag,

        CASE
            WHEN COALESCE(cf.SideViewFlag, 0) = 1
             AND COALESCE(cf.ShooterFlag, 0) = 1
                THEN TRUE
            ELSE FALSE
        END AS SideViewShooterFlag

    FROM mart_play_next_v2 p

    LEFT JOIN classification_flags cf
        ON p.GameID = cf.GameID

    WHERE p.playability_status = 'Unknown'
),

scored AS (
    SELECT
        *,

        (
            CAST(VirtualRealityFlag AS INTEGER)
            + CAST(MusicGenreFlag AS INTEGER)
            + CAST(SideViewShooterFlag AS INTEGER)
        ) AS ReviewSignalCount,

        CASE
            WHEN VirtualRealityFlag
                THEN 'Virtual Reality'

            WHEN MusicGenreFlag
                THEN 'Music / Rhythm Review'

            WHEN SideViewShooterFlag
                THEN 'Side-View Shooter'

            ELSE 'No Specific Risk Signal'
        END AS PrimaryReviewSignal,

        CASE
            WHEN final_recommendation_score >= 70
                THEN 'High Recommendation Value'

            WHEN final_recommendation_score >= 55
                THEN 'Moderate Recommendation Value'

            WHEN final_recommendation_score >= 45
                THEN 'Borderline Recommendation Value'

            ELSE 'Low Recommendation Value'
        END AS RecommendationValueBand

    FROM base
)

SELECT
    *,

    CASE
        WHEN final_recommendation_score >= 70
            THEN 'Priority 1'

        WHEN final_recommendation_score >= 55
         AND ReviewSignalCount > 0
            THEN 'Priority 1'

        WHEN final_recommendation_score >= 55
            THEN 'Priority 2'

        WHEN final_recommendation_score >= 45
         AND ReviewSignalCount > 0
            THEN 'Priority 2'

        WHEN final_recommendation_score >= 45
            THEN 'Priority 3'

        WHEN ReviewSignalCount > 0
            THEN 'Risk Review Only'

        ELSE 'Defer'
    END AS enrichment_priority

FROM scored;