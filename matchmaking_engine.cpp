/*
 * ============================================================================
 * MATCHMAKING ENGINE - C++ DSA Implementation
 * University Project: Gaming Platform
 * 
 * Data Structures Used:
 *   - Binary Search Tree (BST): MMR-based player sorting & range queries
 *   - Max-Heap: Leaderboard (Top players by MMR)
 *   - Linked List (Queue): Matchmaking queue (FIFO)
 * 
 * Output: JSON files for frontend consumption
 * ============================================================================
 */

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <queue>
#include <cstdlib>
#include <ctime>
#include <algorithm>
#include <sstream>

using namespace std;

// ============================================================================
// PLAYER STRUCTURE
// ============================================================================
struct Player {
    int player_id;
    string username;
    int mmr;
    string region;
    int wins;
    int losses;
};

// ============================================================================
// BST NODE - For MMR-based sorting and range queries
// ============================================================================
struct BSTNode {
    Player player;
    BSTNode* left;
    BSTNode* right;
    
    BSTNode(Player p) : player(p), left(nullptr), right(nullptr) {}
};

// ============================================================================
// BINARY SEARCH TREE CLASS
// ============================================================================
class BST {
private:
    BSTNode* root;
    
    BSTNode* insert(BSTNode* node, Player player) {
        if (node == nullptr) return new BSTNode(player);
        if (player.mmr < node->player.mmr)
            node->left = insert(node->left, player);
        else
            node->right = insert(node->right, player);
        return node;
    }
    
    void inorder(BSTNode* node, vector<Player>& result) {
        if (node == nullptr) return;
        inorder(node->left, result);
        result.push_back(node->player);
        inorder(node->right, result);
    }
    
    void rangeQuery(BSTNode* node, int low, int high, vector<Player>& result) {
        if (node == nullptr) return;
        if (node->player.mmr > low)
            rangeQuery(node->left, low, high, result);
        if (node->player.mmr >= low && node->player.mmr <= high)
            result.push_back(node->player);
        if (node->player.mmr < high)
            rangeQuery(node->right, low, high, result);
    }
    
    void destroy(BSTNode* node) {
        if (node == nullptr) return;
        destroy(node->left);
        destroy(node->right);
        delete node;
    }

public:
    BST() : root(nullptr) {}
    ~BST() { destroy(root); }
    
    void insert(Player player) {
        root = insert(root, player);
    }
    
    vector<Player> getSorted() {
        vector<Player> result;
        inorder(root, result);
        return result;
    }
    
    vector<Player> findInRange(int low, int high) {
        vector<Player> result;
        rangeQuery(root, low, high, result);
        return result;
    }
};

// ============================================================================
// MAX-HEAP - For Leaderboard (Top players by MMR)
// ============================================================================
class MaxHeap {
private:
    vector<Player> heap;
    
    void heapifyUp(int index) {
        while (index > 0) {
            int parent = (index - 1) / 2;
            if (heap[index].mmr > heap[parent].mmr) {
                swap(heap[index], heap[parent]);
                index = parent;
            } else break;
        }
    }
    
    void heapifyDown(int index) {
        int size = heap.size();
        while (true) {
            int largest = index;
            int left = 2 * index + 1;
            int right = 2 * index + 2;
            if (left < size && heap[left].mmr > heap[largest].mmr)
                largest = left;
            if (right < size && heap[right].mmr > heap[largest].mmr)
                largest = right;
            if (largest != index) {
                swap(heap[index], heap[largest]);
                index = largest;
            } else break;
        }
    }

public:
    void insert(Player player) {
        heap.push_back(player);
        heapifyUp(heap.size() - 1);
    }
    
    Player extractMax() {
        Player max = heap[0];
        heap[0] = heap.back();
        heap.pop_back();
        if (!heap.empty()) heapifyDown(0);
        return max;
    }
    
    bool isEmpty() { return heap.empty(); }
    int size() { return heap.size(); }
    
    vector<Player> getTop(int n) {
        vector<Player> top;
        // Create a copy to extract from
        MaxHeap copy = *this;
        for (int i = 0; i < n && !copy.isEmpty(); i++) {
            top.push_back(copy.extractMax());
        }
        return top;
    }
};

// ============================================================================
// LINKED LIST QUEUE - Matchmaking Queue (FIFO)
// ============================================================================
struct QueueNode {
    Player player;
    QueueNode* next;
    QueueNode(Player p) : player(p), next(nullptr) {}
};

class MatchmakingQueue {
private:
    QueueNode* front;
    QueueNode* rear;
    int count;

public:
    MatchmakingQueue() : front(nullptr), rear(nullptr), count(0) {}
    
