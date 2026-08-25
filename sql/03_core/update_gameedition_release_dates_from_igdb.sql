UPDATE GameEdition ge
SET ReleaseDate = src.IGDBReleaseDate
FROM std_igdb_release_ready src
WHERE ge.GameEditionID = src.GameEditionID
  AND src.ReleaseDateStatus = 'READY_TO_FILL';