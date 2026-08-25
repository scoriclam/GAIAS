CREATE OR REPLACE VIEW mart_playability_v1 AS

WITH rule_weights AS (
    SELECT
        MAX(
            CASE
                WHEN RuleValue = 'Tank Controls'
                THEN RuleWeight
                ELSE NULL
            END
        ) AS control_penalty,

        MAX(
            CASE
                WHEN RuleValue = 'SHMUP'
                THEN RuleWeight
                ELSE NULL
            END
        ) AS shmup_penalty,

        MAX(
            CASE
                WHEN RuleValue = 'Souls-like'
                THEN RuleWeight
                ELSE NULL
            END
        ) AS soulslike_penalty,

        MAX(
            CASE
                WHEN RuleValue = 'Difficulty Mitigation'
                THEN RuleWeight
                ELSE NULL
            END
        ) AS mitigation_bonus

    FROM PreferenceRule
),

scored AS (
    SELECT
        dg.GameKey,
        dg.GameID,
        dg.GameTitle,

        COALESCE(
            gpp.SpecialAccessoryRequired,
            FALSE
        ) AS SpecialAccessoryRequired,

        COALESCE(
            gpp.ControlSchemeRisk,
            'Unknown'
        ) AS ControlSchemeRisk,

        COALESCE(
            gpp.RhythmFlag,
            FALSE
        ) AS RhythmFlag,

        COALESCE(
            gpp.SHMUPFlag,
            FALSE
        ) AS SHMUPFlag,

        COALESCE(
            gpp.SoulslikeFlag,
            FALSE
        ) AS SoulslikeFlag,

        COALESCE(
            gpp.MitigationAvailable,
            FALSE
        ) AS MitigationAvailable,

        gpp.PlayabilityNotes,

        CASE
            WHEN gpp.SpecialAccessoryRequired = TRUE
                THEN TRUE
            WHEN gpp.RhythmFlag = TRUE
                THEN TRUE
            ELSE FALSE
        END AS hard_exclusion_flag,

        CASE
            WHEN gpp.SpecialAccessoryRequired = TRUE
                THEN 'Special accessory required'
            WHEN gpp.RhythmFlag = TRUE
                THEN 'Rhythm-focused gameplay'
            ELSE NULL
        END AS exclusion_reason,

        (
            CASE
                WHEN gpp.ControlSchemeRisk = 'High'
                    THEN COALESCE(rw.control_penalty, 0)
                ELSE 0
            END
            +
            CASE
                WHEN gpp.SHMUPFlag = TRUE
                    THEN COALESCE(rw.shmup_penalty, 0)
                ELSE 0
            END
            +
            CASE
                WHEN gpp.SoulslikeFlag = TRUE
                    THEN COALESCE(rw.soulslike_penalty, 0)
                ELSE 0
            END
        ) AS raw_playability_penalty,

        CASE
            WHEN gpp.GameID IS NULL
                THEN 'Unknown'

            WHEN gpp.SpecialAccessoryRequired = TRUE
              OR gpp.RhythmFlag = TRUE
                THEN 'Excluded'

            WHEN gpp.ControlSchemeRisk = 'High'
              OR gpp.SHMUPFlag = TRUE
              OR gpp.SoulslikeFlag = TRUE
                THEN
                    CASE
                        WHEN gpp.MitigationAvailable = TRUE
                            THEN 'Playable With Mitigation'
                        ELSE 'High Risk'
                    END

            WHEN gpp.ControlSchemeRisk = 'Moderate'
                THEN
                    CASE
                        WHEN gpp.MitigationAvailable = TRUE
                            THEN 'Playable With Mitigation'
                        ELSE 'Moderate Risk'
                    END

            ELSE 'Playable'
        END AS playability_status,

        rw.mitigation_bonus

    FROM DimGame AS dg

    LEFT JOIN GamePlayabilityProfile AS gpp
        ON gpp.GameID = dg.GameID

    CROSS JOIN rule_weights AS rw
)

SELECT
    GameKey,
    GameID,
    GameTitle,
    SpecialAccessoryRequired,
    ControlSchemeRisk,
    RhythmFlag,
    SHMUPFlag,
    SoulslikeFlag,
    MitigationAvailable,
    PlayabilityNotes,
    hard_exclusion_flag,
    exclusion_reason,

    CASE
        WHEN raw_playability_penalty < 0
         AND MitigationAvailable = TRUE
            THEN LEAST(
                0,
                raw_playability_penalty + COALESCE(mitigation_bonus, 0)
            )

        ELSE raw_playability_penalty
    END AS playability_adjustment,

    playability_status

FROM scored;