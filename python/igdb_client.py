import os

import requests
from dotenv import load_dotenv


class IGDBClient:
    def __init__(self):
        load_dotenv()

        self.client_id = os.getenv("IGDB_CLIENT_ID")
        self.client_secret = os.getenv("IGDB_CLIENT_SECRET")

        if not self.client_id or not self.client_secret:
            raise RuntimeError("Missing IGDB credentials in .env")

        self.access_token = self._get_access_token()

    def _get_access_token(self):
        response = requests.post(
            "https://id.twitch.tv/oauth2/token",
            params={
                "client_id": self.client_id,
                "client_secret": self.client_secret,
                "grant_type": "client_credentials",
            },
            timeout=30,
        )

        response.raise_for_status()

        return response.json()["access_token"]

    def query_games(self, query):
        headers = {
            "Client-ID": self.client_id,
            "Authorization": f"Bearer {self.access_token}",
        }

        response = requests.post(
            "https://api.igdb.com/v4/games",
            headers=headers,
            data=query,
            timeout=30,
        )

        response.raise_for_status()

        return response.json()

    def search_game(self, title, limit=25):
        safe_title = title.replace('"', '\\"')

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
        search "{safe_title}";
        limit {limit};
        """

        return self.query_games(query)