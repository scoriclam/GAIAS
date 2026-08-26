UPDATE GameEdition ge
SET ReleaseDate = src.IGDBReleaseDate
FROM std_igdb_release_ready src
WHERE ge.GameEditionID = src.GameEditionID
  AND src.IGDBReleaseDate IS NOT NULL
  AND src.ReleaseDateStatus IN (
      'READY_TO_FILL',
      'READY_TO_REPAIR_INVALID_PS5'
  );