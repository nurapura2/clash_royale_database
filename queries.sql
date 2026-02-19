-- ===========================
-- JOINs
-- ===========================
-- 1) It shows the players who belong to the Kazakhstan clans in the order of the highest king_level first
SELECT 
    p.player_id,
    p.nickname,
    p.king_level,
    c.clan_name,
    c.location
FROM Player p
LEFT JOIN Clan c ON p.clan_id = c.clan_id
WHERE c.location = 'Kazakhstan'
ORDER BY p.king_level DESC;

-- 2) Shows winners in tournaments
SELECT 
    p.player_id,
    p.nickname,
    t.tournament_id,
    t.tournament_name,
    t.prize
FROM Player p
JOIN Player_Tournament pt ON p.player_id = pt.player_id
JOIN Tournament t ON t.tournament_id = pt.tournament_id
WHERE pt.final_rank = 1
ORDER BY t.tournament_id;

-- 3) Shows the top 10 matches by duration
SELECT 
    m.match_id,
    t.tournament_name,
    m.date, m.duration,
    p1.nickname AS player1,
    p2.nickname AS player2
FROM Match m
LEFT JOIN Tournament t ON m.tournament_id = t.tournament_id
LEFT JOIN Player p1 ON p1.player_id = m.player1_id
LEFT JOIN Player p2 ON p2.player_id = m.player2_id
ORDER BY m.duration DESC
LIMIT 10;

-- 4) Shows matches where the opponents are from the same clan
SELECT 
    m.match_id,
    m.date,
    p1.player_id AS player1,
    p1.nickname AS nick1,
    p2.player_id AS player2,
    p2.nickname AS nick2,
    c.clan_name
FROM Match m
JOIN Player p1 ON p1.player_id = m.player1_id
JOIN Player p2 ON p2.player_id = m.player2_id
JOIN Clan c ON c.clan_id = p1.clan_id
WHERE p1.clan_id = p2.clan_id;

-- 5) Shows which cards are in the deck
SELECT
    d.deck_id,
    d.deck_name,
    c.card_name
FROM Deck d
JOIN Deck_Card dc ON d.deck_id = dc.deck_id
JOIN Card c ON dc.card_id = c.card_id;


-- 6) Shows a list of all the players who participated in the tournaments, and their final rank in each tournament
SELECT
    p.player_id,
    p.nickname AS player_nickname,
    t.tournament_name,
    pt.final_rank,
    p.trophy_road AS current_trophies
FROM Player p
JOIN Player_Tournament pt ON p.player_id = pt.player_id
JOIN Tournament t ON pt.tournament_id = t.tournament_id
ORDER BY t.tournament_name, pt.final_rank ASC;

-- ===========================
-- Aggregation Functions (COUNT, AVG, SUM, MIN, MAX)
-- ===========================
-- 7) Shows time statistics for matches
SELECT 
    COUNT(match_id) AS total_matches_played,
    SUM(duration) AS total_seconds_played,
    SUM(duration) / 60 AS total_minutes_played,
    SUM(duration) / 3600 AS total_hours_played,
    ROUND(AVG(duration), 1) AS avg_match_duration_sec
FROM Match;

-- 8) Shows statistics on the rarity of the cards
SELECT 
    rarity,
    COUNT(card_id) AS cards_count,                                 
    MIN(elixir_cost) AS min_cost,           
    MAX(elixir_cost) AS max_cost,           
    ROUND(AVG(elixir_cost), 2) AS avg_cost          
FROM Card
GROUP BY rarity
ORDER BY 
    CASE rarity
        WHEN 'Common' THEN 1
        WHEN 'Rare' THEN 2
        WHEN 'Epic' THEN 3
        WHEN 'Legendary' THEN 4
    END ASC; 

-- 9) Shows the division of clan data by its location
SELECT 
    location,
    COUNT(clan_id) AS total_clans,
    SUM(members_count) AS total_people,
    ROUND(AVG(clan_score), 2) AS avg_clan_score
FROM Clan
GROUP BY location
ORDER BY total_clans DESC; 

-- 10) Shows how many players are in each King level
SELECT 
    king_level,
    COUNT(player_id) AS player_count
FROM Player
GROUP BY king_level
ORDER BY king_level DESC;

-- 11) Shows how many times the player won and how much he played
SELECT 
    p.nickname,
    COUNT(m.match_id) AS matches_won,
    SUM(m.duration) AS total_seconds_played
