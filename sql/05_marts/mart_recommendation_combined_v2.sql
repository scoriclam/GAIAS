CREATE OR REPLACE VIEW mart_recommendation_combined_v2 AS

WITH base AS (
    SELECT
        t.GameKey,
        t.GameID,
        t.GameTitle,
        t.PlayStatusName,
        t.taste_affinity_score,
        t.taste_affinity_status,

        ca.conditional_affinity_percentile,

        p.ControlSchemeRisk,
        p.RhythmFlag,
        p.SHMUPFlag,
        p.SoulslikeFlag,
        p.MitigationAvailable,
        p.playability_adjustment,
        p.playability_status,
        p.hard_exclusion_flag,
        p.exclusion_reason,

        CASE
            WHEN p.SoulslikeFlag = TRUE
              OR p.SHMUPFlag = TRUE
              OR p.ControlSchemeRisk IN ('Moderate', 'High')
                THEN TRUE
            ELSE FALSE
        END AS conditional_path_relevant,

        CASE
            WHEN (
                p.SoulslikeFlag = TRUE
                OR p.SHMUPFlag = TRUE
                OR p.ControlSchemeRisk IN ('Moderate', 'High')
            )
            AND p.MitigationAvailable = TRUE
            AND ca.conditional_affinity_percentile IS NOT NULL
            AND t.taste_affinity_score IS NOT NULL
                THEN TRUE
            ELSE FALSE
        END AS conditional_path_active

    FROM mart_taste_affinity_v1 AS t

    LEFT JOIN mart_playability_v1 AS p
        ON p.GameKey = t.GameKey

    LEFT JOIN vw_conditional_affinity_normalized AS ca
        ON ca.GameKey = t.GameKey
),

scored AS (
    SELECT
        *,

        CASE
            WHEN hard_exclusion_flag = TRUE
                THEN NULL

            WHEN taste_affinity_score IS NULL
                THEN NULL

            WHEN conditional_path_active = TRUE
                THEN ROUND(
                    taste_affinity_score
                    +
                    LEAST(
                        10.0,
                        GREATEST(
                            0.0,
                            (
                                conditional_affinity_percentile
                                - taste_affinity_score
                            ) * 0.25
                        )
                    ),
                    2
                )

            ELSE taste_affinity_score
        END AS selected_affinity_score,

        CASE
            WHEN hard_exclusion_flag = TRUE
                THEN 'Excluded'

            WHEN taste_affinity_score IS NULL
                THEN 'Insufficient Metadata'

            WHEN conditional_path_active = TRUE
                THEN 'Conditional Affinity'

            ELSE 'Normal Affinity'
        END AS affinity_path

    FROM base
)

SELECT
    GameKey,
    GameID,
    GameTitle,
    PlayStatusName,
    taste_affinity_score,
    taste_affinity_status,
    conditional_affinity_percentile,
    ControlSchemeRisk,
    RhythmFlag,
    SHMUPFlag,
    SoulslikeFlag,
    MitigationAvailable,
    playability_adjustment,
    playability_status,
    hard_exclusion_flag,
    exclusion_reason,
    conditional_path_relevant,
    selected_affinity_score,
    affinity_path,

    CASE
        WHEN hard_exclusion_flag = TRUE
            THEN NULL

        WHEN selected_affinity_score IS NULL
            THEN NULL

        ELSE ROUND(
            selected_affinity_score
            + COALESCE(playability_adjustment, 0),
            2
        )
    END AS provisional_recommendation_score

FROM scored;