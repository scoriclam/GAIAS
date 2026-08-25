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

-- ============================================================
-- Priority 2 enrichment reviews
-- ============================================================

,(44, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Virtual reality content is optional rather than required; aerial combat demands sustained spatial control, while standard controller play and difficulty options provide mitigation.')

,(51, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Primarily exploration, puzzle-solving, and simple adventure gameplay with limited reflex demand and straightforward combat.')

,(94, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Fast real-time action combat requires dodging, aiming, and timing; selectable difficulty provides mitigation.')

,(95, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Fast-paced third-person action-RPG combat requires dodging, aiming, and character switching; selectable difficulty provides mitigation.')

,(117, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional third-person action-RPG controls with selectable difficulty and no identified special playability-risk category.')

,(205, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Twin-stick action combat and frequent simultaneous movement and aiming create coordination demand; adjustable difficulty and progression provide mitigation.')

,(216, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Straightforward third-person action-adventure with simple combat and forgiving progression; no major playability-risk category identified.')

,(251, FALSE, 'High', FALSE, FALSE, FALSE, FALSE,
 'Legacy third-person combat and movement are comparatively stiff and timing-sensitive, with limited modern assistance and no strong mitigation identified.')

,(295, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Real-time action-RPG combat relies on dodging, stance and weapon management, and timing; selectable difficulty and progression provide mitigation.')

,(391, FALSE, 'Moderate', FALSE, FALSE, TRUE, TRUE,
 'Souls-like action combat is deliberate and timing-based, but selectable difficulty provides meaningful mitigation.')

,(413, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Virtual reality is optional rather than required; painting, traversal, and motion-oriented interaction create some control burden, while standard non-VR play provides mitigation.')

,(508, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Turn-based RPG structure keeps reflex demand low; difficulty and progression systems provide mitigation.')

,(524, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person shooting requires sustained aiming and movement coordination; character builds, gear progression, cooperative play, and easier activities provide mitigation.')

,(542, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Turn-based combat minimizes reflex demand; difficulty selection, grinding, party building, and progression provide strong mitigation.')

,(549, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Turn-based tactical structure minimizes reflex demand; extensive grinding, overleveling, and progression provide strong difficulty mitigation.')

,(567, FALSE, 'Moderate', FALSE, FALSE, TRUE, TRUE,
 'Souls-like combat emphasizes stamina, dodging, positioning, and resource management; ranged builds, progression, and equipment optimization provide mitigation.')

,(616, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional action-adventure controls with adjustable difficulty and comfort options; no major playability-risk category identified.')

,(632, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Virtual reality is optional rather than required; space-flight combat requires continuous aiming and movement coordination, while difficulty and configuration options provide mitigation.')

,(651, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Straightforward third-person action-platforming with simple combat and forgiving structure; no major playability-risk category identified.')

,(677, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Third-person shooting and vehicle sections create coordination burden; controller configuration and improved sensitivity behavior provide mitigation.')

,(698, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Third-person shooting and telekinetic combat can become visually and mechanically busy; aiming assistance and difficulty options provide mitigation.')

,(712, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person shooting and traversal require sustained aiming and movement; selectable difficulty, stealth, progression, and companion options provide mitigation.')

,(715, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person shooting and chaotic combat require sustained aiming and movement; difficulty settings, companions, stealth, and progression provide mitigation.')

,(734, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Fast real-time combat, character switching, targeting, and camera management add coordination burden; difficulty settings and party flexibility provide mitigation.')

,(750, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Real-time brawler combat can become hectic and combo-heavy; difficulty settings, healing items, upgrades, and progression provide mitigation.')

,(792, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person combat and survival systems create coordination burden; easier difficulty, cooperative play, and accessibility options provide strong mitigation.')

,(793, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person combat, ship management, resource systems, and procedural survival create layered coordination burden; progression and difficulty tuning provide mitigation.')

,(813, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Fast real-time hunting combat requires camera, dodge, guard, and weapon-form coordination; AI companions and progression provide mitigation.')

,(839, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Fast action-RPG combat can be demanding; assist modes, difficulty options, remapping, and practice features provide strong mitigation.')

,(994, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Real-time brawler combat and chase or action sequences add coordination demand; difficulty settings, healing, upgrades, and combat assistance provide mitigation.')

,(1035, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional third-person action-RPG controls with multiple difficulty settings and flexible character builds.')

,(1079, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Accessible action-adventure structure with simple combat, forgiving checkpoints, character abilities, and optional co-op.')

,(1085, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Simple, forgiving action-adventure controls with optional co-op and low failure pressure; no major control-risk category identified.')

,(1123, FALSE, 'Moderate', FALSE, FALSE, TRUE, TRUE,
 'Souls-like combat emphasizes stamina, dodging, blocking, and deliberate timing; co-op, builds, progression, and ranged or magic options provide mitigation.')

,(1219, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Side-view shooter and platformer, but not a SHMUP under GAIAS rules; standard controls and easier difficulty reduce burden.')

,(1335, FALSE, 'Moderate', FALSE, FALSE, TRUE, TRUE,
 'Souls-like stamina and stance-based combat is demanding and timing-heavy; summons, co-op, gear progression, and build optimization provide mitigation.')

,(1336, FALSE, 'Moderate', FALSE, FALSE, TRUE, TRUE,
 'Highly demanding Souls-like combat with stance, ki, dodge, block, and Yokai systems; co-op, summons, gear progression, and builds provide mitigation.')

,(1560, TRUE, 'Moderate', FALSE, FALSE, FALSE, FALSE,
 'Wii edition requires Wii Remote and Nunchuk motion-oriented controls; special accessory requirement triggers hard exclusion under current GAIAS rules.')

,(1565, FALSE, 'High', FALSE, FALSE, FALSE, TRUE,
 'Fixed camera angles and legacy-style movement create substantial control burden; alternate modern movement and easier difficulty provide mitigation.')

,(1572, FALSE, 'High', FALSE, FALSE, FALSE, FALSE,
 'Legacy tank-style movement, fixed camera angles, and limited aiming flexibility create substantial control burden with little built-in mitigation.')

,(1627, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional action-RPG and life-sim controls; easier difficulty, companions, crafting, and overleveling provide substantial mitigation.')

,(1684, FALSE, 'Moderate', FALSE, FALSE, FALSE, FALSE,
 'Isometric stealth and action RPG combines layered movement, stealth, combat, and traversal systems; no strong difficulty-reduction mechanism identified.')

,(1719, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Investigation-focused structure with conventional movement and camera controls; combat can be de-emphasized and assistance options reduce pressure.')

,(1781, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'High-speed traversal and reaction-based combat create coordination demand; selectable difficulty and assistance settings provide mitigation.')

,(1823, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Fast action-RPG combat and aerial movement add coordination burden; difficulty options and AI-controlled party support provide mitigation.')

,(1922, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Third-person shooting creates aiming burden, but built-in targeting assistance, RPG progression, AI support, and easier difficulty provide mitigation.')

,(1954, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Real-time party RPG combat is comparatively conventional; difficulty settings and AI-controlled party members provide mitigation.')

,(2040, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person survival, combat, and resource management add burden; Peaceful mode and optional cooperative play provide strong mitigation.')

,(2054, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Low-pressure exploration and puzzle structure with minimal reflex demand; no identified major playability-risk category.')

,(2060, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Third-person stealth and combat require aiming, movement, and resource management; lower difficulty, forgiving checkpoints, and stealth provide mitigation.')

,(2063, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Turn-based combat substantially reduces reflex demand; timing-based attacks add some input burden, but repetition and progression provide mitigation.')

,(2130, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Real-time action-RPG combat uses stance switching, dodging, blocking, and companion management; easier difficulty and progression provide mitigation.')

,(2265, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Turn-based tactical structure greatly reduces reflex demand; deliberate unit control, replayable content, and squad progression provide mitigation.')

,(2276, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Very fast third-person shooting, boosting, and precision aiming create substantial coordination demand; easier difficulty and aim assistance provide mitigation.')

,(2361, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Fast retro-style first-person combat demands sustained aiming, movement, and enemy tracking; multiple difficulty settings provide mitigation.')

,(2403, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Fast action combat and boss encounters require movement and reaction timing; difficulty selection provides meaningful mitigation.')

,(2404, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Fast real-time action combat uses dodging, guarding, character switching, and timing; selectable difficulty provides substantial mitigation.')

-- ============================================================
-- Priority 1 enrichment reviews - cycle 2
-- ============================================================

,(28, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Peaceful exploration-focused structure with minimal combat and reflex pressure; sensitivity and axis options provide limited control mitigation.')

,(49, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Turn-based combat and exploration keep reflex demand low; progression and party management provide mitigation.')

,(111, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Turn-based RPG structure keeps motor and reflex burden low; difficulty and progression systems provide mitigation.')

,(129, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional Assassin''s Creed movement, stealth, combat, and sailing; upgrades, ranged tools, stealth, and alternate approaches provide mitigation.')

,(134, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional Assassin''s Creed movement, stealth, and combat with no identified major control-risk category; upgrades and alternate approaches provide mitigation.')

,(136, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Same underlying game and control model as the duplicate Black Flag entry; no major control-risk category identified.')

,(202, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Freeflow combat, counters, gadgets, traversal, and predator encounters create coordination demand; difficulty settings and tactical approaches provide mitigation.')

,(245, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Twin-stick movement and aiming, aerial navigation, and combat create coordination demand; progression, upgrades, and adjustable challenge provide mitigation.')

,(302, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person zero-gravity movement, survival systems, and resource management create coordination and navigation burden; difficulty and progression systems provide mitigation.')

,(366, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Third-person action combat relies on dodging, blocking, weapon switching, and boss timing; selectable difficulty provides mitigation.')

,(369, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Simple action-RPG combat with forgiving controls, lightweight progression, and optional co-op; no major control-risk category identified.')

,(411, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Survival combat, crafting, inventory management, and environmental systems create layered burden; difficulty and server settings plus co-op provide strong mitigation.')

,(470, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional action-RPG controls with pause-driven inventory systems; weapon growth, leveling, items, and preparation provide mitigation.')

,(471, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional action-RPG combat with pause-driven menus, character switching, weapons, items, and extensive progression; grinding and equipment upgrades provide mitigation.')

,(496, FALSE, 'Moderate', FALSE, FALSE, FALSE, FALSE,
 'Retains legacy-era movement, inventory pressure, survivor management, and timer-driven structure; no strong built-in mitigation identified.')

,(599, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Turn-based JRPG combat keeps reflex demand low; difficulty settings, party building, and progression provide mitigation.')

,(624, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Large-scale real-time combat can become visually and mechanically busy, but difficulty settings, character progression, and straightforward crowd-combat systems provide mitigation.')

,(676, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Relaxed farming and exploration structure with simple controls and little sustained reflex pressure; no major playability-risk category identified.')

,(710, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person aiming and combat create sustained coordination demand; easier difficulty, stealth, upgrades, and conventional controls provide mitigation.')

,(711, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person shooting and traversal require sustained aiming and movement; easier difficulty, stealth, progression, and weapon upgrades provide mitigation.')

,(716, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'First-person combat, aiming, traversal, and animal-command systems create coordination demand; difficulty settings, stealth, companions, and progression provide mitigation.')

,(724, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Fast action combat, dodging, character switching, and boss timing create coordination burden; selectable difficulty and progression provide mitigation.')

,(886, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Relaxed exploration and relationship-focused structure with relatively simple combat; difficulty options and co-op support provide mitigation.')

,(1025, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Naval combat requires steering, positioning, speed management, broadside timing, and skill use; selectable difficulty and controller-focused design provide mitigation.')

,(1066, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Low-pressure narrative and driving structure with minimal combat or reflex demand; no major playability-risk category identified.')

,(1080, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Forgiving LEGO action-adventure controls with simple combat, frequent checkpoints, character abilities, and optional co-op.')

,(1082, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Forgiving LEGO action-adventure structure with simple combat, exploration, frequent checkpoints, and low failure pressure.')

,(1134, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Real-time movement and aiming combine with card-driven tactical combat; difficulty and progression systems provide mitigation.')

,(1138, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Puzzle-platforming emphasizes deliberate movement and environmental reasoning rather than combat or rapid reflexes; no major playability-risk category identified.')

,(1185, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Third-person shooting, powers, movement, and squad management create coordination demand; multiple difficulty settings, aim assistance, builds, and squad support provide mitigation.')

,(1234, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Deliberate action combat requires camera management, positioning, weapon-specific inputs, and monster-pattern learning; equipment, preparation, and multiplayer provide mitigation.')

,(1237, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Turn-based combat keeps reflex demand low; party building, monster selection, equipment, and progression provide substantial mitigation.')

,(1240, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Complex real-time hunting combat requires camera control, positioning, weapon mastery, dodging, and monster-pattern recognition; gear progression, preparation, SOS multiplayer, and build flexibility provide mitigation.')

,(1293, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Racing and pursuit sequences require sustained steering and reaction input; driving assists, progression, and vehicle upgrades provide mitigation.')

,(1456, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Third-person action combines movement, aiming, territory-clearing, and combat under pressure; difficulty and progression systems provide mitigation.')

,(1551, FALSE, 'Moderate', FALSE, FALSE, TRUE, TRUE,
 'Souls-like combat combines dodging, stamina management, ranged aiming, and punishing encounters; co-op, builds, gear progression, and difficulty selection provide mitigation.')

,(1592, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'High-speed sports and trick inputs can demand coordination, but auto-landing, multiple control presets, remapping, backtrack, adjustable difficulty, and Zen mode provide strong mitigation.')

,(1609, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional action-RPG controls with pause-driven support systems; leveling, equipment, items, and party management provide mitigation.')

,(1722, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Investigation-focused adventure with conventional movement and limited reflex pressure; action sequences are secondary and generally forgiving.')

,(1955, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional real-time party RPG combat with AI-controlled allies; difficulty settings and progression provide mitigation without creating a major control-risk concern.')

,(1985, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Traversal and combat require camera coordination and quick reactions; difficulty settings and automated web-swing systems reduce burden.')

,(2008, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'High-speed driving, flying, and boating require sustained coordination, but assist settings, forgiving progression, and vehicle tuning provide mitigation.')

,(2031, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Third-person survival-horror combat and resource pressure create aiming and reaction demands; easier difficulty and assistance options provide mitigation.')

,(2058, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Turn-based command structure minimizes reflex demand; party composition, formations, progression, and tactical planning provide mitigation.')

,(2122, FALSE, 'Moderate', FALSE, FALSE, TRUE, TRUE,
 'Souls-like combat emphasizes stamina, dodging, blocking, positioning, and targeted limb attacks; gear progression, implants, and build optimization provide mitigation.')

,(2123, FALSE, 'Moderate', FALSE, FALSE, TRUE, TRUE,
 'Souls-like combat emphasizes directional parrying, stamina, dodging, positioning, and limb targeting; builds, gear progression, implants, and online support systems provide mitigation.')

,(2181, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Turn-based JRPG structure keeps reflex demand low; music-themed presentation does not make it rhythm-focused. Difficulty selection and party progression provide mitigation.')

,(2183, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Tactical third-person shooting, aiming, stealth, and inventory systems create moderate burden; difficulty customization, accessibility options, AI teammates, and co-op provide strong mitigation.')

,(2402, FALSE, 'Moderate', FALSE, FALSE, FALSE, TRUE,
 'Fast real-time action combat, dodging, guarding, character switching, and traversal abilities create coordination demand; difficulty settings provide mitigation.')

,(2427, FALSE, 'None', FALSE, FALSE, FALSE, TRUE,
 'Conventional action-adventure controls with some brush-based precision demands; combat, exploration, upgrades, and forgiving progression provide mitigation.')

ON CONFLICT (GameID) DO UPDATE SET
    SpecialAccessoryRequired = EXCLUDED.SpecialAccessoryRequired,
    ControlSchemeRisk = EXCLUDED.ControlSchemeRisk,
    RhythmFlag = EXCLUDED.RhythmFlag,
    SHMUPFlag = EXCLUDED.SHMUPFlag,
    SoulslikeFlag = EXCLUDED.SoulslikeFlag,
    MitigationAvailable = EXCLUDED.MitigationAvailable,
    PlayabilityNotes = EXCLUDED.PlayabilityNotes;