    ~MatchmakingQueue() {
        while (front != nullptr) {
            QueueNode* temp = front;
            front = front->next;
            delete temp;
        }
    }
    
    void enqueue(Player player) {
        QueueNode* newNode = new QueueNode(player);
        if (rear == nullptr) {
            front = rear = newNode;
        } else {
            rear->next = newNode;
            rear = newNode;
        }
        count++;
    }
    
    Player dequeue() {
        if (front == nullptr) throw runtime_error("Queue is empty");
        QueueNode* temp = front;
        Player player = front->player;
        front = front->next;
        if (front == nullptr) rear = nullptr;
        delete temp;
        count--;
        return player;
    }
    
    bool isEmpty() { return front == nullptr; }
    int size() { return count; }
    
    vector<Player> getAll() {
        vector<Player> all;
        QueueNode* current = front;
        while (current != nullptr) {
            all.push_back(current->player);
            current = current->next;
        }
        return all;
    }
};

// ============================================================================
// JSON OUTPUT UTILITIES
// ============================================================================
string playerToJSON(const Player& p) {
    stringstream ss;
    ss << "    {";
    ss << "\"player_id\": " << p.player_id << ", ";
    ss << "\"username\": \"" << p.username << "\", ";
    ss << "\"mmr\": " << p.mmr << ", ";
    ss << "\"region\": \"" << p.region << "\", ";
    ss << "\"wins\": " << p.wins << ", ";
    ss << "\"losses\": " << p.losses;
    ss << "}";
    return ss.str();
}

void writePlayersJSON(const string& filename, const vector<Player>& players) {
    ofstream file(filename);
    file << "[\n";
    for (size_t i = 0; i < players.size(); i++) {
        file << playerToJSON(players[i]);
        if (i < players.size() - 1) file << ",";
        file << "\n";
    }
    file << "]\n";
    file.close();
}

void writeMatchesJSON(const string& filename, const vector<pair<Player, Player>>& matches) {
    ofstream file(filename);
    file << "[\n";
    for (size_t i = 0; i < matches.size(); i++) {
        file << "    {";
        file << "\"player1\": " << playerToJSON(matches[i].first) << ", ";
        file << "\"player2\": " << playerToJSON(matches[i].second);
        file << "}";
        if (i < matches.size() - 1) file << ",";
        file << "\n";
    }
    file << "]\n";
    file.close();
}

void writeQueueJSON(const string& filename, const vector<Player>& queue) {
    ofstream file(filename);
    file << "{\n";
    file << "  \"queue_size\": " << queue.size() << ",\n";
    file << "  \"players\": [\n";
    for (size_t i = 0; i < queue.size(); i++) {
        file << playerToJSON(queue[i]);
        if (i < queue.size() - 1) file << ",";
        file << "\n";
    }
    file << "  ]\n";
    file << "}\n";
    file.close();
}

// ============================================================================
// MATCHMAKING ALGORITHM
// ============================================================================
vector<pair<Player, Player>> performMatchmaking(MatchmakingQueue& queue, int mmrRange = 300) {
    vector<pair<Player, Player>> matches;
    vector<Player> waiting;
    
    // Dequeue all players
    while (!queue.isEmpty()) {
        waiting.push_back(queue.dequeue());
    }
    
    // Sort by MMR for better matching
    sort(waiting.begin(), waiting.end(), [](const Player& a, const Player& b) {
        return a.mmr < b.mmr;
    });
    
    // Match adjacent players within MMR range
    vector<bool> matched(waiting.size(), false);
    for (size_t i = 0; i < waiting.size(); i++) {
        if (matched[i]) continue;
        for (size_t j = i + 1; j < waiting.size(); j++) {
            if (matched[j]) continue;
            if (abs(waiting[j].mmr - waiting[i].mmr) <= mmrRange) {
                matches.push_back({waiting[i], waiting[j]});
                matched[i] = matched[j] = true;
                break;
            }
        }
    }
    
    // Re-queue unmatched players
    for (size_t i = 0; i < waiting.size(); i++) {
        if (!matched[i]) queue.enqueue(waiting[i]);
    }
    
    return matches;
}

