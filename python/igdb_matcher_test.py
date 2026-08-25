from datetime import datetime, timezone

from igdb_client import IGDBClient


client = IGDBClient()

query = """
fields
    id,
    name,
    first_release_date,
    release_dates.date,
    release_dates.region,
    release_dates.platform.name;
where id = (
    1101,
    342602
);
limit 10;
"""

games = client.query_games(query)


for game in games:
    print("=" * 80)
    print(f"IGDB ID: {game['id']}")
    print(f"Name: {game['name']}")
    print()

    for release in game.get("release_dates", []):
        platform = release.get("platform", {}).get(
            "name",
            "Unknown",
        )

        if platform != "Wii U":
            continue

        timestamp = release.get("date")

        if timestamp:
            release_date = datetime.fromtimestamp(
                timestamp,
                tz=timezone.utc,
            ).date()
        else:
            release_date = None

        print(f"Wii U Release Date: {release_date}")
        print(f"IGDB Region Code: {release.get('region')}")
        print("-" * 60)