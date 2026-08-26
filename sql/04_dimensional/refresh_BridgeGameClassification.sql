BEGIN TRANSACTION;

DELETE FROM BridgeGameClassification;

INSERT INTO BridgeGameClassification (
    GameKey,
    ClassificationKey
)
SELECT DISTINCT
    dg.GameKey,
    dc.ClassificationKey
FROM GameClassificationBridge AS gcb

JOIN DimGame AS dg
    ON dg.GameID = gcb.GameID

JOIN DimClassification AS dc
    ON dc.GameClassificationID =
       gcb.GameClassificationID;

COMMIT;