// ============================================================================
// MAIN
// ============================================================================
int main() {
    cout << "=== Gaming Platform Matchmaking Engine ===" << endl;
    cout << "Initializing data structures..." << endl;
    
    // --- Player Data (simulating SQL read) ---
    vector<Player> allPlayers = {
        {1,  "ShadowBlade",   2450, "NA",   85, 35},
        {2,  "PhantomStrike", 2280, "EU",   72, 38},
        {3,  "NeonViper",     2100, "ASIA", 65, 40},
        {4,  "FrostByte",     1950, "NA",   55, 42},
        {5,  "ThunderWolf",   1820, "EU",   48, 45},
        {6,  "CrimsonFox",    1650, "ASIA", 40, 38},
        {7,  "IronClad",      1500, "NA",   35, 40},
        {8,  "StormRider",    1380, "SA",   30, 35},
        {9,  "DarkMatter",    1200, "EU",   22, 30},
        {10, "PixelHunter",   1050, "OCE",  18, 28},
        {11, "BlazeFury",     980,  "NA",   12, 25},
        {12, "ArcticWind",    850,  "ASIA", 8,  20},
        {13, "SilverHawk",    720,  "EU",   5,  18},
        {14, "VoidWalker",    580,  "SA",   3,  15},
        {15, "CosmicRay",     500,  "OCE",  1,  12}
    };
    
    // --- 1. BUILD BST (MMR Sorting) ---
    cout << "\n[BST] Building Binary Search Tree by MMR..." << endl;
    BST bst;
    for (auto& p : allPlayers) {
        bst.insert(p);
    }
    vector<Player> sorted = bst.getSorted();
    cout << "[BST] Players sorted by MMR (ascending):" << endl;
    for (auto& p : sorted) {
        cout << "  " << p.username << " - MMR: " << p.mmr << endl;
    }
    
    // Range query example
    cout << "\n[BST] Range Query (MMR 1000-2000):" << endl;
    vector<Player> rangeResult = bst.findInRange(1000, 2000);
    for (auto& p : rangeResult) {
        cout << "  " << p.username << " - MMR: " << p.mmr << endl;
    }
    
    // --- 2. BUILD MAX-HEAP (Leaderboard) ---
    cout << "\n[HEAP] Building Max-Heap for Leaderboard..." << endl;
    MaxHeap leaderboard;
    for (auto& p : allPlayers) {
        leaderboard.insert(p);
    }
    vector<Player> top10 = leaderboard.getTop(10);
    cout << "[HEAP] Top 10 Leaderboard:" << endl;
    for (size_t i = 0; i < top10.size(); i++) {
        cout << "  #" << (i+1) << " " << top10[i].username << " - MMR: " << top10[i].mmr << endl;
    }
    
    // --- 3. MATCHMAKING QUEUE (Linked List) ---
    cout << "\n[QUEUE] Building Matchmaking Queue..." << endl;
    MatchmakingQueue queue;
    
    // Simulate players joining queue
    queue.enqueue(allPlayers[0]);  // MMR 2450
    queue.enqueue(allPlayers[1]);  // MMR 2280
    queue.enqueue(allPlayers[3]);  // MMR 1950
    queue.enqueue(allPlayers[4]);  // MMR 1820
    queue.enqueue(allPlayers[6]);  // MMR 1500
    queue.enqueue(allPlayers[7]);  // MMR 1380
    queue.enqueue(allPlayers[9]);  // MMR 1050
    queue.enqueue(allPlayers[10]); // MMR 980
    queue.enqueue(allPlayers[12]); // MMR 720
    queue.enqueue(allPlayers[14]); // MMR 500
    
    cout << "[QUEUE] Players in queue: " << queue.size() << endl;
    
    // Write queue state before matching
    vector<Player> queueState = queue.getAll();
    
    // Perform matchmaking
    cout << "\n[MATCHMAKING] Finding matches (MMR range: 300)..." << endl;
    vector<pair<Player, Player>> matches = performMatchmaking(queue, 300);
    
    cout << "[MATCHMAKING] Matches found: " << matches.size() << endl;
    for (auto& m : matches) {
        cout << "  " << m.first.username << " (MMR:" << m.first.mmr << ") vs "
             << m.second.username << " (MMR:" << m.second.mmr << ")" << endl;
    }
    
    cout << "\n[QUEUE] Remaining in queue: " << queue.size() << endl;
    
    // --- 4. WRITE JSON OUTPUT FILES ---
    string outputDir = "../frontend/data/";
    
    cout << "\n[OUTPUT] Writing JSON files for frontend..." << endl;
    
    // All players
    writePlayersJSON(outputDir + "players.json", allPlayers);
    cout << "  -> players.json" << endl;
    
    // Leaderboard (top 10)
    writePlayersJSON(outputDir + "leaderboard.json", top10);
    cout << "  -> leaderboard.json" << endl;
    
    // Queue state
    writeQueueJSON(outputDir + "queue.json", queueState);
    cout << "  -> queue.json" << endl;
    
    // Match results
    writeMatchesJSON(outputDir + "matches.json", matches);
    cout << "  -> matches.json" << endl;
    
    cout << "\n=== Engine Complete ===" << endl;
    return 0;
}
