# Match-Three Tile Puzzle — Complete Game Specification

---

## TABLE OF CONTENTS

1. [Project Overview](#1-project-overview)
2. [Architecture & Project Structure](#2-architecture--project-structure)
3. [Screen Flow & Navigation](#3-screen-flow--navigation)
4. [Core Gameplay — The Board](#4-core-gameplay--the-board)
5. [Tile System](#5-tile-system)
6. [Input System](#6-input-system)
7. [Match Detection Algorithm](#7-match-detection-algorithm)
8. [Cascade System](#8-cascade-system)
9. [Special Tiles & Combos](#9-special-tiles--combos)
10. [Level System & Progression](#10-level-system--progression)
11. [Scoring System](#11-scoring-system)
12. [Lives System](#12-lives-system)
13. [Coin Economy](#13-coin-economy)
14. [Power-up System](#14-power-up-system)
15. [Shop System](#15-shop-system)
16. [Save/Load System](#16-saveload-system)
17. [Audio System](#17-audio-system)
18. [Visual Effects & Animations](#18-visual-effects--animations)
19. [UI Components](#19-ui-components)
20. [Tutorial System](#20-tutorial-system)
21. [Monetization Systems](#21-monetization-systems)
22. [Background & Atmosphere](#22-background--atmosphere)
23. [Scene Transitions](#23-scene-transitions)
24. [Mobile Platform Configuration](#24-mobile-platform-configuration)
25. [Complete File Inventory](#25-complete-file-inventory)
26. [Testing Checklist](#26-testing-checklist)
27. [Monetization Integration Points](#27-monetization-integration-points)

---

## 1. PROJECT OVERVIEW

### 1.1 Game Description
A casual Match-3 tile puzzle game where players swap adjacent tiles to create
lines of 3 or more matching tiles. Players complete levels by reaching score
targets within a limited number of moves. The game features special tiles,
power-ups, a coin economy, and monetization through rewarded ads and in-app
purchases.

### 1.2 Target Platform
- Primary: Android
- Secondary: iOS
- Development: Flutter with Flame game engine

### 1.3 Technical Stack
| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3.x |
| Game Engine | Flame 1.x |
| State Management | Provider or Riverpod |
| Persistence | SharedPreferences or Hive |
| Audio | flame_audio (audioplayers) |
| Ads | google_mobile_ads (AdMob) |
| IAP | in_app_purchase |
| Analytics | firebase_analytics |
| Crash Reporting | firebase_crashlytics |
| Push Notifications | firebase_messaging |

### 1.4 Screen Orientation
- Portrait only (locked)
- Base resolution: 720 × 1280 logical pixels

### 1.5 Minimum Requirements
- Android: API 24 (Android 7.0)
- iOS: 14.0
- RAM: 2GB minimum
- Target FPS: 60

---

## 2. ARCHITECTURE & PROJECT STRUCTURE

### 2.1 Directory Structure
lib/
├── main.dart
├── app.dart
│
├── core/
│ ├── constants.dart # All game constants
│ ├── game_config.dart # Level configs, difficulty curves
│ └── extensions.dart # Utility extensions
│
├── models/
│ ├── tile_model.dart # Tile data (type, position, special)
│ ├── level_model.dart # Level configuration data
│ ├── save_data.dart # Serializable save state
│ └── shop_item.dart # Shop item definitions
│
├── engine/
│ ├── board.dart # Board logic (grid, swap, match)
│ ├── match_finder.dart # Match detection algorithm
│ ├── cascade_processor.dart # Gravity, refill, chain logic
│ ├── special_tile_logic.dart # Special tile effects & combos
│ └── input_handler.dart # Touch/swipe detection
│
├── game/
│ ├── match_game.dart # Main Flame Game class
│ ├── tile_component.dart # Flame component for a single tile
│ ├── board_component.dart # Flame component for the board
│ ├── particle_component.dart # Burst/sparkle particles
│ └── background_component.dart # Animated background
│
├── screens/
│ ├── splash_screen.dart
│ ├── main_menu_screen.dart
│ ├── level_select_screen.dart
│ ├── game_screen.dart # Wraps the Flame game widget
│ ├── shop_screen.dart
│ └── settings_screen.dart
│
├── widgets/
│ ├── hud_overlay.dart # Score, moves, coins overlay
│ ├── popup_widget.dart # Win/Lose/Confirm popups
│ ├── level_button.dart # Level select button
│ ├── power_up_bar.dart # In-game power-up buttons
│ └── progress_bar.dart # Score progress bar
│
├── services/
│ ├── save_service.dart # Save/load persistence
│ ├── audio_service.dart # Sound effect management
│ ├── ad_service.dart # Rewarded ad management
│ ├── purchase_service.dart # IAP management
│ ├── notification_service.dart # Push notifications
│ └── analytics_service.dart # Event tracking
│
├── providers/
│ ├── game_state_provider.dart
│ ├── save_provider.dart
│ ├── shop_provider.dart
│ └── settings_provider.dart
│
└── utils/
├── colors.dart # Color palette
├── fonts.dart # Font definitions
└── haptics.dart # Haptic feedback helper


assets/
├── images/
│ ├── tiles/ # Tile sprite sheets (if using sprites)
│ ├── ui/ # UI elements
│ ├── backgrounds/ # Background images
│ └── icons/ # App icon, power-up icons
├── audio/
│ ├── sfx/ # Sound effects (or generate procedurally)
│ └── music/ # Background music
└── fonts/
└── *.ttf # Custom fonts

text
text

### 2.2 Architecture Pattern
Use a layered architecture:

Screens (Flutter widgets)
↕
Game Layer (Flame components)
↕
Engine Layer (pure Dart game logic — no UI dependency)
↕
Models & Services (data, persistence, platform APIs)

text
text

**Critical principle:** The engine layer (board.dart, match_finder.dart,
cascade_processor.dart, special_tile_logic.dart) must be pure Dart with ZERO
Flame or Flutter dependencies. This makes it testable and reusable.

---

## 3. SCREEN FLOW & NAVIGATION

### 3.1 Screen Map
Splash Screen (auto-transitions after 1.5s)
│
▼
Main Menu
├── PLAY ──────────► Level Select
├── SHOP ──────────► Shop Screen
└── SOUND toggle (inline)


Level Select
├── BACK ──────────► Main Menu
├── SHOP ──────────► Shop Screen
├── Level button ──► Game Screen (if unlocked + has lives)
└── No lives ──────► No-Lives Popup
├── Watch Ad → +1 Life
├── 300 Coins → +3 Lives
└── Close


Game Screen
├── WIN popup
│ ├── RETRY ────► reload Game Screen (same level)
│ ├── NEXT ─────► reload Game Screen (level + 1)
│ └── MENU ─────► Level Select
│
├── LOSE popup
│ ├── Watch Ad → +5 Moves (continue playing)
│ ├── RETRY ────► reload Game Screen
│ └── MENU ─────► Level Select
│
├── BACK ──────────► Level Select
└── RESTART ───────► reload Game Screen


Shop Screen
├── BACK ──────────► Main Menu
├── Any BUY button ► Confirmation Popup
│ ├── CANCEL
│ └── BUY → execute purchase
└── (scrollable content)

text
text

### 3.2 Navigation Implementation
Use Flutter's Navigator with custom fade transitions. Every scene change
goes through a transition manager that performs:

1. Fade overlay to opaque black (0.25 seconds)
2. Navigate to target screen
3. Fade overlay from opaque to transparent (0.25 seconds)

The transition overlay is a black `ColorFiltered` or `AnimatedOpacity` widget
placed above all content using a Stack.

### 3.3 Daily Reward
On app launch (Main Menu), check if daily reward is available. If today's
date differs from the stored `lastDaily` date, show a popup after 0.5s delay:
- Title: "DAILY REWARD!"
- Reward: +1 Life + 100 Coins
- Button: "CLAIM"
- On claim: update `lastDaily` to today, add rewards, close popup

---

## 4. CORE GAMEPLAY — THE BOARD

### 4.1 Board Dimensions
- Grid: 8 columns × 8 rows
- Cell size: 76 logical pixels
- Board pixel size: 608 × 608
- Board is horizontally centered in the 720px-wide viewport
- Board vertical position: starts at Y=240 (leaving room for HUD above)

### 4.2 Board Offset Calculation
```dart
boardOffsetX = (viewportWidth - cols * tileSize) / 2
boardOffsetY = 240.0

4.3 Board State
The board is represented as a 2D array:

text
text
List<List<TileModel?>> grid = List.generate(8, (_) => List.filled(8, null));

Each cell holds a TileModel? reference. null means the cell is empty
(during gravity/clear operations).


4.4 Board Background Rendering
Draw the following behind the tiles:


1.Dark panel: Rounded rectangle with Color(0, 0, 0, 0.35), 10px margin
around the grid area, with a subtle Color(1, 1, 1, 0.08) border (2px)
2.Checkerboard cells: For each cell, draw a slightly lighter or darker
rectangle. Even cells Color(1, 1, 1, 0.06), odd cells Color(1, 1, 1, 0.03)

4.5 Coordinate Conversion Functions
Implement these helpers:


Function	Input	Output	Description
gridToWorld(col, row)	grid coords	world pixel coords	boardOffset + (col * tileSize, row * tileSize)
worldToGrid(worldPos)	world pixel coords	Vector2(col, row) or (-1, -1) if outside	Converts tap position to grid cell
isInBounds(col, row)	grid coords	bool	Returns false if outside 8×8
isAdjacent(a, b)	two grid positions	bool	Manhattan distance == 1


5. TILE SYSTEM

5.1 Tile Model
dart
dart
class TileModel {
  int tileType;       // 0–4 (color index)
  int gridCol;
  int gridRow;
  SpecialType specialType;  // NONE, STRIPED_H, STRIPED_V, WRAPPED, COLOR_BOMB
}

5.2 Tile Types (Colors & Symbols)
Index	Color	Hex	Symbol	Description
0	Red	#E74C3C	● (circle)	
1	Blue	#3498DB	■ (square)	
2	Green	#2ECC71	▲ (triangle)	
3	Yellow	#F1C40F	◆ (diamond)	
4	Purple	#9B59B6	★ (star)	

The number of active types varies by level:

Levels 1–2: 4 types (indices 0–3)
Levels 3+: 5 types (indices 0–4)

5.3 Tile Visual Rendering
Each tile is drawn as a styled rounded rectangle:


1.Drop shadow: Offset (2, 3) from body, Color(0, 0, 0, 0.30), filled
2.Body: Filled rectangle with the tile's color, 3px padding from cell edge
3.Highlight band: Top 38% of body, color lightened by 35%, inset 3px
on each side
4.Border: 2px stroke, color darkened by 30%
5.Selection glow: When selected — white 3px outer stroke at +3px growth,
then a yellow-tinted 1.5px stroke at +5px growth
6.Symbol: Centered text character using the fallback font, size = 36%
of tile size, white at 88% opacity

5.4 Special Tile Visuals

Striped Horizontal
Three horizontal white lines across the tile
Center line: 3px thick, 85% opacity, pulsing
Two flanking lines: 1.5px thick, 40% opacity

Striped Vertical
Three vertical white lines (same style as horizontal but rotated)

Wrapped
3px glowing border around tile at 45% opacity, pulsing
Four corner squares (7×7px) filled white at 75% opacity

Color Bomb
Body color cycles through HSV hue based on elapsed time (hue = time * 0.25 mod 1.0)
Pulsing outer glow border (2px, white at 50%)
Five small colored dots orbit the tile center at radius = 28% of tile size
Symbol changes to ✦ instead of the normal tile symbol
Color bombs do NOT match with other tiles by type

5.5 Tile Animation States
State	Visual	Duration
Idle	Normal static draw	-
Selected	White glow + yellow outer glow	Until deselected
Swapping	Position tween to target	0.18s ease-out cubic
Shrinking (clear)	Scale → (0,0) + opacity → 0	0.22s ease-in back
Falling (gravity)	Position tween downward	0.10s + 0.04s per row distance, bounce
Dropping (refill)	Position tween from above	0.10s + 0.035s per row distance, bounce, staggered
Special creation	Scale pop: 0.4 → 1.2 → 1.0	0.12s + 0.10s
Pulsing (special idle)	Continuous _draw() updates at 60fps	Ongoing

5.6 Tile Component (Flame)
Create a Flame PositionComponent that:

Holds a TileModel reference
Has onTapDown handler for selection
Renders using Flame's Canvas (equivalent to _draw())
Updates animation state in update(double dt)
Uses ScaleEffect, MoveEffect, SequenceEffect for transitions


6. INPUT SYSTEM

6.1 Supported Input Methods
1.Tap-Tap: Tap one tile to select it, tap an adjacent tile to swap
2.Swipe: Press and drag from one tile in a direction to swap with neighbor

6.2 Input Flow
text
text
Pointer Down
    │
    ├─ Record position and tile under finger
    ├─ Set pointerHeld = true
    │
Pointer Move (while held)
    │
    ├─ Calculate distance from down position
    ├─ If distance > SWIPE_THRESHOLD (28px):
    │   ├─ Determine swipe direction (up/down/left/right)
    │   ├─ Set pointerHeld = false
    │   └─ Execute swap attempt in that direction
    │
Pointer Up
    │
    ├─ If pointerHeld still true (finger didn't move much):
    │   ├─ This is a TAP
    │   ├─ If no tile selected: select this tile
    │   ├─ If same tile tapped: deselect
    │   └─ If different adjacent tile: attempt swap
    │       If different non-adjacent tile: change selection
    │
    └─ Set pointerHeld = false

6.3 Input Blocking
All input is IGNORED when:

isProcessing == true (animations or cascade in progress)
popupActive == true (win/lose/confirmation popup showing)
powerMode == PowerMode.HAMMER and swipe detected (only taps allowed in hammer mode)

6.4 Swipe Threshold
const SWIPE_THRESHOLD = 28.0 logical pixels. If the finger moves less than
this distance, it counts as a tap. If more, it counts as a swipe.


6.5 Direction Calculation
dart
dart
Vector2 direction = currentPos - downPos;
if (direction.x.abs() > direction.y.abs()) {
    // Horizontal swipe
    return direction.x > 0 ? Vector2(1, 0) : Vector2(-1, 0);
} else {
    // Vertical swipe
    return direction.y > 0 ? Vector2(0, 1) : Vector2(0, -1);
}


7. MATCH DETECTION ALGORITHM

7.1 Overview
The match finder scans the entire board for horizontal and vertical runs of
3+ consecutive tiles of the same type. It then classifies matches into
special tile categories based on shape and length.


7.2 Finding Runs

Horizontal Runs
For each row, iterate left to right tracking a "run start" index.
When the current tile type differs from the run start type (or we reach
the end of the row):

If run length ≥ 3: record the run as a list of (col, row) positions
Reset run start to current position

Color bombs at a position should NOT be counted as matching with neighbors.


Vertical Runs
Same algorithm but iterate top to bottom for each column.


7.3 Match Classification (Priority Order)

Given all horizontal runs and vertical runs, classify matches:


Step 1: L/T Shapes → WRAPPED
For every pair (h_run, v_run):

If they share at least one position (intersection)
Mark the intersection position as WRAPPED
Mark both runs as "consumed" (won't generate striped tiles)

Step 2: 5+ Runs → COLOR BOMB
For every unconsumed run with length ≥ 5:

Mark a position as COLOR_BOMB
Prefer the swap position if it's part of the run, otherwise use center
Mark run as consumed

Step 3: 4-Runs → STRIPED
For every unconsumed run with length == 4:

If horizontal run → mark as STRIPED_H (horizontal stripes)
If vertical run → mark as STRIPED_V (vertical stripes)
Prefer swap position, otherwise center

Step 4: All matched positions
All positions in all runs (regardless of special classification) are added
to the "clear set" EXCEPT positions that will become special tiles.


7.4 Output
dart
dart
class MatchInfo {
  List<Vector2> clearPositions;      // tiles to remove
  Map<Vector2, SpecialType> specials; // tiles to transform into specials
}

7.5 Color Bomb Matching Rule
Color bombs do NOT participate in normal color matching. When scanning for
runs, skip positions that contain color bombs. Color bombs can only be
activated by being swapped with another tile (or by another special tile
effect).



8. CASCADE SYSTEM

8.1 The Cascade Loop
After a successful swap, the cascade loop runs:


text
text
while (depth < 25) {
    1. Find all matches (using match detection algorithm)
    2. If no matches found: break

    3. Increment combo counter
    4. Calculate points: matchedCount × BASE_POINTS × comboMultiplier

    5. Separate matched tiles into:
       a. Tiles to clear (normal matches)
       b. Tiles to transform (specials)

    6. Expand special tile chain reactions (see section 9)

    7. Play clear animation (shrink + burst particles)

    8. Create special tiles at marked positions

    9. Apply gravity (collapse columns downward)

    10. Refill empty spaces with new random tiles

    11. Wait 0.12 seconds (settle pause)

    depth++;
}

8.2 Gravity Algorithm
For each column (left to right):

1.Start from bottom row, scan upward
2.Track a "write pointer" starting at the bottom
3.For each non-null tile found:
If it's not already at the write pointer position:
Move it down to the write pointer position in the grid array
Clear its old position
Update its grid coordinates
Create a fall animation (distance-based duration, bounce easing)
Decrement write pointer

8.3 Refill Algorithm
For each column (left to right):

1.Count how many null cells remain at the top of the column
2.For each null cell (top to bottom):
Create a new tile with random type
Place it at a position above the visible board (negative row index)
Add to grid at the correct position
Animate dropping in with:
Staggered delay (based on drop index within column)
Distance-based duration
Bounce easing
Slight random vertical offset for visual variety

8.4 Refill Type Selection
New tiles during refill use simple random type selection:
randi() % numTypes


Unlike board generation, refill does NOT prevent matches — matches created
by refill tiles trigger the next cascade iteration, which is the desired
behavior.


8.5 Timing Constants
Animation	Duration	Easing
Clear (shrink)	0.22s	ease-in, back
Gravity fall	0.10s + 0.04s × distance	ease-in, bounce
Refill drop	0.10s + 0.035s × distance	ease-in, bounce
Refill stagger	0.03s × dropIndex	delay
Settle pause	0.12s	linear


9. SPECIAL TILES & COMBOS

9.1 Special Tile Types

Type	Created By	Activation	Effect
STRIPED_H	4 horizontal match	Matched in a group	Clears entire ROW
STRIPED_V	4 vertical match	Matched in a group	Clears entire COLUMN
WRAPPED	L or T shape match	Matched in a group	3×3 area explosion
COLOR_BOMB	5+ match	Swapped with any tile	Clears ALL tiles of that color

9.2 Special Tile Activation
When a special tile is part of a match (cleared normally):

1.It is NOT cleared with the normal tiles
2.Its effect is triggered instead
3.Effect tiles are added to the clear set

9.3 Special Effect Definitions

Striped Horizontal Effect
When activated at position (col, row):

Add all positions (c, row) for c in 0..7 where c != col

Striped Vertical Effect
When activated at position (col, row):

Add all positions (col, r) for r in 0..7 where r != row

Wrapped Effect
When activated at position (col, row):

Add all positions (col+dc, row+dr) where dc ∈ {-1, 0, 1}, dr ∈ {-1, 0, 1}
excluding (0, 0), only if in bounds

Color Bomb Effect (standalone activation)
When swapped with a normal tile of type T:

Find all tiles of type T on the board
Add all their positions to the clear set
Exclude the color bomb's own position (it's consumed)

9.4 Special + Special Combos

Color Bomb + Color Bomb
Effect: WIPE ENTIRE BOARD
All non-null positions are added to clear set
Status text: "★★ BOARD WIPE! ★★"

Color Bomb + Striped Tile
Effect: All tiles of the striped tile's color become striped tiles
(same H/V direction), then ALL of them activate simultaneously
Process:
1.Find all tiles of target color
2.Change their special type to match the striped tile's special
3.Wait 0.35s for visual feedback
4.Expand all effects (recursive chain)
5.Clear all affected tiles

Color Bomb + Wrapped Tile
Same as above but all target-color tiles become wrapped, then all explode

Striped + Striped
Both effects activate: row clear + column clear (cross pattern)

Striped + Wrapped
Both effects activate simultaneously

Wrapped + Wrapped
Both 3×3 explosions activate simultaneously

General Rule
When two special tiles are swapped:

1.Collect effects from BOTH tiles
2.Combine into one set of affected positions
3.Expand recursively (depth limit: 40 iterations)
4.Clear all affected positions

9.5 Recursive Special Expansion
When clearing tiles, if any cleared tile is itself a special tile, its
effect must also trigger. This creates chain reactions.


text
text
expandSpecials(initialPositions):
    toClear = set(initialPositions)
    queue = list(initialPositions)
    depth = 0

    while queue not empty AND depth < 40:
        pos = queue.removeFirst()
        tile = grid[pos]

        if tile is null or tile.special == NONE:
            continue

        effectPositions = getSpecialEffect(pos, tile.special)

        for each effectPos in effectPositions:
            if effectPos not in toClear:
                toClear.add(effectPos)
                queue.add(effectPos)

        depth++

    return toClear

9.6 Special Tile Creation
When a match is classified as producing a special tile:

1.The matched positions are cleared (shrunk + burst)
2.EXCEPT the position that becomes the special
3.At that position, a new tile is created with:
The same color as the original tile at that position
The assigned special type
4.A pop animation plays: scale 0.4 → 1.2 → 1.0


10. LEVEL SYSTEM & PROGRESSION

10.1 Level Configuration
Each level is defined by:

dart
dart
class LevelConfig {
  int levelNumber;
  int targetScore;
  int maxMoves;
  int numTileTypes;     // 4 or 5
  // Future: obstacles, board shape, special objectives
}

10.2 Level Configuration Formula
dart
dart
LevelConfig getLevelConfig(int level) {
  return LevelConfig(
    levelNumber: level,
    targetScore: 300 + (level - 1) * 200,
    maxMoves: (30 - (level - 1)).clamp(15, 30),
    numTileTypes: level <= 2 ? 4 : 5,
  );
}

10.3 Difficulty Curve
Level	Target Score	Moves	Tile Types	Difficulty
1	300	30	4	Tutorial
2	500	29	4	Easy
3	700	28	5	Medium
4	900	27	5	Medium
5	1,100	26	5	Medium-Hard
6	1,300	25	5	Hard
10	2,100	21	5	Hard
15	3,100	16	5	Very Hard
16+	3,300+	15 (min)	5	Expert

10.4 Board Generation (No Initial Matches)
When generating a new board, for each cell (scanning left-to-right, top-to-bottom):

1.Pick a random tile type
2.Check if it would create a horizontal match (check 2 tiles to the left)
3.Check if it would create a vertical match (check 2 tiles above)
4.If either check passes, pick a different random type
5.Repeat up to 100 attempts
6.Place the tile

10.5 Win Condition
After a move (successful swap + cascade completion):

If score >= targetScore: level is WON

10.6 Lose Condition
After a move:

If movesRemaining <= 0 AND score < targetScore: level is LOST

10.7 Star Rating
Based on score-to-target ratio:

Ratio	Stars
< 1.0	0 (only on fail)
1.0 – 1.49	★☆☆ (1 star)
1.5 – 1.99	★★☆ (2 stars)
≥ 2.0	★★★ (3 stars)

10.8 Level Unlocking
Level 1 is always unlocked
Level N is unlocked when level N-1 has been completed (any star count)
Maximum 50 levels at launch

10.9 Level Select Map
5 columns grid layout
Scrollable vertically
Each button shows:
Level number
Star rating (★ earned, ☆ unearned)
Visual style varies by state:
3 stars: gold border, dark gold background
2 stars: green border, dark green background
1 star: dark green border
Next unlocked level: blue-gray background, subtle gold border
Locked: dark gray, 🔒 icon, disabled


11. SCORING SYSTEM

11.1 Base Points
text
text
const BASE_POINTS = 10

11.2 Points Per Match
text
text
points = matchedTileCount × BASE_POINTS × comboMultiplier

11.3 Combo Multiplier
First match in a cascade: combo = 1
Each subsequent chain in the same cascade: combo increments by 1
Example: 5 tiles matched in a 3-chain = 5 × 10 × 3 = 150 points

11.4 Score Popup
A floating label appears at the center of the matched tiles:

Text: "+{points}"
Font size: 22 + (combo × 4) pixels (gets bigger with combos)
Color:
Combo 1: Gold (#F0C040)
Combo 2: Orange (#FF8C00)
Combo 3+: Red (#FF4444)
Animation: Float upward 55px over 0.75s (ease-out cubic), fade out starting at 0.3s

11.5 Coin Earning
Per matched tile: +1 coin
Per level completion: +50 coins (1+ stars) or +100 coins (3 stars)
Coins earned during a failed attempt are KEPT


12. LIVES SYSTEM

12.1 Configuration
text
text
MAX_LIVES = 5
REGEN_TIME = 1200 seconds (20 minutes per life)

12.2 Life Consumption
A life is consumed when:

A level is LOST (not when won)
A level is played (optionally — depends on design choice; current: only on lose)

12.3 Life Regeneration
On each app foreground event and periodically (every second in UI):
Calculate elapsed time since lastLifeTime
Lives gained = elapsed / REGEN_TIME (integer division)
Add gained lives (capped at MAX_LIVES)
Update lastLifeTime accordingly

12.4 Time Display
Show countdown to next life:

text
text
secsRemaining = REGEN_TIME - ((now - lastLifeTime) % REGEN_TIME)
display = "${mins}:${secs.toString().padLeft(2, '0')}"

12.5 Life Recovery Options
Method	Cost	Reward
Watch rewarded ad	Free (time)	+1 life
Spend coins	300 coins	+3 lives
Wait for regeneration	20 min	+1 life
Daily reward	Free (once/day)	+1 life
Shop purchase	via coin packs	Indirect

12.6 No-Lives Guard
When player taps a level with 0 lives:

1.Show popup: "NO LIVES LEFT!"
2.Show countdown to next life
3.Offer three options:
"🎁 WATCH AD → +1 LIFE" (if ads not removed)
"💰 300 COINS → +3 LIVES"
"CLOSE"


13. COIN ECONOMY

13.1 Earning
Source	Amount	Frequency
Match (per tile cleared)	1 coin	Every match
Level win (1+ stars)	50 coins	Per win
Level win (3 stars)	100 coins	Per win
Daily reward	100 coins	Once per day
Coin pack (IAP)	1,000–10,000	Per purchase
Starter pack	5,000	One-time

13.2 Spending
Item	Cost	Category
Hammer power-up	50 coins	Power-up
Shuffle power-up	30 coins	Power-up
Extra Moves power-up	40 coins	Power-up
3 lives recovery	300 coins	Lives
Hammer pack (×5)	400 coins	Bulk power-up
Shuffle pack (×5)	600 coins	Bulk power-up
Extra Moves pack (×5)	800 coins	Bulk power-up

13.3 Initial Balance
New players start with 500 coins.


13.4 Coin Persistence
Coins are saved after every change (earning or spending).



14. POWER-UP SYSTEM

14.1 Power-up Definitions

Hammer (🔨)
Effect: Player taps any tile on the board → that tile is destroyed
Usage: Before or during a level, on the player's turn
Does NOT cost a move
Trigger flow:
1.Player taps Hammer button
2.If no free hammers, check coins (auto-buy 1 for 100 coins if possible)
3.Enter HAMMER mode
4.Board border turns orange
5.Status text: "🔨 TAP A TILE TO DESTROY"
6.Tap Hammer button again or tap outside board to cancel
7.Tap a tile → execute hammer
8.Swiping is DISABLED during hammer mode
9.After hammer: tile destroyed → gravity → refill → cascade → exit hammer mode

Shuffle (🔀)
Effect: All tile types on the board are randomly reassigned
Does NOT cost a move
Guarantees no matches exist after shuffle (fix algorithm loops until clean)
Animation:
1.All tiles shrink to 30% scale (0.15s)
2.Types are shuffled and reassigned
3.Fix any accidental matches by re-randomizing conflicting tiles
4.All tiles grow back to 100% scale (0.15s)

Extra Moves (⏱ / +5)
Effect: Adds 5 to movesRemaining
Does NOT cost a move
Simple instant effect with "+5 moves!" status message

14.2 Power-up Button Display
Below the board, four buttons in a row:


Button	Default Icon	Stock > 0	Stock = 0
Hammer	🔨	"🔨 ×{count}"	"🔨 {HAMMER_COST}💰"
Shuffle	🔀	"🔀 ×{count}"	"🔀 {SHUFFLE_COST}💰"
Extra Moves	+5	"+5 ×{count}"	"+5 {MOVES_COST}💰"
Restart	↺	"↺"	"↺"

14.3 Power-up Costs (Fallback When Stock = 0)
Power-up	Coins Required
Hammer	100 coins
Shuffle	150 coins
Extra Moves	200 coins

If player has 0 stock AND insufficient coins → show "Need {cost} coins for {name}!"



15. SHOP SYSTEM

15.1 Shop Sections

Section 1: Your Inventory
A 4-column grid panel showing current stock:

Column	Icon	Label	Value
1	💰	Coins	Current coin count
2	🔨	Hammer	Current hammer stock
3	🔀	Shuffle	Current shuffle stock
4	⏱	+5 Moves	Current moves stock

Section 2: Power-ups (Buy with Coins)
Item	Description	Price
🔨 Hammer	"Destroys one tile on the board. Useful for breaking tough spots!"	💰 50
🔀 Shuffle	"Shuffles all tiles randomly. No move is consumed!"	💰 30
⏱ Extra Moves	"Adds 5 extra moves to your remaining move count."	💰 40

Section 3: Coin Packs (Simulated IAP)
Pack	Price	Badge
💰 1,000 Coins	$0.99	-
💰 3,000 Coins	$2.99	⭐ BEST VALUE
💰 10,000 Coins	$6.99	-

Section 4: Premium
Item	Price	Notes
🚫 Remove All Ads	$2.99	One-time purchase, persists forever

Section 5: Starter Pack (One-Time)
Only visible if starterSeen == false
Contents: 5,000 coins + 5× Hammer + 5× Shuffle + 5× Extra Moves
Price: $1.99
Disappears permanently after purchase

15.2 Purchase Confirmation Popup
Every purchase (coin spending AND simulated IAP) shows a confirmation popup:


Layout:

text
text
┌──────────────────────────────────┐
│       CONFIRM PURCHASE           │
│                                  │
│         {Item Name}              │
│                                  │
│    {Item Description}            │
│                                  │
│    {Price / Cost}                │
│                                  │
│       [ CANCEL ]  [ BUY ]       │
└──────────────────────────────────┘

Behavior:

CANCEL: close popup, no purchase
BUY: close popup, execute purchase callback
If purchase succeeds: play "reward" sound, flash success message, update inventory
If purchase fails (insufficient coins): play "lose" sound, flash error message

15.3 Purchase Messages
Result	Message	Color
Power-up bought	"+1 {name} purchased!"	Green
Not enough coins	"Not enough coins! Need 💰 {cost}"	Red
IAP bought	"+{amount} 💰 purchased!"	Green
Ads removed	"Ads removed!"	Green
Starter bought	"Starter Pack purchased!"	Green


16. SAVE/LOAD SYSTEM

16.1 Save Data Structure
dart
dart
class SaveData {
  int version;              // Schema version (current: 2)
  int currentLevel;         // Highest unlocked level
  Map<int, LevelRecord> levels;  // {levelNumber: {stars, score}}
  int lives;                // Current lives (0–5)
  double lastLifeTime;      // Unix timestamp of last life change
  String lastDaily;         // Date string of last daily claim (YYYY-MM-DD)
  bool soundEnabled;        // Audio on/off
  int coins;                // Current coin balance
  int powerHammer;          // Free hammer count
  int powerShuffle;         // Free shuffle count
  int powerMoves;           // Free extra-moves count
  bool adsRemoved;          // Premium flag
  bool starterSeen;         // Starter pack purchased flag
}

class LevelRecord {
  int stars;                // Best star rating (0–3)
  int score;                // Best score
}

16.2 Persistence Method
Use SharedPreferences (simple key-value) or Hive (faster for complex data).
Store as a single JSON string under key "match3_save".


16.3 Save Triggers
Save after every state change:

Level completion
Life consumption
Life regeneration
Coin earning or spending
Power-up earning or spending
Settings change
Daily reward claim
Any IAP

16.4 Load Behavior
On app start:

1.Read save data from storage
2.If no save exists: use defaults (500 coins, 5 lives, 3/2/1 power-ups, level 1)
3.If save exists: parse JSON, fill in missing keys with defaults (for forward compatibility)
4.Immediately sync lives (check regeneration elapsed time)

16.5 Default Values
Field	Default
currentLevel	1
levels	{} (empty)
lives	5
lastLifeTime	now
lastDaily	""
soundEnabled	true
coins	500
powerHammer	3
powerShuffle	2
powerMoves	1
adsRemoved	false
starterSeen	false


17. AUDIO SYSTEM

17.1 Sound Effect Library
All sounds are procedurally generated as short sine-wave tones with
envelope shaping. This eliminates the need for audio asset files.


Sound	Duration	Frequency	Description
click	0.04s	1400 Hz	Button tap
swap	0.06s	1000 Hz	Tile swap
match	0.10s	880 Hz	Tiles matched
combo	0.13s	800→1600 Hz sweep	Chain reaction
special	0.18s	1200 Hz	Special tile created
star	0.12s	1320 Hz	Star earned
bomb	0.25s	200→800 Hz sweep	Color bomb / big effect
win	0.48s	C5-E5-G5-C6 jingle	Level complete (4 notes)
lose	0.40s	400→180 Hz sweep	Level failed
reward	0.30s	E5-G5-C6 jingle	Reward received (3 notes)

17.2 Sound Generation Algorithm
dart
dart
AudioData generateTone(double duration, double frequency) {
    int sampleRate = 22050;
    int numSamples = (duration * sampleRate).toInt();

    for (int i = 0; i < numSamples; i++) {
        double t = i / sampleRate;
        double progress = i / numSamples;
        double envelope = pow(1.0 - progress, 2.0);  // quadratic decay
        double sample = sin(2 * PI * frequency * t) * envelope * 0.5;
        // Convert to 16-bit PCM and store
    }
}

For sweeps: interpolate frequency linearly from f0 to f1 over the duration.
For jingles: concatenate multiple tone segments at different frequencies.


17.3 Dynamic Combo Pitch
Optionally increase the pitch of match sounds based on combo level:

text
text
pitchScale = 1.0 + (comboLevel * 0.1)

17.4 Sound Toggle
A boolean soundEnabled in save data. All sound playback checks this flag
before playing.


17.5 Sound Trigger Points
Event	Sound
Button tap (any screen)	click
Tile swap initiated	swap
Match found (combo 1)	match
Chain combo (combo 2+)	combo
Special tile created	special
Color bomb / board wipe	bomb
Level complete	win
Level failed	lose
Daily reward claimed	reward
Shop purchase success	reward
Shop purchase fail	lose
Power-up activated	special


18. VISUAL EFFECTS & ANIMATIONS

18.1 Burst Particles
When tiles are cleared, spawn burst particles at each tile's center.


Per tile: Spawn 5 particles.


Each particle:

A Node2D/Component at the tile center + random offset (-10 to +10 px in each axis)
Renders an expanding circle that:
Starts at radius 3px, grows to random max (16–28px)
Starts at random color from tile colors + white
Alpha: starts at 0.65, fades to 0 over 0.35 seconds
Self-destructs after 0.35s

18.2 Swap Animation
Two tiles animate simultaneously:

Duration: 0.18s
Easing: ease-out, cubic
Property: position (from current to target)

18.3 Clear Animation
Matched tiles animate simultaneously:

Scale: (1,1) → (0,0), 0.22s, ease-in, back easing
Opacity: 1.0 → 0.0, 0.22s
After animation: queue_free() / remove from component tree

18.4 Gravity Animation
Falling tiles animate:

Position: current → target (below)
Duration: 0.10s + (0.04s × number of rows fallen)
Easing: ease-in, bounce

18.5 Refill Animation
New tiles drop in:

Position: from above the board → final position
Duration: 0.10s + (0.035s × rows to fall)
Easing: ease-in, bounce
Stagger: 0.03s × drop index within column (creates waterfall effect)
Initial position has slight random vertical offset (30–80px above calculated start)

18.6 Special Tile Creation Animation
When a matched position becomes a special tile:

New tile spawns at scale (0.4, 0.4)
Animates to (1.2, 1.2) over 0.12s
Then to (1.0, 1.0) over 0.10s
Creates a satisfying "pop" feeling

18.7 Board Entrance Animation
When a level starts, tiles cascade in from above:


text
text
For each column (0 to 7):
    For each row (7 down to 0):    // bottom rows first
        tile starts at:
            x = normal x position
            y = -(ROWS - row) × tileSize - random(30, 80)  // above board

        Animates to:
            y = normal y position

        Duration: 0.40s
        Easing: ease-in, bounce
        Delay: column × 0.04s + (ROWS-1-row) × 0.025s

This creates a diagonal waterfall wave from bottom-left to top-right.


18.8 Power-up Button Hover
In Flutter, use InkWell or GestureDetector with animated container
for press/hover states.


18.9 Hammer Mode Visual
When hammer mode is active:

Board panel gets a pulsing orange border (Color #F39C12, 4px, 50% alpha)
Status text changes to "🔨 TAP A TILE TO DESTROY"
Tap a tile to execute, tap outside or tap hammer button again to cancel


19. UI COMPONENTS

19.1 Main Menu Layout
text
text
Position Y:
  0.10 × viewportHeight: Title "MATCH\nTHREE" (58px, gold #F0C040, centered, pulsing gently)
  +140px: Subtitle "◆ Tile Puzzle ◆" (18px, white 30% opacity)
  0.42 × viewportHeight: PLAY button (300×72, green #27AE60, 28px text)
  +82px: "Level {current}" (15px, white 30% opacity)
  0.58 × viewportHeight: SHOP button (200×48, purple #8E44AD, 18px text)
  +56px: "💰 {coins}" (16px, gold)
  0.72 × viewportHeight: Lives display (VBoxContainer, centered)
    - "♥♥♥♥♡  4 / 5" (22px)
    - "Next life in 15:42" (14px, white 35% opacity) — only if lives < max
  0.86 × viewportHeight: Sound toggle button (220×42, dark bg)

19.2 Game Screen HUD (Above Board)
text
text
Position relative to boardOffset:

  [← BACK] button (10, 10) — top-left corner
  💰 {coins} — top-right corner (18px, gold, right-aligned)

  "MATCH THREE" title (centered, Y=54, 28px, gold)

  Board top - 82px: "Level {n}" — left-aligned
  Board top - 82px: "Moves: {n}" — right-aligned, color-coded:
    - Green (#2ECC71) when > 10
    - Yellow (#F39C12) when 6–10
    - Red (#E74C3C) when ≤ 5

  Board top - 56px: "Score: {s} / {t} (+{c}💰)" — 17px, white 65%

  Board top - 34px: Status text — 13px, white 35%
    Examples: "Tap or swipe to swap tiles"
              "Match! +30"
              "COMBO x2! +80"
              "No match — swapping back"
              "🔨 TAP A TILE TO DESTROY"

  Board top - 10px: Progress bar (6px height, full board width)
    Background: Color(0.12, 0.12, 0.12)
    Fill: gradient from Red (#E74C3C) to Green (#2ECC71) based on progress
    Progress = clamp(score / targetScore, 0, 1)

19.3 Power-up Bar (Below Board)
text
text
  Power-up status label (centered, 14px, gold) — only when in power mode

  Four buttons in a row (equal width, gap 8px):
    [🔨 ×3]  [🔀 ×2]  [+5 ×1]  [↺]

  Button style: 120×44, dark background (#2C3E50), rounded 10px
  Hover: lighter (#3D566E)
  Pressed: darker (#1A252F)

19.4 Win Popup
text
text
┌───────────────────────────────────────┐
│                                       │
│         LEVEL COMPLETE!               │  (26px, gold)
│                                       │
│           ★★☆                         │  (38px, gold)
│                                       │
│         Score: 450                    │  (22px, white)
│         Target: 300                   │  (15px, white 45%)
│                                       │
│        💰 +80 coins earned            │  (18px, gold)
│        (includes 50 level bonus)      │  (12px, white 30%)
│                                       │
│    [RETRY]  [NEXT LEVEL]  [MENU]     │  (3 buttons, 10px gap)
│                                       │
└───────────────────────────────────────┘

Panel: 420×370, bg #16213E, gold border 3px, rounded 16px, padding 28px
Overlay: black 55% opacity, blocks input

Actions on win:

1.Play "win" sound
2.Haptic: heavy vibration (50ms)
3.Save level progress (stars, score)
4.Award coins (match coins + level bonus)
5.Show popup

19.5 Lose Popup
text
text
┌───────────────────────────────────────┐
│                                       │
│          OUT OF MOVES                 │  (26px, red)
│                                       │
│       Score: 180 / 300                │  (22px, white)
│                                       │
│       💰 +23 coins kept               │  (16px, gold) — if coins > 0
│                                       │
│       ♥ 4 lives remaining            │  (16px, white 50%)
│                                       │
│    [🎁 AD → +5]  [RETRY]  [MENU]     │  (ad button only if ads not removed)
│                                       │
└───────────────────────────────────────┘

Panel: 420×340, bg #1A1A2E, red border 3px, rounded 16px

Actions on lose:

1.Play "lose" sound
2.Haptic: medium vibration (25ms)
3.Deduct 1 life
4.Save coins earned during attempt
5.Show popup

Rewarded Ad Button (🎁 AD → +5):

1.Show simulated ad overlay (3-second progress bar + skip button)
2.On completion: close popup, add 5 moves, resume game
3.On cancel/fail: re-show lose popup

19.6 Level Select Info Bar
text
text
[← BACK]        SELECT LEVEL        [SHOP]

♥♥♥♥♥  5/5    15:42    💰 500
lives     timer      coins

19.7 Confirmation Popup (Shop)
text
text
┌──────────────────────────────────┐
│       CONFIRM PURCHASE           │  (18px, white 45%)
│                                  │
│        🔨 Hammer                 │  (22px, white)
│                                  │
│  Destroys one tile on the board. │  (15px, white 55%)
│  Useful for breaking tough spots!│
│                                  │
│  Cost: 💰 50 (You have: 💰 500)  │  (20px, gold)
│                                  │
│       [ CANCEL ]  [ BUY ]       │
└──────────────────────────────────┘

Panel: 400×280, bg #16213E, gold border, rounded 16px


20. TUTORIAL SYSTEM

20.1 Behavior
Shown on levels 1, 2, and 3
Only shown on FIRST attempt (if player has earned any stars on that level, skip)
Blocks all game input until dismissed
Tap anywhere to dismiss with fade-out animation (0.2s)

20.2 Tutorial Content

Level	Title	Message
1	HOW TO PLAY	"TAP two adjacent tiles to swap them.\nMatch 3 or more of the same color!"
2	HOW TO PLAY	"SWIPE on a tile to swap quickly.\nMatch 4 in a row → STRIPED tile!"
3	HOW TO PLAY	"Match 5 → COLOR BOMB!\nL-shape or T-shape → WRAPPED tile!"

20.3 Tutorial Popup Layout
text
text
┌─────────────────────────────────────┐
│                                     │
│         HOW TO PLAY                 │  (20px, gold)
│                                     │
│  TAP two adjacent tiles to swap     │  (18px, white)
│  them. Match 3 or more of the       │  (auto-wrap enabled)
│  same color!                        │
│                                     │
│       TAP TO CONTINUE               │  (13px, white 30%, pulsing)
│                                     │
└─────────────────────────────────────┘

Panel: 500×220, bg #16213E, gold border, rounded 16px
Overlay: black 55%, blocks input


21. MONETIZATION SYSTEMS

21.1 Revenue Streams

Rewarded Video Ads
Trigger	Reward	Frequency Cap
Level failed	+5 moves (continue playing)	Once per fail
No lives	+1 life	No cap
Daily reward double	×2 daily coins	Once per day

Implementation: Show a simulated ad overlay with a 3-second progress bar
and a "SKIP (test)" button. In production, replace with real AdMob
RewardedAd.load() / .show().


Gate: If adsRemoved == true, auto-grant the reward without showing ad.


In-App Purchases (Simulated)
Product ID	Name	Price	Contents
coins_1000	1,000 Coins	$0.99	1,000 coins
coins_3000	3,000 Coins	$2.99	3,000 coins
coins_10000	10,000 Coins	$6.99	10,000 coins
remove_ads	Remove Ads	$2.99	Permanent ad removal
starter_pack	Starter Pack	$1.99	5,000 coins + 5× each power-up

Implementation: Show confirmation popup, then simulate instant grant.
In production, replace with Google Play Billing / Apple StoreKit calls.


21.2 Funnel Design
text
text
Day 1:  Download → Easy levels (1-10) → Hook on core loop → No monetization pressure
Day 2:  Difficulty increases → First rewarded ad offered (on fail)
Day 3:  First hard level → "Continue?" prompt → Ad or IAP decision point
Day 7:  Starter pack offer expires → FOMO → First purchase opportunity
Day 14: Player invested → Coin pack needed → Second purchase opportunity
Day 30: Recurring needs (lives, power-ups) → Ongoing engagement

21.3 Analytics Events to Track
Event	Parameters	When
level_start	level_number	Level loads
level_complete	level_number, stars, score, moves_left	Win
level_fail	level_number, score, target	Lose
ad_watched	ad_type (rewarded), reward_type	Ad completed
iap_purchase	product_id, price	Purchase confirmed
power_up_used	power_type, level_number	Power-up activated
session_start	-	App foreground
session_end	duration	App background


22. BACKGROUND & ATMOSPHERE

22.1 Background Visual
Render behind all game content (z-index = -100):


1.
Base fill: Solid dark color Color(0.03, 0.03, 0.07)

2.
Vertical gradient bands: 12 horizontal strips spanning the viewport.
Each strip is a slightly different dark shade of purple/blue, creating
a subtle gradient effect. Alpha: 0.35

3.
Drifting glow orbs: Two large soft circles that slowly move:

Orb 1: Purple (0.18, 0.06, 0.30), center drifts with sin/cos at ~0.3 Hz
Orb 2: Blue (0.06, 0.12, 0.22), center drifts with cos/sin at ~0.3 Hz
Each orb rendered at 3 sizes: 180px, 120px, 70px with decreasing alpha (0.025, 0.019, 0.011)
4.
Floating particles: 20 small white circles:

Random start positions across viewport
Random size (1.5–3.5px)
Random alpha (0.04–0.12)
Drift upward slowly (velocity: x ∈ [-5,5], y ∈ [-10,-2])
Wrap around: when y < -10, respawn at y = 1290 with new random x

22.2 Background Animation
Update all particle positions each frame. Redraw the entire background
every frame using _draw() or Flame's render().



23. SCENE TRANSITIONS

23.1 Transition Effect
Every scene change uses a fade-to-black transition:


1.Create/show a black overlay at 0% opacity covering the full viewport
2.Animate opacity to 100% over 0.25 seconds
3.Navigate to new screen
4.Overlay starts at 100% opacity on new screen
5.Animate opacity to 0% over 0.25 seconds
6.Hide/remove overlay

23.2 Transition Guard
Only one transition can be active at a time (busy flag prevents overlapping).


23.3 Initial Scene Load
When the app first starts, show the main menu with a fade-in from black
(0.3 seconds).


23.4 Transition Routes
From	To	Trigger
Splash	Main Menu	Auto after 1.5s
Main Menu	Level Select	PLAY button
Main Menu	Shop	SHOP button
Level Select	Main Menu	← BACK button
Level Select	Shop	SHOP button
Level Select	Game	Level button tap
Game	Level Select	← BACK button
Game	Level Select	MENU button (win/lose popup)
Game (reload)	Game	RETRY/NEXT button (win/lose popup)
Shop	Main Menu	← BACK button
Shop	Main Menu	After Remove Ads or Starter purchase (reload)


24. MOBILE PLATFORM CONFIGURATION

24.1 Android Configuration
yaml
yaml
# android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 24
        targetSdkVersion 34
        applicationId "com.yourstudio.matchthree"
        versionCode 1
        versionName "1.0.0"
    }

    signingConfigs {
        release {
            storeFile file("match3.keystore")
            storePassword "..."
            keyAlias "match3"
            keyPassword "..."
        }
    }
}

Generate keystore:

bash
bash
keytool -genkey -v -keystore match3.keystore \
  -alias match3 -keyalg RSA -keysize 2048 -validity 10000

Screen orientation: Lock to portrait in AndroidManifest.xml:

xml
xml
<activity android:screenOrientation="portrait" ...>

Immersive mode: Hide navigation bar for full-screen experience.


24.2 iOS Configuration
xml
xml
<!-- Info.plist -->
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>

<key>UIRequiresFullScreen</key>
<true/>

<key>MinimumOSVersion</key>
<string>14.0</string>

24.3 Performance Targets
Metric	Target	How to Achieve
Frame rate	60 fps	Use Flame's game loop, minimize widget rebuilds
Memory	< 80 MB	Object pooling for tiles and particles
APK size	< 30 MB	No external image assets (all procedural), tree-shake
Load time	< 3s	Preload only essential assets, lazy-load shop/UI
Input lag	< 50ms	Use Flame's gesture detector, not Flutter's

24.4 Object Pooling
Create pools for frequently created/destroyed objects:

Tile components: pool of 64 (8×8 board) + extra for refills
Burst particles: pool of 100
Score popup labels: pool of 10

When an object is "destroyed," return it to the pool instead of actually
freeing it. When a new object is needed, take from pool first.



25. COMPLETE FILE INVENTORY

25.1 Scenes/Screens (Flutter)
File	Root Widget	Purpose
splash_screen.dart	StatelessWidget	App branding, auto-transition
main_menu_screen.dart	StatefulWidget	Title, Play, Shop, Lives, Daily
level_select_screen.dart	StatefulWidget	Level grid, Lives, Coins
game_screen.dart	StatefulWidget wrapping GameWidget	Board gameplay
shop_screen.dart	StatefulWidget	All shop sections

25.2 Flame Components
File	Class	Purpose
match_game.dart	FlameGame	Main game class, manages board
tile_component.dart	PositionComponent	Renders single tile
board_component.dart	Component	Board background, cell grid
particle_component.dart	Component	Burst particle effect
background_component.dart	Component	Animated background
score_popup_component.dart	Component	Floating "+N" text

25.3 Engine (Pure Dart)
File	Purpose
board.dart	Grid state, swap logic, tile management
match_finder.dart	Horizontal/vertical run detection, classification
cascade_processor.dart	Clear→gravity→refill loop
special_tile_logic.dart	Special effects, combos, chain expansion
input_handler.dart	Tap/swipe detection, threshold logic
level_config.dart	Level configuration formulas

25.4 Models
File	Purpose
tile_model.dart	Tile data (type, position, special)
level_model.dart	Level configuration data class
save_data.dart	Serializable save state
shop_item.dart	Shop item definitions

25.5 Services
File	Purpose
save_service.dart	SharedPreferences JSON persistence
audio_service.dart	Procedural sound generation and playback
ad_service.dart	Rewarded ad simulation/real integration
purchase_service.dart	IAP simulation/real integration
analytics_service.dart	Event logging
notification_service.dart	Push notification scheduling

25.6 Providers/State
File	Purpose
game_state_provider.dart	Current level state (score, moves, coins earned)
save_provider.dart	Global save data, lives, coins
shop_provider.dart	Shop state, purchase logic
settings_provider.dart	Sound toggle, preferences

25.7 Widgets (Flutter UI)
File	Purpose
hud_overlay.dart	Score, moves, coins, status, progress bar
popup_widget.dart	Win/Lose/Confirm popup builder
level_button.dart	Individual level button on select screen
power_up_bar.dart	Hammer/Shuffle/Moves/Restart buttons
transition_overlay.dart	Fade-to-black transition widget


26. TESTING CHECKLIST

26.1 Core Gameplay
 Board generates 8×8 grid with no initial matches
 Tap-tap: select tile, tap adjacent to swap
 Swipe: drag past threshold to swap in direction
 Invalid swap (no match) → tiles animate back
 Valid swap → matched tiles clear with animation
 Gravity: tiles above empty spaces fall down
 Refill: new tiles drop in from above
 Cascade: new matches auto-detect and process
 Combo counter increments per chain
 Score popups appear at match center
 Input blocked during all animations

26.2 Special Tiles
 4 horizontal → STRIPED_H tile created
 4 vertical → STRIPED_V tile created
 L-shape → WRAPPED tile at intersection
 T-shape → WRAPPED tile at intersection
 5+ horizontal → COLOR_BOMB at center
 5+ vertical → COLOR_BOMB at center
 Striped activation clears row/column
 Wrapped activation clears 3×3 area
 Color bomb + normal tile → all of that color cleared
 Color bomb + color bomb → entire board cleared
 Color bomb + striped → all target color become striped, then activate
 Color bomb + wrapped → all target color become wrapped, then activate
 Recursive chain reactions work (special clears trigger other specials)
 Special tile visual animations (pulsing, rainbow, stripes)
 Special tile creation pop animation (0.4→1.2→1.0 scale)

26.3 Level System
 Level 1: 300 target, 30 moves, 4 types
 Difficulty scales correctly per formula
 Win condition detected (score >= target)
 Lose condition detected (moves <= 0, score < target)
 Star rating: 1★ at 1.0x, 2★ at 1.5x, 3★ at 2.0x
 Level unlock progression works
 Level select shows correct star indicators
 Locked levels are disabled

26.4 Economy
 Coins earned per match (1 per tile)
 Coins earned per level win (50/100 bonus)
 Coins kept on level fail
 Power-ups purchased with coins
 Coin packs (simulated IAP) add coins
 Confirmation popup before every purchase
 Insufficient funds error handling
 Inventory panel updates after purchase
 Starter pack disappears after purchase

26.5 Power-ups
 Hammer: enter mode → tap tile → destroy → cascade
 Hammer: cancel by tapping button again or outside board
 Hammer: swiping disabled during hammer mode
 Shuffle: all tiles re-randomized, no matches remain
 Shuffle: does not consume a move
 Extra Moves: +5 added to moves remaining
 Extra Moves: does not consume a move
 Button labels show stock count or coin cost
 Auto-buy from coins when stock = 0

26.6 Lives & Time
 Start with 5 lives
 Lose deducts 1 life
 Win does NOT deduct a life
 Timer counts down to next life regeneration
 Lives regenerate after 20 minutes
 No-lives popup with recovery options
 Watch ad → +1 life
 300 coins → +3 lives
 Level buttons disabled at 0 lives

26.7 Persistence
 Progress saves after level win
 Lives save after change
 Coins save after change
 Power-ups save after change
 Settings save after change
 Daily reward date saved
 App restart restores all state
 First launch uses correct defaults

26.8 UI & Polish
 Scene transitions (fade-to-black)
 Board entrance animation (cascade in)
 Background animated (orbs + particles)
 Tutorial shows on levels 1–3 (first time only)
 Tutorial blocks input, tap to dismiss
 Daily reward popup on new day
 Haptic feedback on match, combo, win, lose
 All popups block board input
 Status text updates correctly for all states

26.9 Audio
 All 10 sounds play at correct moments
 Sound toggle mutes/unmutes all sounds
 Combo sounds have rising pitch
 No audio errors on mute

26.10 Mobile
 Runs at 60fps on mid-range Android (2021)
 Portrait orientation locked
 Immersive mode (no nav bar)
 Touch input responsive (< 50ms)
 No memory leaks after extended play
 App survives background/foreground cycle
 Save data persists across app restarts


27. MONETIZATION INTEGRATION POINTS

27.1 AdMob Integration (Rewarded Ads)
Replace simulated ad overlay with:


dart
dart
// Load ad
RewardedAd.load(
  adUnitId: 'ca-app-pub-XXXXX/XXXXX',
  request: AdRequest(),
  rewardedAdLoadCallback: RewardedAdLoadCallback(
    onAdLoaded: (ad) { _rewardedAd = ad; },
    onAdFailedToLoad: (error) { /* handle */ },
  ),
);

// Show ad
_rewardedAd.show(
  onUserEarnedReward: (ad, reward) {
    // Grant reward: +5 moves or +1 life
  },
);

Ad Unit IDs:

Use test IDs during development
Create real ad units in AdMob console for production
Separate IDs for rewarded (game fail) and rewarded (lives)

27.2 Google Play Billing / Apple StoreKit
Replace simulated IAP callbacks with real purchase flows:


dart
dart
// Query products
final products = await InAppPurchase.instance.queryProductIds([
  'coins_1000', 'coins_3000', 'coins_10000',
  'remove_ads', 'starter_pack',
]);

// Listen for purchases
InAppPurchase.instance.purchaseStream.listen((purchases) {
  for (final purchase in purchases) {
    if (purchase.status == PurchaseStatus.purchased) {
      _grantPurchase(purchase.productID);
      InAppPurchase.instance.completePurchase(purchase);
    }
  }
});

// Initiate purchase
final product = products.firstWhere((p) => p.id == productId);
InAppPurchase.instance.buyNonConsumable(
  purchaseParam: PurchaseParam(item: product),
);

Note: Coin packs are CONSUMABLE purchases (can buy multiple times).
Remove Ads and Starter Pack are NON-CONSUMABLE (one-time).


27.3 Firebase Analytics
Log events at key moments:


dart
dart
FirebaseAnalytics.instance.logEvent(
  name: 'level_complete',
  parameters: {
    'level': 5,
    'stars': 2,
    'score': 850,
    'moves_left': 3,
  },
);

27.4 Firebase Crashlytics
Initialize in main.dart. Wrap game loop in error boundary.


27.5 Push Notifications
Schedule "lives full" notification:

dart
dart
// When lives decrease below max, schedule:
// "Your lives are full! Come play!" at now + (livesToRegen * 20 minutes)

Cancel notification when app opens (lives may have already been claimed).



APPENDIX A: COLOR PALETTE

Name	Hex	Usage
Background	#080812	Screen backgrounds
Surface	#12121F	Panel backgrounds
Panel	#16213E	Popup panels
Panel Alt	#1A1A2E	Lose popup panel
Gold	#F0C040	Primary accent, titles, coins
Red	#E74C3C	Tile 0, danger, lose text
Blue	#3498DB	Tile 1
Green	#2ECC71	Tile 2, success, buy buttons
Yellow	#F1C40F	Tile 3
Purple	#9B59B6	Tile 4, premium
Dark Blue	#2C3E50	Button default
Slate	#34495E	Back buttons, secondary
Text Primary	#FFFFFF	Main text
Text Muted	rgba(255,255,255,0.35)	Secondary text
Text Faint	rgba(255,255,255,0.15)	Version info

APPENDIX B: FONT SPECIFICATIONS

Role	Size	Weight	Color
Game title (menu)	58px	Bold	Gold
Game title (in-game)	28px	Bold	Gold
Section header	15–16px	Medium	White 35%
Popup title	26px	Bold	Gold/Red
Button text	14–18px	Medium	White
HUD labels	17–22px	Regular	Various
Status text	13px	Regular	White 35%
Score popup	22–34px	Bold	Gold/Orange/Red
Body text	14–18px	Regular	White
Caption	11–13px	Regular	White 30%

Use a distinctive display font for titles (e.g., Bebas Neue, Syne, or
Montserrat) paired with a clean body font (e.g., DM Mono, Lora, or
Source Serif 4). Load via Google Fonts CDN or bundle in assets.


APPENDIX C: CONSTANTS REFERENCE

dart
dart
// Board
const COLS = 8;
const ROWS = 8;
const TILE_SIZE = 76.0;
const BOARD_Y = 240.0;
const SWIPE_THRESHOLD = 28.0;

// Scoring
const BASE_POINTS = 10;
const COIN_PER_TILE = 1;
const COIN_LEVEL_BONUS_1STAR = 50;
const COIN_LEVEL_BONUS_3STAR = 100;

// Lives
const MAX_LIVES = 5;
const REGEN_SECS = 1200.0; // 20 minutes

// Economy
const STARTING_COINS = 500;
const STARTING_HAMMER = 3;
const STARTING_SHUFFLE = 2;
const STARTING_MOVES = 1;
const SHOP_HAMMER_PRICE = 50;
const SHOP_SHUFFLE_PRICE = 30;
const SHOP_MOVES_PRICE = 40;
const POWER_HAMMER_COST = 100;  // fallback when stock = 0
const POWER_SHUFFLE_COST = 150;
const POWER_MOVES_COST = 200;
const LIFE_REFILL_COST = 300;

// Animation Durations
const SWAP_DURATION = 0.18;
const CLEAR_DURATION = 0.22;
const GRAVITY_BASE = 0.10;
const GRAVITY_PER_ROW = 0.04;
const REFILL_BASE = 0.10;
const REFILL_PER_ROW = 0.035;
const REFILL_STAGGER = 0.03;
const SETTLE_PAUSE = 0.12;
const SPECIAL_POP_FAST = 0.12;
const SPECIAL_POP_SLOW = 0.10;
const SCORE_POP_DURATION = 0.75;
const TRANSITION_DURATION = 0.25;

// Limits
const MAX_CASCADE_DEPTH = 25;
const MAX_SPECIAL_CHAIN_DEPTH = 40;
const MAX_MATCH_ATTEMPTS = 100;
const TOTAL_LEVELS = 50;
