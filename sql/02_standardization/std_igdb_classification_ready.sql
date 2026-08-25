CREATE OR REPLACE VIEW std_igdb_classification_ready AS
WITH latest_success AS (
    SELECT
        GAIASGameID,
        SearchPlatform,
        GenresRaw,
        ThemesRaw,
        GameModesRaw,
        PlayerPerspectivesRaw,
        FetchedAt,
        ROW_NUMBER() OVER (
            PARTITION BY GAIASGameID, SearchPlatform
            ORDER BY FetchedAt DESC
        ) AS row_num
    FROM stg_igdb_game_raw
    WHERE FetchStatus IN (
        'MATCHED',
        'MATCHED_OVERRIDE',
        'MATCHED_BACKCOMPAT',
        'MATCHED_VIRTUAL_CONSOLE'
    )
),

igdb_values AS (
    SELECT
        GAIASGameID,
        SearchPlatform,
        'Genre' AS ClassificationType,
        trim(value::VARCHAR, '"') AS IGDBValue
    FROM latest_success,
         json_each(GenresRaw)
    WHERE row_num = 1

    UNION ALL

    SELECT
        GAIASGameID,
        SearchPlatform,
        'Theme',
        trim(value::VARCHAR, '"')
    FROM latest_success,
         json_each(ThemesRaw)
    WHERE row_num = 1

    UNION ALL

    SELECT
        GAIASGameID,
        SearchPlatform,
        'Mode',
        trim(value::VARCHAR, '"')
    FROM latest_success,
         json_each(GameModesRaw)
    WHERE row_num = 1

    UNION ALL

    SELECT
        GAIASGameID,
        SearchPlatform,
        'Perspective',
        trim(value::VARCHAR, '"')
    FROM latest_success,
         json_each(PlayerPerspectivesRaw)
    WHERE row_num = 1
),

mapped_values AS (
    SELECT
        iv.GAIASGameID,
        iv.SearchPlatform,
        iv.ClassificationType,
        iv.IGDBValue,
        CASE
            WHEN iv.ClassificationType = 'Perspective'
             AND iv.IGDBValue = 'Bird view / Isometric'
                THEN 'Bird view/Isometric'
            ELSE iv.IGDBValue
        END AS ProposedGAIASValue
    FROM igdb_values iv
)

SELECT
    mv.GAIASGameID,
    g.GameTitle,
    mv.SearchPlatform,
    mv.ClassificationType,
    mv.IGDBValue,
    gc.ClassificationValue AS GAIASValue,
    gc.GameClassificationID,
    CASE
        WHEN gc.GameClassificationID IS NOT NULL
            THEN 'READY'
        ELSE 'UNMAPPED'
    END AS MappingStatus
FROM mapped_values mv
JOIN Game g
    ON g.GameID = mv.GAIASGameID
LEFT JOIN GameClassification gc
    ON gc.ClassificationType = mv.ClassificationType
   AND lower(gc.ClassificationValue)
       = lower(mv.ProposedGAIASValue);