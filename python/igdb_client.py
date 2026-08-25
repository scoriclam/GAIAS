import os
import time

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

        # Keep requests comfortably below IGDB's rate limit.
        self.minimum_request_interval = 0.30
        self.last_request_time = 0.0

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

    def _throttle(self):
        elapsed = time.monotonic() - self.last_request_time

        if elapsed < self.minimum_request_interval:
            time.sleep(
                self.minimum_request_interval - elapsed
            )

    def query_games(self, query, max_retries=5):
        headers = {
            "Client-ID": self.client_id,
            "Authorization": f"Bearer {self.access_token}",
        }

        for attempt in range(max_retries):
            self._throttle()

            response = requests.post(
                "https://api.igdb.com/v4/games",
                headers=headers,
                data=query,
                timeout=30,
            )

            self.last_request_time = time.monotonic()

            if response.status_code != 429:
                response.raise_for_status()
                return response.json()

            retry_after = response.headers.get(
                "Retry-After"
            )

            if retry_after:
                wait_seconds = float(retry_after)
            else:
                wait_seconds = 2 ** attempt

            print(
                "IGDB rate limit reached. "
                f"Waiting {wait_seconds:.1f} seconds..."
            )

            time.sleep(wait_seconds)

        raise RuntimeError(
            "IGDB rate limit persisted after "
            f"{max_retries} retries."
        )

    def search_game(self, title, limit=25):
        safe_title = title.replace('"', '\\"')

        query = f"""
        fields
            id,
            name,
            first_release_date,
            category,
            genres.name,
            themes.name,
            game_modes.name,
            player_perspectives.name,
            platforms.name;
        search "{safe_title}";
        limit {limit};
        """

        return self.query_games(query)

    def exact_name_game(self, title, limit=50):
        safe_title = title.replace('"', '\\"')

        query = f"""
        fields
            id,
            name,
            first_release_date,
            category,
            genres.name,
            themes.name,
            game_modes.name,
            player_perspectives.name,
            platforms.name;
        where name = "{safe_title}";
        limit {limit};
        """

        return self.query_games(query)