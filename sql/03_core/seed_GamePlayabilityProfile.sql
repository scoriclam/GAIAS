-- Authoritative seed/upsert for GamePlayabilityProfile.
--
-- Purpose:
--   1. Preserve the 44 pre-existing manually curated playability profiles.
--   2. Add the 56 Priority 1 playability reviews completed during
--      recommendation-engine revalidation.
--   3. Make GamePlayabilityProfile reproducible and safe to rerun.
--
-- ControlSchemeRisk vocabulary:
--   None
--   Moderate
--   High
--
-- "None" means no identified control-scheme risk under the current
-- GAIAS playability rules. It does not mean the game is universally easy.
--
-- Review signals such as IGDB Virtual Reality, Music, or Side-View Shooter
-- are used only to prioritize manual review. They do not automatically
-- determine playability-profile values.

INSERT INTO GamePlayabilityProfile (
    GameID,
    SpecialAccessoryRequired,
    ControlSchemeRisk,
    RhythmFlag,
    SHMUPFlag,
    SoulslikeFlag,
    MitigationAvailable,
    PlayabilityNotes
)
VALUES

-- ============================================================
-- Existing manually curated profiles
-- ============================================================

(200,  FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(234,  FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(317,  FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(320,  FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(481,  FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(489,  FALSE, 'None', FALSE, FALSE, TRUE, TRUE,
 'Conditional A-tier: substantially more playable with mitigation.'),

(602,  FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(704,  FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(707,  FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(731,  FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(829,  FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(912,  FALSE, 'None', FALSE, FALSE, TRUE, TRUE,
 'Conditional A-tier: strong preference fit when difficulty is mitigated.'),

(979,  FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(980,  FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(982,  FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(1155, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(1204, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(1208, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(1220, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(1221, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(1290, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(1314, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(1387, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(1501, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(1542, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(1559, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'Resident Evil 4 is a high-A example with acceptable modern controls.'),

(1596, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(1648, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(1956, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(2022, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(2079, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(2080, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'Legacy controls and camera conventions, but no identified severe control barrier.'),

(2081, TRUE, 'None', FALSE, FALSE, FALSE, FALSE,
 'Wii version requires Wii MotionPlus-compatible motion controls and Nunchuk; special accessory requirement triggers hard exclusion.'),

(2100, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(2116, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(2189, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(2311, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(2373, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(2379, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(2380, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(2381, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(2382, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(2383, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

(2384, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'No identified major playability risk under current GAIAS rules.'),

-- ============================================================
-- Priority 1 enrichment reviews
-- ============================================================

(62, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Standard third-person action controls; generous aiming assistance and broad difficulty options provide strong mitigation.'),

(92, FALSE, 'High', FALSE, FALSE, FALSE, TRUE,
 'Complex contextual controls, timing cues, and intentionally limited guidance create substantial control and learning burden; tutorial and interface assistance provide partial mitigation.'),

(127, FALSE, 'Moderate', FALSE, FALSE, TRUE, TRUE,
 'Souls-like stamina-based combat and punishing encounters create elevated playability risk; AI or human companion support provides mitigation.'),

(128, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Standard action-adventure controls with no identified accessory, rhythm, SHMUP, Souls-like, or major control-scheme concern.'),

(135, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional Assassin''s Creed movement and combat with no identified major playability-risk category.'),

(138, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Familiar Assassin''s Creed controls and systems with no identified major playability-risk category.'),

(143, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional Assassin''s Creed controls; stealth, ranged tools, upgrades, and alternate approaches can reduce combat pressure.'),

(145, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Parkour, stealth, combat, and dense crowd navigation require added coordination; upgrades, stealth, ranged tools, and co-op provide mitigation.'),

(201, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Freeflow combat, traversal, Batmobile driving, and gadget use require coordination; difficulty options and alternate approaches provide mitigation.'),

(204, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Freeflow combat, gadgets, traversal, and predator encounters require coordination; difficulty settings and tactical approaches provide mitigation.'),

(240, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person combat combines shooting, powers, weapon switching, and environmental threats; easier difficulty and save systems provide mitigation.'),

(291, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional first-person shooter controls; local or online co-op provides meaningful combat mitigation.'),

(292, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional first-person shooter controls; optional local or online co-op provides meaningful combat mitigation.'),

(479, FALSE, 'Moderate', FALSE, FALSE, TRUE, TRUE,
 'Souls-influenced dodge and timing combat creates elevated playability risk; multiple difficulty levels provide mitigation.'),

(494, FALSE, 'Moderate', FALSE, FALSE, FALSE, FALSE,
 'Legacy controls and persistent time pressure create additional playability burden; no strong built-in mitigation identified for this version.'),

(495, FALSE, 'Moderate', FALSE, FALSE, FALSE, FALSE,
 'Legacy-era controls, inventory management, survivor management, and persistent time pressure create added burden; no strong built-in mitigation identified.'),

(497, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'More forgiving controls and reduced time-pressure emphasis than earlier Dead Rising entries; adjustable difficulty provides mitigation.'),

(531, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person stealth and action involve layered systems and aiming demands; easier difficulty and multiple noncombat approaches provide mitigation.'),

(532, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person stealth and action involve layered systems and aiming demands; multiple difficulty levels, stealth, hacking, and alternate routes provide strong mitigation.'),

(585, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Standard controller layout; adjustable difficulty provides meaningful combat mitigation.'),

(620, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person parkour and melee combat create coordination and reaction demands; adjustable difficulty and assistance options provide mitigation.'),

(621, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person parkour and melee combat require added coordination; difficulty options and optional co-op provide meaningful mitigation.'),

(629, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Combat can be demanding, especially early, but easier difficulty settings, adjustable combat parameters, and companions provide mitigation.'),

(659, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Virtual reality is supported but not required; complex flight controls create moderate control burden, while standard controller play and configurable controls provide mitigation.'),

(680, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Low-pressure exploratory structure with minimal reaction-time demand; automatic continuation provides additional mitigation.'),

(700, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Survival systems and timing-based melee increase playability burden; difficulty, companion, and progression systems provide mitigation.'),

(706, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Real-time combat, inventory management, and online survival systems add burden; V.A.T.S., builds, progression, and co-op provide mitigation.'),

(739, FALSE, 'None', FALSE, FALSE, FALSE, FALSE,
 'Turn-based combat minimizes reflex and control burden; no conventional difficulty setting identified for this release.'),

(861, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Relaxed exploration and life-sim structure with low combat pressure and no identified special control risk.'),

(999, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Standard open-world action controls; alternate preparation and progression approaches can reduce mission pressure.'),

(1000, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional third-person open-world controls with no identified major control-risk category.'),

(1058, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Investigation-focused structure has relatively limited reflex demand; driving assistance and action-sequence skipping provide mitigation.'),

(1153, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional third-person shooting and driving controls; easier difficulty, aim assistance, and driving assists provide mitigation.'),

(1154, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional third-person action controls with multiple combat approaches and no identified major control-risk category.'),

(1186, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional third-person RPG and shooter controls; multiple difficulty levels provide strong mitigation.'),

(1254, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Directional melee and mounted combat require coordination and practice; extensive difficulty settings substantially reduce challenge.'),

(1269, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Generally low-pressure crafting and life-sim structure with conventional controls; combat is not the dominant difficulty driver.'),

(1291, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Racing requires sustained steering and reaction input; easier difficulty and driving-assistance settings provide strong mitigation.'),

(1294, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Racing controls can feel sensitive and require sustained coordination; alternate Wii U control approaches provide some mitigation.'),

(1313, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional action-RPG controls; adjustable difficulty provides meaningful combat mitigation.'),

(1372, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Standard third-person open-world action controls; selectable difficulty provides meaningful combat mitigation.'),

(1517, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional action-platformer controls; easier difficulty provides strong combat mitigation.'),

(1599, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Action-RPG combat can be demanding, but easier difficulty provides meaningful mitigation.'),

(1629, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Top-down action combat uses stamina, blocking, aiming, and dodge timing; easier difficulty and aiming assistance provide mitigation.'),

(1636, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Older survival-FPS structure adds resource and combat burden; adjustable difficulty, manual saving, and control assistance provide mitigation.'),

(1637, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Older survival-FPS structure adds resource and combat burden; adjustable difficulty, manual saving, and control assistance provide mitigation.'),

(1646, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Standard open-world action controls; adjustable difficulty provides meaningful mitigation.'),

(1716, FALSE, 'High', FALSE, FALSE, FALSE, FALSE,
 'Legacy movement and camera controls are notably awkward, and QTE or timing-sensitive sequences add substantial control burden with little built-in mitigation.'),

(1717, FALSE, 'High', FALSE, FALSE, FALSE, FALSE,
 'Legacy movement and camera controls remain awkward, with numerous QTE and timing-sensitive sequences and little built-in mitigation.'),

(1720, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Investigation-focused adventure with conventional movement and camera controls and limited reflex demand.'),

(1763, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Precision aiming and stealth can require fine motor control; difficulty and aim-assistance options substantially reduce the burden.'),

(1984, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Traversal and combat require camera coordination and quick reactions; difficulty settings and automated web-swing assistance reduce burden.'),

(2184, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional third-person tactical-shooter controls; easier difficulty and squad or tactical options provide substantial mitigation.'),

(2188, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional third-person shooter controls; mission difficulty and cooperative play provide meaningful mitigation.'),

(2299, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Simple combat inputs are offset by legacy movement and lock-on behavior; multiple difficulty levels provide mitigation.'),

(2385, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Real-time brawler combat can become hectic and combo-heavy; difficulty settings, healing items, equipment, and progression provide mitigation.')

ON CONFLICT (GameID) DO UPDATE SET
    SpecialAccessoryRequired = EXCLUDED.SpecialAccessoryRequired,
    ControlSchemeRisk = EXCLUDED.ControlSchemeRisk,
    RhythmFlag = EXCLUDED.RhythmFlag,
    SHMUPFlag = EXCLUDED.SHMUPFlag,
    SoulslikeFlag = EXCLUDED.SoulslikeFlag,
    MitigationAvailable = EXCLUDED.MitigationAvailable,
    PlayabilityNotes = EXCLUDED.PlayabilityNotes;