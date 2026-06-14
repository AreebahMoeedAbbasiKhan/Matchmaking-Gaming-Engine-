"""
============================================================================
PYTHON ML & ANALYTICS ENGINE
University Project: Gaming Platform Matchmaking Engine & Player Analytics

Features:
  - Win Rate Analysis (Pandas/NumPy)
  - K/D Ratio Computation
  - Match Outcome Prediction (Logistic Regression)
  - Scatter Plot Visualization (Matplotlib)
  - JSON output for frontend consumption
============================================================================
"""

import json
import os
import numpy as np

# Try to import optional libraries gracefully
try:
    import pandas as pd
    HAS_PANDAS = True
except ImportError:
    HAS_PANDAS = False
    print("[WARNING] pandas not installed. Using basic data processing.")

try:
    import matplotlib
    matplotlib.use('Agg')  # Non-interactive backend
    import matplotlib.pyplot as plt
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("[WARNING] matplotlib not installed. Skipping graph generation.")

try:
    from sklearn.linear_model import LogisticRegression
    from sklearn.model_selection import train_test_split
    from sklearn.metrics import accuracy_score
    HAS_SKLEARN = True
except ImportError:
    HAS_SKLEARN = False
    print("[WARNING] scikit-learn not installed. Skipping ML predictions.")


# ============================================================================
# PLAYER & MATCH DATA (Simulating SQL Database Read)
# ============================================================================
players_data = [
    {"player_id": 1,  "username": "ShadowBlade",   "mmr": 2450, "region": "NA",   "wins": 85, "losses": 35},
    {"player_id": 2,  "username": "PhantomStrike", "mmr": 2280, "region": "EU",   "wins": 72, "losses": 38},
    {"player_id": 3,  "username": "NeonViper",     "mmr": 2100, "region": "ASIA", "wins": 65, "losses": 40},
    {"player_id": 4,  "username": "FrostByte",     "mmr": 1950, "region": "NA",   "wins": 55, "losses": 42},
    {"player_id": 5,  "username": "ThunderWolf",   "mmr": 1820, "region": "EU",   "wins": 48, "losses": 45},
    {"player_id": 6,  "username": "CrimsonFox",    "mmr": 1650, "region": "ASIA", "wins": 40, "losses": 38},
    {"player_id": 7,  "username": "IronClad",      "mmr": 1500, "region": "NA",   "wins": 35, "losses": 40},
    {"player_id": 8,  "username": "StormRider",    "mmr": 1380, "region": "SA",   "wins": 30, "losses": 35},
    {"player_id": 9,  "username": "DarkMatter",    "mmr": 1200, "region": "EU",   "wins": 22, "losses": 30},
    {"player_id": 10, "username": "PixelHunter",   "mmr": 1050, "region": "OCE",  "wins": 18, "losses": 28},
    {"player_id": 11, "username": "BlazeFury",     "mmr": 980,  "region": "NA",   "wins": 12, "losses": 25},
    {"player_id": 12, "username": "ArcticWind",    "mmr": 850,  "region": "ASIA", "wins": 8,  "losses": 20},
    {"player_id": 13, "username": "SilverHawk",    "mmr": 720,  "region": "EU",   "wins": 5,  "losses": 18},
    {"player_id": 14, "username": "VoidWalker",    "mmr": 580,  "region": "SA",   "wins": 3,  "losses": 15},
    {"player_id": 15, "username": "CosmicRay",     "mmr": 500,  "region": "OCE",  "wins": 1,  "losses": 12},
]

