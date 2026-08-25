import csv
import re
import unicodedata

from igdb_client import IGDBClient


PLATFORM_NAME_MAP = {
    "PS4": "PlayStation 4",
    "PS5": "PlayStation 5",
    "WIIU": "Wii U",
}

BACKWARD_COMPATIBLE_PLATFORM_MAP = {
    "WIIU": ["Wii"],
}

VIRTUAL_CONSOLE_PLATFORM_MAP = {
    "WIIU": [
        "Nintendo Entertainment System",
        "Super Nintendo Entertainment System",
        "Nintendo 64",
        "Game Boy Advance",
        "Family Computer",
        "Family Computer Disk System",
        "Super Famicom",
    ],
}

OVERRIDE_FILE = "config/igdb_match_overrides.csv"


def normalize_title(title):
    normalized = title.casefold().strip()

    # Remove diacritics.
    # Example: "Pokémon" becomes "Pokemon".
    normalized = "".join(
        character
        for character in unicodedata.normalize("NFKD", normalized)
        if not unicodedata.combining(character)
    )

    # Remove selected leading brand prefixes.
    normalized = re.sub(
        r"^(disney|dreamworks)\s+",
        "",
        normalized,
    )

    # Remove trailing alias annotations.
    normalized = re.sub(
        r"\s*\(aka [^)]+\)\s*$",
        "",
        normalized,
    )

    # Treat ampersands as the word "and".
    normalized = normalized.replace("&", " and ")

    # Treat punctuation between digits as formatting rather than meaning.
    # Example: "1.000" becomes "1000".
    normalized = re.sub(
        r"(?<=\d)\.(?=\d)",
        "",
        normalized,
    )

    normalized = re.sub(
        r"[^a-z0-9]+",
        " ",
        normalized,
    )

    normalized = re.sub(
        r"\s+",
        " ",
        normalized,
    )

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

    def _platform_title_matches(
        self,
        games,
        title,
        allowed_platforms,
    ):
        normalized_title = normalize_title(title)

        matches = []

        for game in games:
            platform_names = [
                platform["name"]
                for platform in game.get("platforms", [])
            ]

            platform_matches = any(
                allowed_platform in platform_names
                for allowed_platform in allowed_platforms
            )

            title_matches = (
                normalize_title(game.get("name", ""))
                == normalized_title
            )

            if platform_matches and title_matches:
                matches.append(game)

        return matches

    def _resolve_games(
        self,
        games,
        title,
        platform_code,
        acquisition_source,
    ):
        igdb_platform = PLATFORM_NAME_MAP[platform_code]

        native_matches = self._platform_title_matches(
            games,
            title,
            [igdb_platform],
        )

        if len(native_matches) == 1:
            return {
                "status": "MATCHED",
                "title": title,
                "platform": platform_code,
                "match": native_matches[0],
                "candidates": native_matches,
            }

        if len(native_matches) > 1:
            return {
                "status": "AMBIGUOUS",
                "title": title,
                "platform": platform_code,
                "match": None,
                "candidates": native_matches,
            }

        backward_platforms = (
            BACKWARD_COMPATIBLE_PLATFORM_MAP.get(
                platform_code,
                [],
            )
        )

        backward_matches = self._platform_title_matches(
            games,
            title,
            backward_platforms,
        )

        if len(backward_matches) == 1:
            return {
                "status": "MATCHED_BACKCOMPAT",
                "title": title,
                "platform": platform_code,
                "match": backward_matches[0],
                "candidates": backward_matches,
            }

        if len(backward_matches) > 1:
            return {
                "status": "AMBIGUOUS",
                "title": title,
                "platform": platform_code,
                "match": None,
                "candidates": backward_matches,
            }

        virtual_console_platforms = (
            VIRTUAL_CONSOLE_PLATFORM_MAP.get(
                platform_code,
                [],
            )
        )

        if (
            platform_code == "WIIU"
            and acquisition_source == "ROM"
            and virtual_console_platforms
        ):
            virtual_console_matches = (
                self._platform_title_matches(
                    games,
                    title,
                    virtual_console_platforms,
                )
            )

            if len(virtual_console_matches) == 1:
                return {
                    "status": "MATCHED_VIRTUAL_CONSOLE",
                    "title": title,
                    "platform": platform_code,
                    "match": virtual_console_matches[0],
                    "candidates": virtual_console_matches,
                }

            if len(virtual_console_matches) > 1:
                return {
                    "status": "AMBIGUOUS",
                    "title": title,
                    "platform": platform_code,
                    "match": None,
                    "candidates": virtual_console_matches,
                }

        return None

    def match_game(
        self,
        title,
        platform_code,
        gaias_game_id=None,
        acquisition_source=None,
    ):
        platform_code = platform_code.upper()

        if acquisition_source:
            acquisition_source = acquisition_source.upper()

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

        if platform_code not in PLATFORM_NAME_MAP:
            return {
                "status": "UNSUPPORTED_PLATFORM",
                "title": title,
                "platform": platform_code,
                "match": None,
                "candidates": [],
            }

        search_title = build_search_title(title)

        # First attempt: normal IGDB search.
        games = self.client.search_game(search_title)

        result = self._resolve_games(
            games,
            title,
            platform_code,
            acquisition_source,
        )

        if result is not None:
            return result

        # Second attempt: exact-name lookup.
        exact_games = self.client.exact_name_game(
            search_title
        )

        result = self._resolve_games(
            exact_games,
            title,
            platform_code,
            acquisition_source,
        )

        if result is not None:
            return result

        return {
            "status": "NO_EXACT_MATCH",
            "title": title,
            "platform": platform_code,
            "match": None,
            "candidates": games,
        }