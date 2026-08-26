INSERT INTO DimClassification (
    ClassificationKey,
    GameClassificationID,
    ClassificationType,
    ClassificationValue,
    ClassificationDescription
)
SELECT
    COALESCE(
        (
            SELECT MAX(ClassificationKey)
            FROM DimClassification
        ),
        0
    )
    + ROW_NUMBER() OVER (
        ORDER BY gc.GameClassificationID
    ) AS ClassificationKey,
    gc.GameClassificationID,
    gc.ClassificationType,
    gc.ClassificationValue,
    gc.ClassificationDescription
FROM GameClassification AS gc

LEFT JOIN DimClassification AS dc
    ON dc.GameClassificationID =
       gc.GameClassificationID

WHERE dc.GameClassificationID IS NULL;