FROM Player p, Match m
WHERE p.player_id = m.winner_id
GROUP BY p.player_id, p.nickname
ORDER BY matches_won DESC;

-- ===========================
-- Subqueries 
-- ===========================
-- 12) Shows only those decks with more than two legendary cards
SELECT 
    d.deck_name,
    lc.count_legendaries
FROM Deck d
JOIN (
    SELECT dc.deck_id, COUNT(*) as count_legendaries
    FROM Deck_Card dc
    JOIN Card c ON dc.card_id = c.card_id
    WHERE c.rarity = 'Legendary'
    GROUP BY dc.deck_id
) lc ON d.deck_id = lc.deck_id
WHERE lc.count_legendaries > 2
ORDER BY count_legendaries;

-- 13) Shows a list of clans and their number of wins (first place) in their wars
SELECT 
    c.clan_name,
    c.clan_score,
    (SELECT 
        COUNT(cw.war_id)
    FROM Clan_War cw
    WHERE cw.clan_id = c.clan_id AND cw.place = 1
    ) AS total_wars_won
FROM Clan c
ORDER BY total_wars_won DESC;

-- 14) Shows a list of cards that are more expensive than the average in their rarity
SELECT
    c1.card_name,
    c1.rarity,
    c1.elixir_cost AS card_cost,
    (SELECT 
        ROUND(AVG(c2.elixir_cost), 2)
    FROM Card c2
    WHERE c2.rarity = c1.rarity
    ) AS avg_rarity_cost 
FROM Card c1
WHERE c1.elixir_cost > (
        SELECT 
            ROUND(AVG(c2.elixir_cost), 2)
        FROM Card c2
        WHERE c2.rarity = c1.rarity
    )
ORDER BY c1.rarity, c1.elixir_cost DESC;

-- 15) Shows the opposite of players who have not participated in tournaments
SELECT 
    player_id,
    nickname
FROM Player
WHERE player_id NOT IN (
        SELECT DISTINCT player_id 
        FROM Player_Tournament
    );



-- ===========================
-- JOIN and aggregation combined 
-- ===========================
-- 16) Shows the top 10 players by the amount of elixir spent, as well as how many matches they played
SELECT
    p.player_id,
    p.nickname,
    SUM(ps.total_elixir_cost) AS elixir_cost,
    COUNT(ps.match_id) AS total_match_count
FROM Player p
JOIN Player_Stats ps ON p.player_id = ps.player_id
GROUP BY p.player_id, p.nickname
ORDER BY elixir_cost DESC
LIMIT 10;

-- 17) Shows victory statistics using this deck excluding unknown decks
SELECT
    d.deck_id,
    d.deck_name,
    COUNT(m.match_id) AS wins_count
FROM Deck d
JOIN Player p ON d.deck_id = p.deck_id
JOIN Match m ON p.player_id = m.winner_id
WHERE d.deck_id <> 999
GROUP BY d.deck_id, d.deck_name
ORDER BY wins_count DESC;

-- 18) Shows how many participants are in each tournament
SELECT
    t.tournament_id,
    t.tournament_name,
    COUNT(player_id) AS players_count
FROM Player_Tournament pt
JOIN Tournament t ON pt.tournament_id = t.tournament_id
GROUP BY t.tournament_id
ORDER BY players_count DESC;

-- 19) Shows the total damage done and the number of crowns earned by each player in specific tournaments
SELECT 
    t.tournament_name,
    p.nickname,
    SUM(ps.total_damage) AS total_damage_dealt,
    SUM(ps.crowns_earned) AS total_crowns
FROM Player p
JOIN Player_Stats ps ON p.player_id = ps.player_id
JOIN Match m ON ps.match_id = m.match_id
JOIN Tournament t ON m.tournament_id = t.tournament_id
GROUP BY t.tournament_id, p.player_id
ORDER BY total_damage_dealt DESC;

-- 20) It shows how many times cards of a certain rarity are found in all created decks
SELECT 
    c.rarity,
    COUNT(dc.deck_id) AS times_used_in_decks,
    ROUND(AVG(c.elixir_cost), 1) AS avg_rarity_cost
FROM Card c
JOIN Deck_Card dc ON c.card_id = dc.card_id
GROUP BY c.rarity
ORDER BY times_used_in_decks DESC;




