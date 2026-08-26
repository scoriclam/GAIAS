SELECT
    RepresentativePSNName,
    NormalizedGameName,
    EntitlementCount,
    PlatformCount,
    HasPS4,
    HasPS5,
    HasPSPlusEntitlement

FROM std_psn_unmatched_titles

ORDER BY
    RepresentativePSNName;