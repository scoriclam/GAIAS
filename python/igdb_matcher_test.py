from igdb_matcher import IGDBMatcher


TEST_CASES = [
    (607, "DreamWorks How to Train Your Dragon 2", "WIIU"),
    (637, "EarthBound (aka Mother 2)", "WIIU"),
    (638, "EarthBound Beginnings (aka Mother)", "WIIU"),
]


matcher = IGDBMatcher()


for game_id, title, platform in TEST_CASES:
    result = matcher.match_game(
        title,
        platform,
        gaias_game_id=game_id,
    )

    print("=" * 80)
    print(f"GAIAS GameID: {game_id}")
    print(f"Title: {title}")
    print(f"Platform: {platform}")
    print(f"Status: {result['status']}")

    if result["match"]:
        print(f"IGDB ID: {result['match']['id']}")
        print(f"IGDB Name: {result['match']['name']}")