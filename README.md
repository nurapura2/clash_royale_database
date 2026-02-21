# Clash Royale - Relational Database & Entity Schema
**Description**
This pet project focuses on designing a robust relational database schema for Clash Royale game entities. The goal was to create a normalized structure capable of supporting game analytics, player tracking, and match history logging.

The repository contains the full SQL schema and a pre-populated database with synthetic data.

## Project Structure
```
clash_royale_database/
├── diagrams/
│   ├── ERD.pdf              # Entity-Relationship Diagram
│   └── normalization.pdf    # Database normalization process documentation
├── scripts/
│   ├── 01_init_schema.sql   # DDL: Table creation and constraints
│   ├── 02_data.sql          # DML: Synthetic data population
│   └── 03_queries.sql       # Analytical SQL queries and views
├── competition.sqlite       # Compiled SQLite database file
└── README.md
```

## Work Completed
Database Design: Architected a relational schema with 5+ core entities.

Normalization: Applied 3NF principles to ensure data integrity and reduce redundancy.

Data Generation: Populated tables with synthetic records using Python's random library (scripts not included).

Relational Mapping: Implemented complex relationships including many-to-one (Players to Clans) and dual-reference keys (Battles to Players).

Schema Overview
Cards: Catalog of units, spells, and buildings with rarity and elixir metrics.

Arenas: Tiered progression system with trophy requirements.

Clans: Clan metadata including types and entry requirements.

Players: User statistics, trophy counts, and clan affiliations.

Battles: Historical log of matches, results, and locations.

## Evaluation & Metrics
The schema is optimized for the following SQL operations:

Join Performance: Efficient linking of players, clans, and battle results.

Aggregation: Fast calculation of clan-wide trophy sums and card rarity distributions.

Integrity: Strict enforcement of Foreign Key constraints to prevent orphaned records.

## How to Run
1. Initialize Database
To deploy the schema and import data into a new SQLite instance:

Bash
```
sqlite3 clash_royale.db < sql/database.sql
```
2. Analytical Queries
You can run the following examples to test the dataset:

Top 10 Players by Wins:
SQL
```
SELECT p.name, COUNT(b.id) AS total_wins
FROM Players p
JOIN Battles b ON p.id = b.winner_id
GROUP BY p.id
ORDER BY total_wins DESC
LIMIT 10;
```

Clan Capacity Report:
```
SQL
SELECT c.name, COUNT(p.id) AS member_count
FROM Clans c
LEFT JOIN Players p ON c.id = p.clan_id
GROUP BY c.id;
```

## Technologies Used
SQL / SQLite 3

## Relational Modeling

Synthetic Data Generation (Python)

## Notes
All data in 02_data.sql is synthetic and used for demonstration purposes.
