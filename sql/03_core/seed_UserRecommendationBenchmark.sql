CREATE TABLE IF NOT EXISTS UserRecommendationBenchmark (
    GameID INTEGER PRIMARY KEY,
    BenchmarkTier VARCHAR NOT NULL,
    BenchmarkReason VARCHAR
);

INSERT INTO UserRecommendationBenchmark (
    GameID,
    BenchmarkTier,
    BenchmarkReason
)
VALUES
    (
        1539,
        'S',
        'Established personal benchmark title'
    ),
    (
        2078,
        'S',
        'Established personal benchmark title'
    ),
    (
        2148,
        'S',
        'Established personal benchmark title'
    )
ON CONFLICT (GameID) DO UPDATE SET
    BenchmarkTier = EXCLUDED.BenchmarkTier,
    BenchmarkReason = EXCLUDED.BenchmarkReason;