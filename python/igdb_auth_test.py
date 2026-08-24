import os

import requests
from dotenv import load_dotenv


load_dotenv()

client_id = os.getenv("IGDB_CLIENT_ID")
client_secret = os.getenv("IGDB_CLIENT_SECRET")

if not client_id or not client_secret:
    raise RuntimeError("Missing IGDB credentials in .env")

response = requests.post(
    "https://id.twitch.tv/oauth2/token",
    params={
        "client_id": client_id,
        "client_secret": client_secret,
        "grant_type": "client_credentials",
    },
    timeout=30,
)

response.raise_for_status()

token_data = response.json()

print("Authentication successful")
print(f"Token type: {token_data.get('token_type')}")
print(f"Expires in: {token_data.get('expires_in')} seconds")