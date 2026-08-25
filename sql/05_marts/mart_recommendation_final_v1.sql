CREATE OR REPLACE VIEW mart_recommendation_final_v1 AS

WITH scored AS (
    SELECT
        r.GameKey,
        r.GameID,
        r.GameTitle,
        r.PlayStatusName,
        r.taste_affinity_score,
        r.conditional_affinity_percentile,
        r.affinity_path,
        r.playability_status,
        r.playability_adjustment,
        r.hard_exclusion_flag,
        r.exclusion_reason,
        q.avg_quality_rating,
        q.quality_percentile,
        q.quality_coverage_status,

        CASE
            WHEN q.quality_percentile IS NULL
                THEN 0
            ELSE ROUND(
                (q.quality_percentile - 50.0) * 0.10,
                2
            )
        END AS quality_adjustment,

        r.provisional_recommendation_score
            AS affinity_playability_score,

        CASE
            WHEN r.hard_exclusion_flag = TRUE
                THEN NULL

            WHEN r.provisional_recommendation_score IS NULL
                THEN NULL

            ELSE ROUND(
                r.provisional_recommendation_score
                + CASE
                    WHEN q.quality_percentile IS NULL
                        THEN 0
                    ELSE
                        (q.quality_percentile - 50.0) * 0.10
                  END,
                2
            )
        END AS final_recommendation_score,

        CASE
            WHEN r.hard_exclusion_flag = TRUE
                THEN 'Excluded'

            WHEN r.provisional_recommendation_score IS NULL
                THEN 'Insufficient Metadata'

            WHEN r.affinity_path = 'Conditional Affinity'
                THEN 'Conditional Recommendation'

            WHEN r.playability_status = 'Unknown'
                THEN 'Recommendation / Playability Unknown'

            WHEN r.playability_status = 'High Risk'
                THEN 'High Playability Risk'

            WHEN r.playability_status = 'Moderate Risk'
                THEN 'Moderate Playability Risk'

            ELSE 'Recommended'
        END AS recommendation_status

    FROM mart_recommendation_combined_v2 AS r

    LEFT JOIN mart_quality_signal_v1 AS q
        ON q.GameKey = r.GameKey
),

ranked AS (
    SELECT
        GameKey,

        ROUND(
            PERCENT_RANK() OVER (
                ORDER BY final_recommendation_score
            ) * 100.0,
            2
        ) AS recommendation_percentile

    FROM scored

    WHERE final_recommendation_score IS NOT NULL
)

SELECT
    s.GameKey,
    s.GameID,
    s.GameTitle,
    s.PlayStatusName,
    s.taste_affinity_score,
    s.conditional_affinity_percentile,
    s.affinity_path,
    s.playability_status,
    s.playability_adjustment,
    s.hard_exclusion_flag,
    s.exclusion_reason,
    s.avg_quality_rating,
    s.quality_percentile,
    s.quality_coverage_status,
    s.quality_adjustment,
    s.affinity_playability_score,
    s.final_recommendation_score,
    s.recommendation_status,

    r.recommendation_percentile,

    CASE
        WHEN b.BenchmarkTier = 'S'
            THEN 'S - First-Rate'

        WHEN r.recommendation_percentile IS NULL
            THEN NULL

        WHEN r.recommendation_percentile >= 98.4
            THEN 'A - Great'

        WHEN r.recommendation_percentile >= 90.0
            THEN 'B - Debate'

        WHEN r.recommendation_percentile >= 70.0
            THEN 'C - Wait'

        WHEN r.recommendation_percentile >= 35.0
            THEN 'D - Relegate'

        ELSE 'F - Hate'
    END AS recommendation_tier

FROM scored AS s

LEFT JOIN ranked AS r
    ON r.GameKey = s.GameKey

LEFT JOIN UserRecommendationBenchmark AS b
    ON b.GameID = s.GameID;