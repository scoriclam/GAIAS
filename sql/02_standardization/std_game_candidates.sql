CREATE VIEW std_game_candidates AS SELECT game_title, max(igdb_id) AS igdb_id, max(opencritic_id) AS opencritic_id FROM std_inventory_game_ready GROUP BY game_title;
