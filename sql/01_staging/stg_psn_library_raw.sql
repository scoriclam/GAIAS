CREATE TABLE IF NOT EXISTS stg_psn_library_raw (
    EntitlementID VARCHAR NOT NULL,
    ProductID VARCHAR,
    TitleID VARCHAR,
    ConceptID VARCHAR,
    GameName VARCHAR NOT NULL,
    Platform VARCHAR,
    Membership VARCHAR,
    IsActive BOOLEAN,
    IsDownloadable BOOLEAN,
    IsPreOrder BOOLEAN,
    ImageURL VARCHAR,
    RawPayload JSON,
    FetchedAt TIMESTAMP NOT NULL
);