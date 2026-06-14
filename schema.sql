-- ============================================================================
-- FIGHTING GAME PLATFORM - Complete Database Schema
-- University Project: Matchmaking Engine & Player Analytics
-- ============================================================================

-- ============================================================================
-- 1. DROP ALL
-- ============================================================================
DROP VIEW IF EXISTS view_player_stats;
DROP VIEW IF EXISTS view_top_players;
DROP VIEW IF EXISTS view_leaderboard;
DROP TABLE IF EXISTS Match_History;
DROP TABLE IF EXISTS Matches;
DROP TABLE IF EXISTS Player_Powers;
DROP TABLE IF EXISTS Powers;
DROP TABLE IF EXISTS Player_Inventory;
DROP TABLE IF EXISTS Items;
DROP TABLE IF EXISTS Player_Rankings;
DROP TABLE IF EXISTS Seasons;
DROP TABLE IF EXISTS Players;

-- ============================================================================
-- 2. CREATE TABLES
-- ============================================================================

CREATE TABLE Players (
    player_id       SERIAL PRIMARY KEY,
    username        VARCHAR(50) NOT NULL UNIQUE,
    skill_rating_mmr INTEGER NOT NULL DEFAULT 1000,
    player_level    INTEGER NOT NULL DEFAULT 1,
    region          VARCHAR(10) NOT NULL,
    wins            INTEGER NOT NULL DEFAULT 0,
    losses          INTEGER NOT NULL DEFAULT 0,
    account_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_mmr_positive CHECK (skill_rating_mmr >= 0),
    CONSTRAINT chk_level_positive CHECK (player_level >= 1),
    CONSTRAINT chk_region CHECK (region IN ('NA', 'EU', 'ASIA', 'SA', 'OCE'))
);

CREATE TABLE Seasons (
    season_id       SERIAL PRIMARY KEY,
    season_name     VARCHAR(50) NOT NULL UNIQUE,
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    is_active       BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_dates CHECK (end_date > start_date)
);

CREATE TABLE Player_Rankings (
    player_id       INTEGER NOT NULL,
    season_id       INTEGER NOT NULL,
    rank_tier       VARCHAR(20) NOT NULL DEFAULT 'Bronze',
    ranking_points  INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (player_id, season_id),
    CONSTRAINT fk_rank_player FOREIGN KEY (player_id) REFERENCES Players(player_id) ON DELETE CASCADE,
    CONSTRAINT fk_rank_season FOREIGN KEY (season_id) REFERENCES Seasons(season_id) ON DELETE CASCADE,
    CONSTRAINT chk_tier CHECK (rank_tier IN ('Bronze','Silver','Gold','Platinum','Diamond','Master','Grandmaster'))
);

CREATE TABLE Items (
    item_id         SERIAL PRIMARY KEY,
    item_name       VARCHAR(50) NOT NULL UNIQUE,
    rarity          VARCHAR(15) NOT NULL DEFAULT 'Common',
    buy_price       INTEGER NOT NULL DEFAULT 0,
    stat_boost      INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT chk_rarity CHECK (rarity IN ('Common','Uncommon','Rare','Epic','Legendary'))
);

CREATE TABLE Player_Inventory (
    player_id       INTEGER NOT NULL,
    item_id         INTEGER NOT NULL,
    quantity        INTEGER NOT NULL DEFAULT 1,
    is_equipped     BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (player_id, item_id),
    CONSTRAINT fk_inv_player FOREIGN KEY (player_id) REFERENCES Players(player_id) ON DELETE CASCADE,
    CONSTRAINT fk_inv_item FOREIGN KEY (item_id) REFERENCES Items(item_id) ON DELETE CASCADE
);

CREATE TABLE Powers (
    power_id        SERIAL PRIMARY KEY,
    power_name      VARCHAR(50) NOT NULL UNIQUE,
    power_type      VARCHAR(20) NOT NULL,
    damage          INTEGER NOT NULL DEFAULT 0,
    cooldown_sec    DECIMAL(5,2) NOT NULL DEFAULT 1.0,
    rarity          VARCHAR(15) NOT NULL DEFAULT 'Common',
    CONSTRAINT chk_power_type CHECK (power_type IN ('Attack','Defense','Heal','Buff','Ultimate')),
    CONSTRAINT chk_pow_rarity CHECK (rarity IN ('Common','Uncommon','Rare','Epic','Legendary'))
);

