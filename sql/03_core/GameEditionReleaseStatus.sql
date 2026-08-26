CREATE TABLE IF NOT EXISTS GameEditionReleaseStatus (
    GameEditionID INTEGER PRIMARY KEY,
    ReleaseStatus VARCHAR NOT NULL,
    StatusReason VARCHAR,
    StatusSource VARCHAR,
    LastReviewedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (GameEditionID)
        REFERENCES GameEdition(GameEditionID),

    CHECK (
        ReleaseStatus IN (
            'Released',
            'Announced / TBA',
            'Not Applicable - Cloud Streaming',
            'Platform Mismatch',
            'Edition Mismatch',
            'Needs External Verification',
            'Unresolved'
        )
    )
);