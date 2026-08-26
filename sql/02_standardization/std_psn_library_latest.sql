CREATE OR REPLACE VIEW std_psn_library_latest AS

WITH latest_snapshot AS (
    SELECT MAX(FetchedAt) AS FetchedAt
    FROM stg_psn_library_raw
)

SELECT
    psn.EntitlementID,
    psn.ProductID,
    psn.TitleID,
    psn.ConceptID,
    psn.GameName,
    psn.Platform,
    psn.Membership,
    psn.IsActive,
    psn.IsDownloadable,
    psn.IsPreOrder,
    psn.ImageURL,
    psn.FetchedAt

FROM stg_psn_library_raw AS psn

JOIN latest_snapshot AS latest
    ON latest.FetchedAt = psn.FetchedAt;