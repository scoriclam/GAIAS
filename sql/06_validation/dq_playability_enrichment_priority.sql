CREATE OR REPLACE VIEW dq_playability_enrichment_priority AS

WITH classification_flags AS (
    SELECT
        b.GameID,

        MAX(
            CASE
                WHEN c.ClassificationType = 'Perspective'
                 AND c.ClassificationValue = 'Virtual Reality'
                THEN 1
                ELSE 0
            END
        ) AS VirtualRealityFlag,

        MAX(
            CASE
                WHEN c.ClassificationType = 'Genre'
                 AND c.ClassificationValue = 'Music'
                THEN 1
                ELSE 0
            END
        ) AS MusicGenreFlag,

        MAX(
            CASE
                WHEN c.ClassificationType = 'Genre'
                 AND c.ClassificationValue = 'Shooter'
                THEN 1
                ELSE 0
            END
        ) AS ShooterFlag,

        MAX(
            CASE
                WHEN c.ClassificationType = 'Perspective'
                 AND c.ClassificationValue = 'Side View'
                THEN 1
                ELSE 0
            END
        ) AS SideViewFlag

    FROM GameClassificationBridge b
    JOIN GameClassification c
        ON c.GameClassificationID = b.GameClassificationID

    GROUP BY
        b.GameID
),

review_base AS (
    SELECT
        p.GameKey,
        p.GameID,
        p.GameTitle,
        p.final_recommendation_score,
        p.playability_status,
        p.recommendation_status,

        COALESCE(cf.VirtualRealityFlag, 0) AS VirtualRealityFlag,
        COALESCE(cf.MusicGenreFlag, 0) AS MusicGenreFlag,

        CASE
            WHEN COALESCE(cf.ShooterFlag, 0) = 1
             AND COALESCE(cf.SideViewFlag, 0) = 1
            THEN 1
            ELSE 0
        END AS SideViewShooterFlag

    FROM mart_play_next_v2 p

    LEFT JOIN classification_flags cf
        ON cf.GameID = p.GameID

    WHERE p.playability_status = 'Unknown'
),

review_signals AS (
    SELECT
        *,

        (
            VirtualRealityFlag
            + MusicGenreFlag
            + SideViewShooterFlag
        ) AS ReviewSignalCount,

        CASE
            WHEN VirtualRealityFlag = 1
                THEN 'Virtual Reality'

            WHEN MusicGenreFlag = 1
             AND SideViewShooterFlag = 1
                THEN 'Music + Side-View Shooter'

            WHEN MusicGenreFlag = 1
                THEN 'Music Genre'

            WHEN SideViewShooterFlag = 1
                THEN 'Side-View Shooter'

            ELSE 'No Specific Risk Signal'
        END AS PrimaryReviewSignal

    FROM review_base
),

thresholds AS (
    SELECT
        quantile_cont(final_recommendation_score, 0.75) AS P75,
        quantile_cont(final_recommendation_score, 0.90) AS P90,
        quantile_cont(final_recommendation_score, 0.95) AS P95
    FROM review_signals
)

SELECT
    r.GameKey,
    r.GameID,
    r.GameTitle,
    r.final_recommendation_score,
    r.playability_status,
    r.recommendation_status,

    r.VirtualRealityFlag,
    r.MusicGenreFlag,
    r.SideViewShooterFlag,
    r.ReviewSignalCount,
    r.PrimaryReviewSignal,

    CASE
        WHEN r.final_recommendation_score >= t.P95
            THEN 'Priority 1'

        WHEN r.final_recommendation_score >= t.P90
            THEN 'Priority 2'

        WHEN r.final_recommendation_score >= t.P75
         AND r.ReviewSignalCount > 0
            THEN 'Priority 2'

        WHEN r.final_recommendation_score >= t.P75
            THEN 'Priority 3'

        WHEN r.ReviewSignalCount > 0
            THEN 'Priority 3'

        ELSE 'Lower Priority'
    END AS enrichment_priority

FROM review_signals r
CROSS JOIN thresholds t

ORDER BY
    CASE enrichment_priority
        WHEN 'Priority 1' THEN 1
        WHEN 'Priority 2' THEN 2
        WHEN 'Priority 3' THEN 3
        ELSE 4
    END,
    ReviewSignalCount DESC,
    final_recommendation_score DESC,
    GameTitle;