match_data = [
    {"match_id": 1, "player_id": 1,  "kills": 15, "deaths": 3,  "assists": 2, "damage": 12500, "outcome": "Win"},
    {"match_id": 1, "player_id": 2,  "kills": 12, "deaths": 5,  "assists": 4, "damage": 11200, "outcome": "Win"},
    {"match_id": 1, "player_id": 4,  "kills": 8,  "deaths": 7,  "assists": 3, "damage": 6800,  "outcome": "Loss"},
    {"match_id": 1, "player_id": 5,  "kills": 6,  "deaths": 9,  "assists": 5, "damage": 4200,  "outcome": "Loss"},
    {"match_id": 2, "player_id": 3,  "kills": 10, "deaths": 4,  "assists": 1, "damage": 9800,  "outcome": "Win"},
    {"match_id": 2, "player_id": 4,  "kills": 9,  "deaths": 5,  "assists": 2, "damage": 8500,  "outcome": "Win"},
    {"match_id": 2, "player_id": 6,  "kills": 7,  "deaths": 6,  "assists": 2, "damage": 7200,  "outcome": "Loss"},
    {"match_id": 2, "player_id": 7,  "kills": 5,  "deaths": 8,  "assists": 3, "damage": 4500,  "outcome": "Loss"},
    {"match_id": 4, "player_id": 1,  "kills": 18, "deaths": 2,  "assists": 0, "damage": 15800, "outcome": "Win"},
    {"match_id": 4, "player_id": 3,  "kills": 11, "deaths": 6,  "assists": 2, "damage": 9200,  "outcome": "Win"},
    {"match_id": 4, "player_id": 9,  "kills": 4,  "deaths": 11, "assists": 1, "damage": 4800,  "outcome": "Loss"},
    {"match_id": 4, "player_id": 14, "kills": 1,  "deaths": 12, "assists": 0, "damage": 1500,  "outcome": "Loss"},
    {"match_id": 6, "player_id": 2,  "kills": 14, "deaths": 4,  "assists": 3, "damage": 13500, "outcome": "Win"},
    {"match_id": 6, "player_id": 1,  "kills": 13, "deaths": 5,  "assists": 2, "damage": 12000, "outcome": "Win"},
    {"match_id": 6, "player_id": 3,  "kills": 9,  "deaths": 8,  "assists": 1, "damage": 8200,  "outcome": "Loss"},
    {"match_id": 6, "player_id": 5,  "kills": 5,  "deaths": 10, "assists": 4, "damage": 3800,  "outcome": "Loss"},
    {"match_id": 8, "player_id": 1,  "kills": 20, "deaths": 1,  "assists": 1, "damage": 18500, "outcome": "Win"},
    {"match_id": 8, "player_id": 2,  "kills": 16, "deaths": 3,  "assists": 2, "damage": 14800, "outcome": "Win"},
    {"match_id": 8, "player_id": 11, "kills": 2,  "deaths": 14, "assists": 0, "damage": 2200,  "outcome": "Loss"},
    {"match_id": 8, "player_id": 15, "kills": 0,  "deaths": 15, "assists": 0, "damage": 800,   "outcome": "Loss"},
]


# ============================================================================
# ANALYTICS FUNCTIONS
# ============================================================================

def compute_player_stats(players, matches):
    """Compute K/D ratio and win rate for each player."""
    stats = []
    
    for player in players:
        pid = player["player_id"]
        player_matches = [m for m in matches if m["player_id"] == pid]
        
        total_kills = sum(m["kills"] for m in player_matches)
        total_deaths = sum(m["deaths"] for m in player_matches)
        total_assists = sum(m["assists"] for m in player_matches)
        total_damage = sum(m["damage"] for m in player_matches)
        total_wins = sum(1 for m in player_matches if m["outcome"] == "Win")
        total_matches = len(player_matches)
        
        kd_ratio = round(total_kills / max(total_deaths, 1), 2)
        win_rate = round((total_wins / max(total_matches, 1)) * 100, 1)
        
        stats.append({
            "player_id": pid,
            "username": player["username"],
            "mmr": player["mmr"],
            "region": player["region"],
            "total_matches": total_matches,
            "total_kills": total_kills,
            "total_deaths": total_deaths,
            "total_assists": total_assists,
            "total_damage": total_damage,
            "kd_ratio": kd_ratio,
            "win_rate": win_rate
        })
    
    return stats


def generate_scatter_plot(stats, output_path):
    """Generate MMR vs Win Rate scatter plot."""
    if not HAS_MATPLOTLIB:
        print("[SKIP] Cannot generate plot without matplotlib")
        return
    
    mmrs = [s["mmr"] for s in stats if s["total_matches"] > 0]
    win_rates = [s["win_rate"] for s in stats if s["total_matches"] > 0]
    kd_ratios = [s["kd_ratio"] for s in stats if s["total_matches"] > 0]
    names = [s["username"] for s in stats if s["total_matches"] > 0]
    
    # Create figure with dark gaming theme
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.patch.set_facecolor('#0f172a')
    
    # --- Plot 1: MMR vs Win Rate ---
    ax1 = axes[0]
    ax1.set_facecolor('#1e293b')
    scatter1 = ax1.scatter(mmrs, win_rates, c=mmrs, cmap='plasma', 
                           s=100, edgecolors='white', linewidth=0.5, alpha=0.9)
    ax1.set_xlabel('MMR (Skill Rating)', color='white', fontsize=11)
    ax1.set_ylabel('Win Rate (%)', color='white', fontsize=11)
    ax1.set_title('MMR vs Win Rate', color='#818cf8', fontsize=13, fontweight='bold')
    ax1.tick_params(colors='white')
    ax1.grid(True, alpha=0.2, color='gray')
    ax1.spines['bottom'].set_color('#334155')
    ax1.spines['top'].set_color('#334155')
    ax1.spines['left'].set_color('#334155')
    ax1.spines['right'].set_color('#334155')
    
    # Add player labels
    for i, name in enumerate(names):
        ax1.annotate(name, (mmrs[i], win_rates[i]), fontsize=7, 
                    color='#94a3b8', ha='center', va='bottom')
    
    # --- Plot 2: MMR vs K/D Ratio ---
    ax2 = axes[1]
    ax2.set_facecolor('#1e293b')
    scatter2 = ax2.scatter(mmrs, kd_ratios, c=kd_ratios, cmap='cool',
                           s=100, edgecolors='white', linewidth=0.5, alpha=0.9)
    ax2.set_xlabel('MMR (Skill Rating)', color='white', fontsize=11)
    ax2.set_ylabel('K/D Ratio', color='white', fontsize=11)
    ax2.set_title('MMR vs K/D Ratio', color='#818cf8', fontsize=13, fontweight='bold')
    ax2.tick_params(colors='white')
    ax2.grid(True, alpha=0.2, color='gray')
    ax2.spines['bottom'].set_color('#334155')
    ax2.spines['top'].set_color('#334155')
    ax2.spines['left'].set_color('#334155')
    ax2.spines['right'].set_color('#334155')
    
    for i, name in enumerate(names):
        ax2.annotate(name, (mmrs[i], kd_ratios[i]), fontsize=7,
                    color='#94a3b8', ha='center', va='bottom')
    
    plt.tight_layout(pad=2)
    plt.savefig(output_path, dpi=150, bbox_inches='tight', facecolor='#0f172a')
    plt.close()
    print(f"[PLOT] Saved scatter plot to: {output_path}")


