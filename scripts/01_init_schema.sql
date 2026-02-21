-- SQLite
drop table if EXISTS Player;
drop table if EXISTS Clan;
drop table if EXISTS Clan_War;
drop table if EXISTS Deck;
drop table if EXISTS Deck_Card;
drop table if EXISTS Card;
drop table if EXISTS Tournament;
drop table if EXISTS Match;
drop table if EXISTS Player_Stats;
drop table if EXISTS Player_Penalty;
drop table if EXISTS Player_Tournament;

CREATE TABLE Player (
    player_id INTEGER PRIMARY KEY,
    nickname TEXT NOT NULL,
    trophy_road INTEGER NOT NULL,
    deck_id INTEGER,
    stats_royale INTEGER,
    clan_id TEXT,
    king_level INTEGER NOT NULL,
    FOREIGN KEY (clan_id) REFERENCES Clan(clan_id),
    FOREIGN KEY (deck_id) REFERENCES Deck(deck_id)
);

CREATE TABLE Clan (
    clan_id INTEGER PRIMARY KEY,
    clan_tag TEXT,
    clan_name TEXT NOT NULL,
    location TEXT,
    clan_score INTEGER,
    members_count INTEGER NOT NULL,
    required_trophies INTEGER,
    donations_weekly INTEGER
);

CREATE TABLE Clan_War (
    war_id TEXT PRIMARY KEY,
    clan_id INTEGER NOT NULL,
    type TEXT,
    week INTEGER,
    result TEXT,
    place TEXT,
    FOREIGN KEY (clan_id) REFERENCES Clan(clan_id)
);

CREATE TABLE Deck (
    deck_id INTEGER PRIMARY KEY NOT NULL,
    deck_name TEXT
);

CREATE TABLE Deck_Card (
    deck_id INTEGER NOT NULL,
    card_id INTEGER NOT NULL,
    PRIMARY KEY (deck_id, card_id),
    FOREIGN KEY (deck_id) REFERENCES Deck(deck_id),
    FOREIGN KEY (card_id) REFERENCES Card(card_id)
);

CREATE TABLE Card (
    card_id INTEGER PRIMARY KEY,
    card_name TEXT NOT NULL,
    rarity TEXT NOT NULL,
    elixir_cost REAL NOT NULL,
    card_type TEXT NOT NULL
);

CREATE TABLE Tournament (
    tournament_id INTEGER PRIMARY KEY,
    tournament_name TEXT NOT NULL,
    location TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    type TEXT,
    prize TEXT
);

CREATE TABLE Match (
    match_id INTEGER PRIMARY KEY,
    tournament_id INTEGER NOT NULL,
    player1_id INTEGER NOT NULL,
    player2_id INTEGER NOT NULL,
    winner_id INTEGER,
    duration INTEGER,
    date DATE,
    FOREIGN KEY (tournament_id) REFERENCES Tournament(tournament_id),
    FOREIGN KEY (player1_id) REFERENCES Player(player_id),
    FOREIGN KEY (player2_id) REFERENCES Player(player_id),
    FOREIGN KEY (winner_id) REFERENCES Player(player_id)
);

CREATE TABLE Player_Stats (
    match_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    deck_id INTEGER,
    total_damage INTEGER,
    crowns_earned INTEGER,
    total_elixir_cost INTEGER,
    count_cards_used INTEGER,
    PRIMARY KEY (match_id, player_id),
    FOREIGN KEY (match_id) REFERENCES Match(match_id),
    FOREIGN KEY (player_id) REFERENCES Player(player_id),
    FOREIGN KEY (deck_id) REFERENCES Deck(deck_id)
);

CREATE TABLE Player_Penalty (
    penalty_id INTEGER PRIMARY KEY,
    player_id INTEGER NOT NULL,
    tournament_id INTEGER NOT NULL,
    match_id INTEGER,                      
    type TEXT NOT NULL,                    
    severity INTEGER,            
    reason TEXT,                           
    rule_code TEXT,                        
    FOREIGN KEY (player_id) REFERENCES Player(player_id),
    FOREIGN KEY (tournament_id) REFERENCES Tournament(tournament_id),
    FOREIGN KEY (match_id) REFERENCES Match(match_id)
);

CREATE TABLE Player_Tournament (
    player_id INTEGER NOT NULL,
    tournament_id INTEGER NOT NULL,
    registration_date DATE,
    status TEXT DEFAULT 'registered',
    final_rank INTEGER,
    PRIMARY KEY (player_id, tournament_id),
    FOREIGN KEY (player_id) REFERENCES Player(player_id),
    FOREIGN KEY (tournament_id) REFERENCES Tournament(tournament_id)
);



