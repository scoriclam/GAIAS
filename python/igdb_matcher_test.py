from igdb_matcher import IGDBMatcher


matcher = IGDBMatcher()

result = matcher.match_game(
    "Live A Live",
    "WIIU",
    gaias_game_id=1117,
    acquisition_source="ROM",
)

print(f"Status: {result['status']}")
print(f"Title: {result['title']}")
print(f"Platform: {result['platform']}")

if result["match"]:
    print(f"IGDB ID: {result['match']['id']}")
    print(f"IGDB Name: {result['match']['name']}")