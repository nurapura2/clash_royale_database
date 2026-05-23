# 🎮 Clash Royale — Relational Database & Entity Schema

![SQLite](https://img.shields.io/badge/SQLite-003B57?style=flat&logo=sqlite&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

## Description

A pet project focused on designing a normalized relational database schema for Clash Royale game entities. The goal was to build a structure capable of supporting game analytics, player tracking, and match history logging — then use it to answer real analytical questions about gameplay patterns.

The repository includes the full SQL schema, synthetic data, and a collection of analytical queries.

---

## Project Structure

```
clash_royale_database/
├── diagrams/
│   ├── ERD.pdf                  # Entity-Relationship Diagram
│   └── normalization.pdf        # 3NF normalization process documentation
├── scripts/
│   ├── 01_init_schema.sql       # DDL: Table creation and constraints
│   ├── 02_data.sql              # DML: Synthetic data population
│   └── 03_queries.sql           # Analytical SQL queries and views
├── competition.sqlite           # Compiled SQLite database file
└── README.md
```

---

## Schema Overview

The database is built around 5 core entities with clearly defined relationships:

| Entity | Description |
|--------|-------------|
| **Cards** | Catalog of units, spells, and buildings with rarity and elixir cost |
| **Arenas** | Tiered progression system with trophy thresholds |
| **Clans** | Clan metadata including type and entry requirements |
| **Players** | User statistics, trophy counts, and clan affiliations |
| **Battles** | Historical log of matches, outcomes, and arena locations |

**Key relationships:**
- Players → Clans: many-to-one
- Battles → Players: dual-reference foreign keys (winner/loser)
- Players → Arenas: many-to-one via trophy count

---

## ERD overview
<img width="1730" height="1557" alt="ERD" src="https://github.com/user-attachments/assets/a7bdee7d-9ba7-4d8d-92f6-2521570423d1" />
<img width="1451" height="1311" alt="изображение" src="https://github.com/user-attachments/assets/dfe2fa0e-a5b8-4767-b88a-8444befc4f12" />

---

## Database Design Decisions

- **3NF Normalization** applied throughout to eliminate redundancy and ensure data integrity
- **Foreign Key constraints** enforced to prevent orphaned records
- **Dual-reference keys** in the Battles table allow tracking both participants without duplicating player data
- Schema optimized for aggregation-heavy queries (clan stats, card distributions, win rates)

---

## Analytical Queries & Key Findings

The schema was designed to answer the following questions:

### 🏆 Top 10 Players by Wins
```sql
SELECT p.name, COUNT(b.id) AS total_wins
FROM Players p
JOIN Battles b ON p.id = b.winner_id
GROUP BY p.id
ORDER BY total_wins DESC
LIMIT 10;
```

### 🏰 Clan Member Count & Capacity Report
```sql
SELECT c.name, COUNT(p.id) AS member_count
FROM Clans c
LEFT JOIN Players p ON c.id = p.clan_id
GROUP BY c.id;
```

### ⚔️ Win Rate by Arena
```sql
SELECT a.name AS arena,
       COUNT(b.id) AS total_battles,
       ROUND(AVG(CASE WHEN b.winner_id IS NOT NULL THEN 1 ELSE 0 END) * 100, 2) AS win_rate_pct
FROM Battles b
JOIN Arenas a ON b.arena_id = a.id
GROUP BY a.id
ORDER BY a.trophy_requirement;
```

### 🃏 Card Popularity by Rarity
```sql
SELECT rarity, COUNT(*) AS card_count,
       ROUND(AVG(elixir_cost), 2) AS avg_elixir
FROM Cards
GROUP BY rarity
ORDER BY avg_elixir DESC;
```

### 📊 Clan Activity — Average Trophies per Clan
```sql
SELECT c.name, 
       COUNT(p.id) AS members,
       ROUND(AVG(p.trophies), 0) AS avg_trophies
FROM Clans c
JOIN Players p ON c.id = p.clan_id
GROUP BY c.id
ORDER BY avg_trophies DESC;
```

---

## How to Run

**1. Initialize the database**
```bash
sqlite3 clash_royale.db < scripts/01_init_schema.sql
sqlite3 clash_royale.db < scripts/02_data.sql
```

**2. Run analytical queries**
```bash
sqlite3 clash_royale.db < scripts/03_queries.sql
```

Or open `competition.sqlite` directly in [DB Browser for SQLite](https://sqlitebrowser.org/).

---

## Technologies Used

- **SQL / SQLite 3** — schema design, queries, views
- **Python** (`random`, `sqlite3`) — synthetic data generation
- **DB Browser for SQLite** — visual schema inspection and query testing

---

## Notes

All data in `02_data.sql` is synthetically generated for demonstration purposes only and does not reflect real Clash Royale gameplay statistics.