CREATE TABLE Player_Powers (
    player_id       INTEGER NOT NULL,
    power_id        INTEGER NOT NULL,
    power_level     INTEGER NOT NULL DEFAULT 1,
    is_equipped     BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (player_id, power_id),
    CONSTRAINT fk_pp_player FOREIGN KEY (player_id) REFERENCES Players(player_id) ON DELETE CASCADE,
    CONSTRAINT fk_pp_power FOREIGN KEY (power_id) REFERENCES Powers(power_id) ON DELETE CASCADE
);

CREATE TABLE Matches (
    match_id        SERIAL PRIMARY KEY,
    match_type      VARCHAR(15) NOT NULL DEFAULT 'Ranked',
    match_duration  INTEGER,
    match_date      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_match_type CHECK (match_type IN ('Ranked','Casual','Tournament'))
);

CREATE TABLE Match_History (
    match_id        INTEGER NOT NULL,
    player_id       INTEGER NOT NULL,
    kills           INTEGER NOT NULL DEFAULT 0,
    deaths          INTEGER NOT NULL DEFAULT 0,
    assists         INTEGER NOT NULL DEFAULT 0,
    damage_dealt    INTEGER NOT NULL DEFAULT 0,
    match_outcome   VARCHAR(4) NOT NULL,
    PRIMARY KEY (match_id, player_id),
    CONSTRAINT fk_mh_match FOREIGN KEY (match_id) REFERENCES Matches(match_id) ON DELETE CASCADE,
    CONSTRAINT fk_mh_player FOREIGN KEY (player_id) REFERENCES Players(player_id) ON DELETE CASCADE,
    CONSTRAINT chk_kills CHECK (kills >= 0),
    CONSTRAINT chk_deaths CHECK (deaths >= 0),
    CONSTRAINT chk_outcome CHECK (match_outcome IN ('Win','Loss','Draw'))
);

-- ============================================================================
-- 3. INDEXES
-- ============================================================================
CREATE INDEX idx_players_mmr ON Players(skill_rating_mmr);
CREATE INDEX idx_players_region ON Players(region);
CREATE INDEX idx_match_history_player ON Match_History(player_id);
CREATE INDEX idx_rankings_points ON Player_Rankings(ranking_points DESC);

-- ============================================================================
-- 4. SAMPLE DATA
-- ============================================================================

INSERT INTO Players (player_id, username, skill_rating_mmr, player_level, region, wins, losses) VALUES
(1,  'ShadowBlade',   2450, 45, 'NA',   85, 35),
(2,  'PhantomStrike', 2280, 40, 'EU',   72, 38),
(3,  'NeonViper',     2100, 37, 'ASIA', 65, 40),
(4,  'FrostByte',     1950, 33, 'NA',   55, 42),
(5,  'ThunderWolf',   1820, 30, 'EU',   48, 45),
(6,  'CrimsonFox',    1650, 27, 'ASIA', 40, 38),
(7,  'IronClad',      1500, 24, 'NA',   35, 40),
(8,  'StormRider',    1380, 21, 'SA',   30, 35),
(9,  'DarkMatter',    1200, 18, 'EU',   22, 30),
(10, 'PixelHunter',   1050, 15, 'OCE',  18, 28),
(11, 'BlazeFury',     980,  12, 'NA',   12, 25),
(12, 'ArcticWind',    850,  10, 'ASIA', 8,  20),
(13, 'SilverHawk',    720,   8, 'EU',   5,  18),
(14, 'VoidWalker',    580,   5, 'SA',   3,  15),
(15, 'CosmicRay',     500,   3, 'OCE',  1,  12);

