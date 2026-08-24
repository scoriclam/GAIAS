import csv
import re

from igdb_client import IGDBClient


PLATFORM_NAME_MAP = {
    "PS4": "PlayStation 4",
    "PS5": "PlayStation 5",
    "WIIU": "Wii U",
}

BACKWARD_COMPATIBLE_PLATFORM_MAP = {
    "WIIU": ["Wii"],
}

OVERRIDE_FILE = "config/igdb_match_overrides.csv"


def normalize_title(title):
    normalized = title.casefold().strip()

    # Remove selected leading brand prefixes.
    normalized = re.sub(r"^(disney|dreamworks)\s+", "", normalized)

    # Remove trailing alias annotations.
    # Example:
    # "EarthBound (aka Mother 2)" becomes "EarthBound"
    normalized = re.sub(r"\s*\(aka [^)]+\)\s*$", "", normalized)

    # Treat ampersands as the word "and".
    normalized = normalized.replace("&", " and ")

    # Treat punctuation between digits as formatting rather than meaning.
    # Example: "1.000" becomes "1000".
    normalized = re.sub(r"(?<=\d)\.(?=\d)", "", normalized)

    normalized = re.sub(r"[^a-z0-9]+", " ", normalized)
    normalized = re.sub(r"\s+", " ", normalized)

    return normalized.strip()

def build_search_title(title):
    search_title = title.strip()

    # Remove selected leading brand prefixes.
    search_title = re.sub(
        r"^(Disney|DreamWorks)\s+",
        "",
        search_title,
        flags=re.IGNORECASE,
    )

    # Remove trailing alias annotations.
    search_title = re.sub(
        r"\s*\(aka [^)]+\)\s*$",
        "",
        search_title,
        flags=re.IGNORECASE,
    )

    return search_title.strip()

def load_overrides():
    overrides = {}

    with open(
        OVERRIDE_FILE,
        mode="r",
        encoding="utf-8",
        newline="",
    ) as file:
        reader = csv.DictReader(file)

        for row in reader:
            key = (
                int(row["GAIASGameID"]),
                row["PlatformCode"].upper(),
            )

            overrides[key] = {
                "IGDBID": int(row["IGDBID"]),
                "IGDBName": row["IGDBName"],
                "OverrideReason": row["OverrideReason"],
            }

    return overrides


class IGDBMatcher:
    def __init__(self):
        self.client = IGDBClient()
        self.overrides = load_overrides()

    def match_game(
        self,
        title,
        platform_code,
        gaias_game_id=None,
    ):
        platform_code = platform_code.upper()

        if gaias_game_id is not None:
            override_key = (
                gaias_game_id,
                platform_code,
            )

            override = self.overrides.get(override_key)

            if override:
                return {
                    "status": "MATCHED_OVERRIDE",
                    "title": title,
                    "platform": platform_code,
                    "match": {
                        "id": override["IGDBID"],
                        "name": override["IGDBName"],
                    },
                    "candidates": [],
                    "override_reason": override["OverrideReason"],
                }

        igdb_platform = PLATFORM_NAME_MAP.get(platform_code)

        if not igdb_platform:
            return {
                "status": "UNSUPPORTED_PLATFORM",
                "title": title,
                "platform": platform_code,
                "match": None,
                "candidates": [],
            }

        search_title = build_search_title(title)
        games = self.client.search_game(search_title)

        normalized_search_title = normalize_title(title)

        # First preference: native platform match.
        native_platform_matches = []

        for game in games:
            platform_names = [
                platform["name"]
                for platform in game.get("platforms", [])
            ]

            if igdb_platform in platform_names:
                native_platform_matches.append(game)

        native_title_matches = [
            game
            for game in native_platform_matches
            if normalize_title(game.get("name", ""))
            == normalized_search_title
        ]

        if len(native_title_matches) == 1:
            return {
                "status": "MATCHED",
                "title": title,
                "platform": platform_code,
                "match": native_title_matches[0],
                "candidates": native_platform_matches,
            }

        if len(native_title_matches) > 1:
            return {
                "status": "AMBIGUOUS",
                "title": title,
                "platform": platform_code,
                "match": None,
                "candidates": native_title_matches,
            }

        # Second preference: approved backward-compatible platform.
        fallback_platforms = BACKWARD_COMPATIBLE_PLATFORM_MAP.get(
            platform_code,
            [],
        )

        backward_compatible_matches = []

        for game in games:
            platform_names = [
                platform["name"]
                for platform in game.get("platforms", [])
            ]

            has_fallback_platform = any(
                fallback_platform in platform_names
                for fallback_platform in fallback_platforms
            )

            title_matches = (
                normalize_title(game.get("name", ""))
                == normalized_search_title
            )

            if has_fallback_platform and title_matches:
                backward_compatible_matches.append(game)

        if len(backward_compatible_matches) == 1:
            return {
                "status": "MATCHED_BACKCOMPAT",
                "title": title,
                "platform": platform_code,
                "match": backward_compatible_matches[0],
                "candidates": backward_compatible_matches,
            }

        if len(backward_compatible_matches) > 1:
            return {
                "status": "AMBIGUOUS",
                "title": title,
                "platform": platform_code,
                "match": None,
                "candidates": backward_compatible_matches,
            }

        return {
            "status": "NO_EXACT_MATCH",
            "title": title,
            "platform": platform_code,
            "match": None,
            "candidates": native_platform_matches,
        }