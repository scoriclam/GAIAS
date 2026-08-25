UPDATE GameEdition ge
SET ReleaseDate = src.IGDBReleaseDate
FROM std_igdb_release_ready src
WHERE ge.GameEditionID = src.GameEditionID
  AND src.IGDBReleaseDate IS NOT NULL
  AND (
      src.ReleaseDateStatus = 'READY_TO_FILL'
      OR (
          src.PlatformName = 'PS5'
          AND src.ReleaseDateStatus = 'CONFLICT'
      )
  );