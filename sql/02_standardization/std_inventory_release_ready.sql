CREATE OR REPLACE VIEW std_inventory_release_ready AS

SELECT
    * EXCLUDE (release_date),

    CASE
        WHEN platform_name = 'PS5'
         AND release_date < DATE '2020-11-12'
            THEN NULL

        ELSE release_date
    END AS release_date

FROM std_inventory_curated;