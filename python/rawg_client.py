import os
import time

import requests
from dotenv import load_dotenv


class RAWGClient:
    BASE_URL = "https://api.rawg.io/api"

    def __init__(self):
        load_dotenv(".env")

        self.api_key = os.getenv("RAWG_API_KEY")

        if not self.api_key:
            raise RuntimeError(
                "Missing RAWG_API_KEY in .env"
            )

        self.minimum_request_interval = 0.25
        self.last_request_time = 0.0

    def _throttle(self):
        elapsed = time.monotonic() - self.last_request_time

        if elapsed < self.minimum_request_interval:
            time.sleep(
                self.minimum_request_interval - elapsed
            )

    def _get(self, endpoint, params=None):
        if params is None:
            params = {}

        params = {
            **params,
            "key": self.api_key,
        }

        self._throttle()

        response = requests.get(
            f"{self.BASE_URL}/{endpoint}",
            params=params,
            timeout=30,
        )

        self.last_request_time = time.monotonic()

        response.raise_for_status()

        return response.json()

    def search_games(
        self,
        title,
        platform_id=None,
        page_size=20,
    ):
        params = {
            "search": title,
            "page_size": page_size,
        }

        if platform_id is not None:
            params["platforms"] = platform_id

        data = self._get(
            "games",
            params=params,
        )

        return data.get("results", [])

    def get_game(self, rawg_id):
        return self._get(
            f"games/{int(rawg_id)}"
        )
