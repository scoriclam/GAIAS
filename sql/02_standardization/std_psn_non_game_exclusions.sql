CREATE OR REPLACE VIEW std_psn_non_game_exclusions AS

SELECT *
FROM (
    VALUES
        (
            'amazon prime video',
            'NON_GAME_APPLICATION',
            'Streaming application'
        ),
        (
            'crackle free movies and tv',
            'NON_GAME_APPLICATION',
            'Streaming application'
        ),
        (
            'dazn',
            'NON_GAME_APPLICATION',
            'Streaming application'
        ),
        (
            'hbo max',
            'NON_GAME_APPLICATION',
            'Streaming application'
        ),
        (
            'hulu',
            'NON_GAME_APPLICATION',
            'Streaming application'
        ),
        (
            'netflix',
            'NON_GAME_APPLICATION',
            'Streaming application'
        ),
        (
            'peacocktv',
            'NON_GAME_APPLICATION',
            'Streaming application'
        ),
        (
            'ufc fight pass',
            'NON_GAME_APPLICATION',
            'Streaming application'
        ),
        (
            'watchespn',
            'NON_GAME_APPLICATION',
            'Streaming application'
        ),
        (
            'wwe network',
            'NON_GAME_APPLICATION',
            'Streaming application'
        ),
        (
            'youtube',
            'NON_GAME_APPLICATION',
            'Streaming application'
        )
) AS exclusions (
    NormalizedGameName,
    ExclusionCategory,
    ExclusionReason
);