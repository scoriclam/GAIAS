CREATE OR REPLACE VIEW mart_recommendation_final_v1 AS

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

    r.provisional_recommendation_score AS affinity_playability_score,

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
                ELSE (q.quality_percentile - 50.0) * 0.10
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
    ON q.GameKey = r.GameKey;