INSERT INTO Seasons (season_id, season_name, start_date, end_date, is_active) VALUES
(1, 'Season 1: Origins',    '2024-01-01', '2024-04-01', FALSE),
(2, 'Season 2: Storm',      '2024-04-01', '2024-07-01', TRUE);

INSERT INTO Player_Rankings (player_id, season_id, rank_tier, ranking_points) VALUES
(1, 2, 'Grandmaster', 3200), (2, 2, 'Master', 2800), (3, 2, 'Master', 2600),
(4, 2, 'Diamond', 2200), (5, 2, 'Diamond', 1900), (6, 2, 'Platinum', 1600),
(7, 2, 'Platinum', 1400), (8, 2, 'Gold', 1200), (9, 2, 'Gold', 1000),
(10, 2, 'Silver', 800), (11, 2, 'Silver', 650), (12, 2, 'Bronze', 450),
(13, 2, 'Bronze', 300), (14, 2, 'Bronze', 150), (15, 2, 'Bronze', 50);

INSERT INTO Items (item_id, item_name, rarity, buy_price, stat_boost) VALUES
(1, 'Iron Sword',        'Common',    200,  5),
(2, 'Shadow Dagger',     'Rare',      1500, 12),
(3, 'Dragon Staff',      'Epic',      5000, 20),
(4, 'Excalibur',         'Legendary', 15000,30),
(5, 'Leather Armor',     'Common',    150,  3),
(6, 'Dragon Scale Mail', 'Epic',      6000, 18),
(7, 'Health Potion',     'Common',    50,   0),
(8, 'Speed Boots',       'Uncommon',  600,  8);

INSERT INTO Player_Inventory (player_id, item_id, quantity, is_equipped) VALUES
(1, 4, 1, TRUE), (1, 6, 1, TRUE), (1, 7, 5, FALSE),
(2, 3, 1, TRUE), (2, 5, 1, TRUE),
(3, 2, 1, TRUE), (3, 8, 1, TRUE),
(4, 1, 1, TRUE), (4, 5, 1, TRUE),
(5, 3, 1, TRUE), (6, 2, 1, TRUE),
(7, 1, 1, TRUE), (8, 1, 1, TRUE), (8, 7, 3, FALSE);

INSERT INTO Powers (power_id, power_name, power_type, damage, cooldown_sec, rarity) VALUES
(1, 'Blade Storm',    'Attack',   45, 8.0,  'Rare'),
(2, 'Thunder Slash',  'Attack',   35, 5.0,  'Common'),
(3, 'Arcane Blast',   'Attack',   60, 10.0, 'Epic'),
(4, 'Frost Nova',     'Defense',  25, 12.0, 'Rare'),
(5, 'Shadow Step',    'Buff',     0,  6.0,  'Uncommon'),
(6, 'Death Mark',     'Ultimate', 80, 15.0, 'Legendary'),
(7, 'Healing Light',  'Heal',     0,  8.0,  'Rare'),
(8, 'Iron Wall',      'Defense',  0,  14.0, 'Epic');

INSERT INTO Player_Powers (player_id, power_id, power_level, is_equipped) VALUES
(1, 1, 5, TRUE), (1, 6, 3, TRUE),
(2, 3, 5, TRUE), (2, 4, 3, TRUE),
(3, 5, 4, TRUE), (3, 6, 4, TRUE),
(4, 2, 3, TRUE), (4, 8, 3, TRUE),
(5, 7, 4, TRUE), (5, 3, 2, FALSE),
(6, 1, 3, TRUE), (7, 8, 2, TRUE),
(8, 2, 2, TRUE), (9, 3, 1, TRUE);

INSERT INTO Matches (match_id, match_type, match_duration, match_date) VALUES
(1, 'Ranked',     185, '2024-05-01 20:00:00'),
(2, 'Ranked',     240, '2024-05-02 15:30:00'),
(3, 'Casual',     150, '2024-05-03 10:00:00'),
(4, 'Ranked',     310, '2024-05-04 22:15:00'),
(5, 'Tournament', 275, '2024-05-05 18:00:00'),
(6, 'Ranked',     190, '2024-05-06 21:30:00'),
(7, 'Casual',     165, '2024-05-07 12:45:00'),
(8, 'Ranked',     420, '2024-05-08 19:00:00');

