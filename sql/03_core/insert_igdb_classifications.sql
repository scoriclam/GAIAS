INSERT INTO GameClassificationBridge (
    GameID,
    GameClassificationID
)
SELECT DISTINCT
    r.GAIASGameID,
    r.GameClassificationID
FROM std_igdb_classification_ready r
LEFT JOIN GameClassificationBridge gcb
    ON gcb.GameID = r.GAIASGameID
   AND gcb.GameClassificationID = r.GameClassificationID
WHERE r.MappingStatus = 'READY'
  AND gcb.GameID IS NULL;