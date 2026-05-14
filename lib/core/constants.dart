// =============================================================================
// CORE CONSTANTS
// =============================================================================

// ---- Board ----
const int boardCols = 8;
const int boardRows = 8;
const int tileSize = 76;
const double boardOffsetX = (720 - boardCols * tileSize) / 2; // 68.0
const double boardOffsetY = 240.0;

// ---- Input ----
const double swipeThreshold = 28.0;

// ---- Scoring ----
const int basePoints = 10;

// ---- Lives ----
const int maxLives = 5;
const int regenTime = 1200; // seconds (20 minutes)

// ---- Level ----
const int maxLevels = 50;

// ---- Tiles ----
const int numTileTypesTutorial = 4; // levels 1-2
const int numTileTypesFull = 5; // level 3+

// ---- Special Tile Types ----
enum SpecialType {
  none,
  stripedH,
  stripedV,
  wrapped,
  colorBomb,
}

// ---- Match classification thresholds ----
const int matchMinLength = 3;
const int matchStripeLength = 4;
const int matchBombLength = 5;

// ---- Animation Durations (seconds) ----
const double animSwap = 0.18;
const double animClear = 0.22;
const double animGravityBase = 0.10;
const double animGravityPerRow = 0.04;
const double animRefillBase = 0.10;
const double animRefillPerRow = 0.035;
const double animRefillStagger = 0.03;
const double animSettlePause = 0.12;
const double animSpecialPop1 = 0.12;
const double animSpecialPop2 = 0.10;
const double animBoardEntry = 0.40;
const double animTutorialFade = 0.2;

// ---- Cascade ----
const int maxCascadeDepth = 25;
const int maxSpecialExpansionDepth = 40;

// ---- Score Popup ----
const double scorePopupBaseSize = 22.0;
const double scorePopupComboIncrement = 4.0;
const double scorePopupFloatDistance = 55.0;
const double scorePopupDuration = 0.75;

// ---- Colors ----
const int colorRed = 0xFFE74C3C;
const int colorBlue = 0xFF3498DB;
const int colorGreen = 0xFF2ECC71;
const int colorYellow = 0xFFF1C40F;
const int colorPurple = 0xFF9B59B6;

const int colorGold = 0xFFF0C040;
const int colorDarkBg = 0xFF0A0A14;

// ---- Tile Type Enum ----
enum TileType { red, blue, green, yellow, purple }

// ---- UI Dimensions ----
const double verticalResolution = 1280.0;
const double horizontalResolution = 720.0;