# Gaming Platform: Matchmaking Engine & Player Analytics

## University Project — Multi-Tier Architecture

A complete gaming matchmaking system demonstrating full-stack development with C++ data structures, Python machine learning, SQL database design, and a modern web frontend.

---

## 🏗️ System Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   SQL Database  │────▶│  C++ DSA Engine   │────▶│  JSON Output    │
│   (PostgreSQL)  │     │  BST/Heap/Queue   │     │  (File Bridge)  │
└─────────────────┘     └──────────────────┘     └────────┬────────┘
        │                                                  │
        │               ┌──────────────────┐               ▼
        └──────────────▶│  Python ML/Stats │     ┌─────────────────┐
                        │  Pandas/Sklearn  │────▶│  Frontend (HTML)│
                        └──────────────────┘     │  CSS + JS       │
                                                 └─────────────────┘
```

---

## 📂 Project Structure

```
├── database/
│   └── schema.sql              # Complete DDL + sample data + views
│
├── cpp_engine/
│   └── matchmaking_engine.cpp  # BST, Max-Heap, Linked List Queue
│
├── python_analytics/
│   └── analytics.py            # Win rate, K/D, Logistic Regression
│
├── frontend/
│   ├── index.html              # Home page
│   ├── players.html            # Player management
│   ├── matchmaking.html        # Queue & matching
│   ├── leaderboard.html        # Top 10 rankings
│   ├── analytics.html          # Stats & ML predictions
│   ├── css/style.css           # Dark gaming theme
│   ├── js/app.js               # UI logic & interactions
│   ├── data/                   # JSON output from engines
│   └── assets/                 # Plot images from Python
│
└── README.md
```

---

## 🚀 How to Run

### 1. Frontend (Open directly in browser)
```
Open frontend/index.html in any browser
```
No server needed — all data is embedded in JavaScript for standalone operation.

### 2. C++ Engine (Compile & Run)
```bash
cd cpp_engine
g++ -o matchmaking matchmaking_engine.cpp -std=c++17
./matchmaking
```
Outputs JSON files to `frontend/data/`

### 3. Python Analytics (Run script)
```bash
cd python_analytics
pip install numpy matplotlib scikit-learn pandas
python analytics.py
```
Generates `frontend/assets/analytics_plot.png` and `frontend/data/analytics.json`

### 4. SQL Database (Execute on PostgreSQL)
```bash
psql -U postgres -c "CREATE DATABASE matchmaking_engine;"
psql -U postgres -d matchmaking_engine -f database/schema.sql
```

---

## 💻 Technologies & Data Structures

| Layer | Technology | DSA/Algorithm |
|-------|-----------|---------------|
| Database | PostgreSQL/SQL | Indexing, Joins, Views |
| C++ Engine | Standard C++ | BST, Max-Heap, Linked List (Queue) |
| Python ML | Pandas, NumPy, Sklearn | Logistic Regression, Statistics |
| Frontend | HTML5, CSS3, JS | DOM Manipulation, Event Handling |

### C++ Data Structures:
- **Binary Search Tree (BST)**: MMR sorting & range queries (find players between MMR X and Y)
- **Max-Heap**: Leaderboard extraction (top 10 players by MMR)
- **Linked List Queue**: FIFO matchmaking queue with enqueue/dequeue

### Python ML:
- **Logistic Regression**: Predict match win probability from MMR + K/D ratio
- **Matplotlib**: Scatter plots (MMR vs Win Rate, MMR vs K/D)
- **NumPy/Pandas**: Statistical analysis

---

## 🎮 Features

- ✅ Display all players in table format
- ✅ Add new players via form
- ✅ Matchmaking queue (Linked List FIFO)
- ✅ Leaderboard (Max-Heap sorted)
- ✅ Analytics with K/D and win rate
- ✅ ML prediction display
- ✅ Scatter plot visualization
- ✅ Dark gaming UI theme
- ✅ Responsive design
- ✅ SQL schema with constraints, indexes, views
