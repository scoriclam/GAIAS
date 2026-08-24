import os

import requests
from dotenv import load_dotenv


load_dotenv()

client_id = os.getenv("IGDB_CLIENT_ID")
client_secret = os.getenv("IGDB_CLIENT_SECRET")

if not client_id or not client_secret:
    raise RuntimeError("Missing IGDB credentials in .env")


SEARCH_TITLE = "The Witcher 3: Wild Hunt"
SEARCH_PLATFORM = "PlayStation 5"


token_response = requests.post(
    "https://id.twitch.tv/oauth2/token",
    params={
        "client_id": client_id,
        "client_secret": client_secret,
        "grant_type": "client_credentials",
    },
    timeout=30,
)

token_response.raise_for_status()
access_token = token_response.json()["access_token"]


headers = {
    "Client-ID": client_id,
    "Authorization": f"Bearer {access_token}",
}


query = f"""
fields
    id,
    name,
    first_release_date,
    genres.name,
    themes.name,
    game_modes.name,
    player_perspectives.name,
    platforms.name;
search "{SEARCH_TITLE}";
limit 10;
"""


response = requests.post(
    "https://api.igdb.com/v4/games",
    headers=headers,
    data=query,
    timeout=30,
)

response.raise_for_status()
games = response.json()


platform_matches = []

for game in games:
    platform_names = [
        platform["name"]
        for platform in game.get("platforms", [])
    ]

    if SEARCH_PLATFORM in platform_names:
        platform_matches.append(game)


exact_matches = [
    game
    for game in platform_matches
    if game.get("name", "").casefold() == SEARCH_TITLE.casefold()
]


print(f"Search title: {SEARCH_TITLE}")
print(f"Search platform: {SEARCH_PLATFORM}")
print(f"IGDB results: {len(games)}")
print(f"Platform matches: {len(platform_matches)}")
print(f"Exact title + platform matches: {len(exact_matches)}")
print()


if len(exact_matches) == 1:
    match = exact_matches[0]

    print("MATCH STATUS: MATCHED")
    print(f"IGDB ID: {match['id']}")
    print(f"IGDB Name: {match['name']}")

elif len(exact_matches) > 1:
    print("MATCH STATUS: AMBIGUOUS")

    for match in exact_matches:
        print(match)

else:
    print("MATCH STATUS: NO EXACT MATCH")