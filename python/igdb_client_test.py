from igdb_client import IGDBClient


client = IGDBClient()

games = client.search_game("The Witcher 3: Wild Hunt")

print(f"Matches returned: {len(games)}")

for game in games:
    print(game["id"], game["name"])