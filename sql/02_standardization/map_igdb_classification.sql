CREATE OR REPLACE VIEW map_igdb_classification AS
SELECT
    ClassificationType,
    IGDBValue,
    GAIASValue
FROM read_csv_auto(
    'config/igdb_classification_map.csv',
    HEADER = TRUE
);