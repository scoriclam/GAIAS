from igdb_matcher import IGDBMatcher
from igdb_stage_writer import write_match_to_staging


GAIAS_GAME_ID = 2148
SEARCH_TITLE = "The Witcher 3: Wild Hunt Complete Edition"
SEARCH_PLATFORM = "PS5"


matcher = IGDBMatcher()

result = matcher.match_game(
    SEARCH_TITLE,
    SEARCH_PLATFORM,
)

write_match_to_staging(
    gaias_game_id=GAIAS_GAME_ID,
    search_title=SEARCH_TITLE,
    search_platform=SEARCH_PLATFORM,
    match_result=result,
)

print("Staging write completed")