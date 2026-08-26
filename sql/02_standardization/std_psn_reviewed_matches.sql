CREATE OR REPLACE VIEW std_psn_reviewed_matches AS

WITH reviewed_matches AS (
    SELECT *
    FROM (
        VALUES
            (
                'Alone in the Dark: The New Nightmare (2001)',
                78,
                'APPROVED',
                'Year suffix only'
            ),
            (
                'DOOM',
                580,
                'APPROVED',
                'Confirmed as Doom (2016); classic Doom titles are represented separately'
            ),
            (
                'Rogue Legacy PS4™',
                1610,
                'APPROVED',
                'Platform suffix only'
            ),
            (
                'Baldur''s Gate and Baldur''s Gate II: Enhanced Edition',
                189,
                'APPROVED',
                'Punctuation variation'
            ),
            (
                'Planescape: Torment and Icewind Dale: Enhanced Editions',
                1449,
                'APPROVED',
                'Capitalization and punctuation variation'
            ),
            (
                'Broken Sword - Shadow of the Templars: Reforged',
                306,
                'APPROVED',
                'Minor title wording variation'
            ),
            (
                'Momodora: Reverie Under the Moonlight',
                1230,
                'APPROVED',
                'GAIAS spelling correction required'
            ),
            (
                'Hard West Ultimate Edition',
                877,
                'APPROVED',
                'Punctuation and GAIAS spelling variation'
            ),
            (
                'Death end re;Quest2',
                509,
                'APPROVED',
                'Spacing and punctuation variation'
            ),
            (
                'ZONE OF THE ENDERS THE 2nd RUNNER : M∀RS',
                2422,
                'APPROVED',
                'Typography variation'
            ),
            (
                'The Bard''s Tale IV: Directors Cut',
                1990,
                'APPROVED',
                'Apostrophe variation'
            ),
            (
                'Amnesia: Rebirth',
                87,
                'APPROVED',
                'GAIAS spelling correction required'
            ),
            (
                'TimeSplitters 2',
                2168,
                'APPROVED',
                'Spacing variation'
            ),
            (
                'RESIDENT EVIL5',
                1561,
                'APPROVED',
                'Spacing and capitalization variation'
            ),
            (
                'InertialDrift',
                957,
                'APPROVED',
                'Spacing variation'
            ),
            (
                'TimeSplitters',
                2167,
                'APPROVED',
                'Spacing variation'
            ),
            (
                'GODS EATER BURST',
                813,
                'APPROVED',
                'Singular/plural title variation'
            ),
            (
                'GhostSong',
                797,
                'APPROVED',
                'Spacing variation'
            ),
            (
                'God of War Ragnarök',
                820,
                'APPROVED',
                'Diacritic variation'
            ),
            (
                'Crysis2® Remastered',
                447,
                'APPROVED',
                'Spacing and trademark variation'
            ),
            (
                'Crysis3® Remastered',
                448,
                'APPROVED',
                'Spacing and trademark variation'
            ),
            (
                'Stalker: Shadow of Chornobyl',
                1637,
                'APPROVED',
                'Alternate transliteration'
            ),
            (
                'Eiyuden Chronicle: Rising',
                653,
                'APPROVED',
                'Minor pluralization variation'
            ),
            (
                'Dakar18',
                464,
                'APPROVED',
                'Spacing variation'
            ),
            (
                'Assassin''s Creed® III Remastered',
                128,
                'APPROVED',
                'Roman/Arabic numeral variation'
            ),
            (
                'Call of Duty® Modern Warfare 3',
                334,
                'APPROVED',
                'Roman/Arabic numeral variation'
            ),
            (
                'AmongtheSleep',
                90,
                'APPROVED',
                'Spacing variation'
            ),
            (
                'The Bluecoats - North & South',
                1995,
                'APPROVED',
                'Ampersand versus word variation'
            ),
            (
                'METAL GEAR SOLID V: THE DEFINITIVE EXPERIENCE',
                1204,
                'APPROVED',
                'Capitalization and punctuation variation'
            ),
            (
                'RAGE2',
                1502,
                'APPROVED',
                'Spacing variation'
            ),
            (
                'Regalia: Of Men and Monarchs - Royal Edition',
                1548,
                'APPROVED',
                'Edition wording variation'
            ),
            (
                'Andro Dunos 2',
                93,
                'APPROVED',
                'Arabic/Roman numeral variation'
            ),
            (
                'Red Faction Guerrilla Re-Mars-tered',
                1542,
                'APPROVED',
                'GAIAS spelling variation'
            ),
            (
                'HELLDIVERS™ 2',
                895,
                'APPROVED',
                'Arabic/Roman numeral variation'
            ),
            (
                'TORCHLIGHT 2',
                2199,
                'APPROVED',
                'Arabic/Roman numeral variation'
            )
    ) AS v (
        PSNGameName,
        GameID,
        MatchDecision,
        ReviewReason
    )
)

SELECT
    PSNGameName,

    TRIM(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                LOWER(PSNGameName),
                '[™®©]',
                '',
                'g'
            ),
            '[^a-z0-9]+',
            ' ',
            'g'
        )
    ) AS NormalizedGameName,

    GameID,
    MatchDecision,
    ReviewReason

FROM reviewed_matches;