INSERT INTO Match_History (match_id, player_id, kills, deaths, assists, damage_dealt, match_outcome) VALUES
(1, 1, 15, 3, 2, 12500, 'Win'), (1, 4, 8, 7, 3, 6800, 'Loss'),
(1, 2, 12, 5, 4, 11200, 'Win'), (1, 5, 6, 9, 5, 4200, 'Loss'),
(2, 3, 10, 4, 1, 9800, 'Win'), (2, 6, 7, 6, 2, 7200, 'Loss'),
(2, 7, 5, 8, 3, 4500, 'Loss'), (2, 4, 9, 5, 2, 8500, 'Win'),
(3, 11, 4, 10, 1, 3200, 'Loss'), (3, 12, 3, 8, 2, 2800, 'Loss'),
(3, 10, 6, 5, 3, 5500, 'Win'), (3, 13, 2, 7, 1, 2100, 'Loss'),
(4, 1, 18, 2, 0, 15800, 'Win'), (4, 3, 11, 6, 2, 9200, 'Win'),
(4, 9, 4, 11, 1, 4800, 'Loss'), (4, 14, 1, 12, 0, 1500, 'Loss'),
(5, 5, 7, 7, 4, 5800, 'Draw'), (5, 6, 7, 7, 3, 6200, 'Draw'),
(5, 8, 6, 6, 2, 5000, 'Draw'), (5, 7, 5, 5, 3, 4200, 'Draw'),
(6, 2, 14, 4, 3, 13500, 'Win'), (6, 1, 13, 5, 2, 12000, 'Win'),
(6, 3, 9, 8, 1, 8200, 'Loss'), (6, 5, 5, 10, 4, 3800, 'Loss'),
(7, 8, 8, 4, 2, 7200, 'Win'), (7, 14, 3, 9, 0, 2500, 'Loss'),
(7, 15, 2, 11, 1, 1800, 'Loss'), (7, 10, 7, 6, 3, 6000, 'Win'),
(8, 1, 20, 1, 1, 18500, 'Win'), (8, 2, 16, 3, 2, 14800, 'Win'),
(8, 11, 2, 14, 0, 2200, 'Loss'), (8, 15, 0, 15, 0, 800, 'Loss');

-- ============================================================================
-- 5. VIEWS
-- ============================================================================

CREATE VIEW view_player_stats AS
SELECT
    p.player_id, p.username, p.skill_rating_mmr, p.region,
    COUNT(mh.match_id) AS total_matches,
    COALESCE(SUM(mh.kills), 0) AS total_kills,
    COALESCE(SUM(mh.deaths), 0) AS total_deaths,
    CASE WHEN COALESCE(SUM(mh.deaths), 0) = 0 THEN CAST(SUM(mh.kills) AS DECIMAL)
         ELSE ROUND(CAST(SUM(mh.kills) AS DECIMAL) / SUM(mh.deaths), 2)
    END AS kd_ratio,
    ROUND(CAST(SUM(CASE WHEN mh.match_outcome='Win' THEN 1 ELSE 0 END) AS DECIMAL)
        / NULLIF(COUNT(mh.match_id), 0) * 100, 1) AS win_rate
FROM Players p
LEFT JOIN Match_History mh ON p.player_id = mh.player_id
GROUP BY p.player_id, p.username, p.skill_rating_mmr, p.region;

CREATE VIEW view_top_players AS
SELECT player_id, username, skill_rating_mmr, region
FROM Players ORDER BY skill_rating_mmr DESC LIMIT 10;

CREATE VIEW view_leaderboard AS
SELECT p.username, pr.rank_tier, pr.ranking_points, p.skill_rating_mmr, p.region
FROM Player_Rankings pr
JOIN Players p ON pr.player_id = p.player_id
JOIN Seasons s ON pr.season_id = s.season_id
WHERE s.is_active = TRUE
ORDER BY pr.ranking_points DESC;
