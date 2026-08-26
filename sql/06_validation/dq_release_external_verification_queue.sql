CREATE OR REPLACE VIEW dq_release_external_verification_queue AS

SELECT
    ge.GameEditionID,
    g.GameID,
    g.GameTitle,
    p.PlatformName,
    g.IGDBID,
    rs.ReleaseStatus,
    rs.StatusReason,
    rs.StatusSource,
    rs.LastReviewedAt

FROM GameEditionReleaseStatus rs

JOIN GameEdition ge
    ON ge.GameEditionID = rs.GameEditionID

JOIN Game g
    ON g.GameID = ge.GameID

JOIN Platform p
    ON p.PlatformID = ge.PlatformID

WHERE rs.ReleaseStatus = 'Needs External Verification'
  AND ge.ReleaseDate IS NULL

ORDER BY
    p.PlatformName,
    g.GameTitle;