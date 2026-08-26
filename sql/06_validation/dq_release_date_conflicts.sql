CREATE OR REPLACE VIEW dq_release_date_conflicts AS

SELECT
    game_title,
    platform_name,
    release_date AS source_release_date,
    'BEFORE_PS5_LAUNCH' AS issue_type

FROM std_inventory_curated

WHERE platform_name = 'PS5'
  AND release_date < DATE '2020-11-12';