def predict_match_outcome(stats):
    """
    Logistic Regression: Predict Win/Loss based on MMR and K/D ratio.
    Features: MMR, K/D Ratio
    Target: Win (1) or Loss (0) based on win_rate > 50%
    """
    if not HAS_SKLEARN:
        print("[SKIP] Cannot run ML without scikit-learn")
        return None
    
    # Prepare features
    X = np.array([[s["mmr"], s["kd_ratio"]] for s in stats if s["total_matches"] > 0])
    y = np.array([1 if s["win_rate"] > 50 else 0 for s in stats if s["total_matches"] > 0])
    
    if len(X) < 4:
        print("[ML] Not enough data for train/test split")
        return None
    
    # Train/Test split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)
    
    # Train model
    model = LogisticRegression(random_state=42)
    model.fit(X_train, y_train)
    
    # Evaluate
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    
    print(f"\n[ML] Logistic Regression Model Trained")
    print(f"[ML] Accuracy: {accuracy * 100:.1f}%")
    print(f"[ML] Coefficients: MMR={model.coef_[0][0]:.6f}, KD={model.coef_[0][1]:.6f}")
    
    # Predict for all players
    predictions = []
    for s in stats:
        if s["total_matches"] > 0:
            features = np.array([[s["mmr"], s["kd_ratio"]]])
            prob = model.predict_proba(features)[0]
            predictions.append({
                "username": s["username"],
                "mmr": s["mmr"],
                "predicted_win_prob": round(float(prob[1]) * 100, 1)
            })
    
    return {"accuracy": round(accuracy * 100, 1), "predictions": predictions}


# ============================================================================
# MAIN EXECUTION
# ============================================================================
def main():
    print("=" * 60)
    print("  GAMING PLATFORM - Python Analytics Engine")
    print("=" * 60)
    
    # Ensure output directory exists
    output_dir = os.path.join(os.path.dirname(__file__), "..", "frontend", "data")
    os.makedirs(output_dir, exist_ok=True)
    
    img_dir = os.path.join(os.path.dirname(__file__), "..", "frontend", "assets")
    os.makedirs(img_dir, exist_ok=True)
    
    # --- 1. Compute Stats ---
    print("\n[ANALYTICS] Computing player statistics...")
    stats = compute_player_stats(players_data, match_data)
    
    print(f"\n{'Username':<16} {'MMR':<6} {'K/D':<6} {'Win%':<7} {'Matches'}")
    print("-" * 50)
    for s in stats:
        if s["total_matches"] > 0:
            print(f"{s['username']:<16} {s['mmr']:<6} {s['kd_ratio']:<6} {s['win_rate']:<7} {s['total_matches']}")
    
    # --- 2. Generate Visualization ---
    print("\n[ANALYTICS] Generating scatter plot...")
    plot_path = os.path.join(img_dir, "analytics_plot.png")
    generate_scatter_plot(stats, plot_path)
    
    # --- 3. ML Prediction ---
    print("\n[ML] Training match outcome predictor...")
    ml_results = predict_match_outcome(stats)
    
    if ml_results:
        print(f"\n{'Username':<16} {'MMR':<6} {'Win Probability'}")
        print("-" * 40)
        for p in ml_results["predictions"]:
            print(f"{p['username']:<16} {p['mmr']:<6} {p['predicted_win_prob']}%")
    
    # --- 4. Save JSON for Frontend ---
    print("\n[OUTPUT] Writing analytics JSON...")
    
    analytics_output = {
        "player_stats": stats,
        "ml_predictions": ml_results["predictions"] if ml_results else [],
        "model_accuracy": ml_results["accuracy"] if ml_results else 0
    }
    
    with open(os.path.join(output_dir, "analytics.json"), "w") as f:
        json.dump(analytics_output, f, indent=2)
    print(f"  -> analytics.json")
    
    print("\n" + "=" * 60)
    print("  Analytics Engine Complete!")
    print("=" * 60)


if __name__ == "__main__":
    main()
