// Game modes
final int GAME_LOADING = 0;
final int GAME_HOME = 1;
final int GAME_LEVEL_PREP = 2;  // 新增：關卡準備頁面
final int GAME_PLAYING = 3;
final int GAME_WIN = 4;
final int GAME_LOSE = 5;

// Speed for grid like movement
final int SPEED = 100;

// Sprites variable
final int SPRITE_SIZE = 100;

// Player variables
PImage[] playerSprites = new PImage[6];
Player p;

// Enemy variables
PImage[][] enemySprites = new PImage[3][2];
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
int enemySpawnInterval;
int lastEnemySpawnTime = 0;

// Item Variables
PImage[] itemSprites = new PImage[3];
ArrayList<Item> items = new ArrayList<Item>();
int itemSpawnInterval = 5000;
int lastItemSpawnTime = 0;

// Grid Variables
Grid grid;

// Game Variables
int gameState = GAME_HOME;
int gameStartTime = 0;
int level = 1; // Set default value
int selectedLevel = 1; // 新增：記錄選擇的關卡

// Background and UI Images
PImage titleImage;
PImage backgroundImage;

// GridIndicator Variables
ArrayList<GridIndicator> gridIndicators = new ArrayList<GridIndicator>();

// UI Manager
UI ui;

int levelDuration = 60000; // 每關60秒
int currentLevelStartTime = 0;

// 在全域變數區域添加
boolean isSpeedingUp = false;
int speedUpStartTime = 0;
boolean speedUpMessageShown = false;

// 載入相關變數
int loadingStartTime = 0;
final int LOADING_DURATION = 4000; // 修改為4秒載入時間

void setup() {
  size(1280, 720);

  // 先初始化 UI
  ui = new UI();

  // 載入圖片資源（在載入頁面之前）
  loadSprites();

  // 開始載入頁面
  gameState = GAME_LOADING;
  loadingStartTime = millis();

  println("Starting CarrotDash game...");
  println("Loading screen initialized...");
}

void draw() {
  switch(gameState) {
  case GAME_LOADING:
    // 顯示載入畫面（使用已載入的圖片）
    ui.showLoadingScreen(titleImage, backgroundImage, loadingStartTime);

    // 檢查載入是否完成
    if (millis() - loadingStartTime >= LOADING_DURATION) {
      gameState = GAME_HOME;

      // 載入完成後初始化遊戲資源
      grid = new Grid();
      p = new Player();

      println("Loading completed! Entering main menu...");
    }
    break;

  case GAME_HOME:
    // 載入完成後才顯示主選單
    ui.showHomeMenu(titleImage, backgroundImage);
    break;

  case GAME_LEVEL_PREP:
    ui.showLevelPrepScreen(selectedLevel, backgroundImage);
    break;

  case GAME_PLAYING:
    // Show background image
    if (backgroundImage != null) {
      imageMode(CORNER);
      image(backgroundImage, 0, 0, width, height);
    } else {
      background(50, 150, 50);
    }

    grid.show();

    // Spawn enemies every interval - Level 1 特別優化
    if (millis() - lastEnemySpawnTime > enemySpawnInterval) {
      ArrayList<String> enemyTypes = new ArrayList<String>();
      enemyTypes.add("pest");

      if (level == 2 || level == 3) {
        enemyTypes.add("bird");
      }
      
      String randomType = enemyTypes.get((int)random(enemyTypes.size()));

      // Level 1 特殊生成邏輯：按您的要求修改
      float spawnX, spawnY;

      if (level == 1) {
        // Level 1: 更隨機的生成位置和方向

        // Level 1 額外隨機性：10% 機率從上下生成
        if (random(1) < 0.1) {
          boolean fromTop = random(1) < 0.5;
          if (fromTop) {
            // 從上方生成
            spawnX = grid.originX + random(0, grid.cols) * grid.cellSize;
            spawnY = grid.originY - random(2, 3) * grid.cellSize; // 2-3格距離
          } else {
            // 從下方生成
            spawnX = grid.originX + random(0, grid.cols) * grid.cellSize;
            spawnY = grid.originY + (grid.playableRows + random(2, 3)) * grid.cellSize; // 2-3格距離
          }
        } else {
          // 90% 機率從左右生成
          boolean fromLeft = random(1) < 0.5;

          if (fromLeft) {
            // 從左側生成：2-3格距離
            spawnX = grid.originX - random(2, 3) * grid.cellSize; // 修改：2-3格距離
            // 垂直位置：只在可玩區域內，不包含邊界
            int randomRow = (int)random(1, grid.playableRows + 1); // 修改：不包含邊界
            spawnY = grid.originY + randomRow * grid.cellSize;
          } else {
            // 從右側生成：2-3格距離
            spawnX = grid.originX + (grid.cols + random(2, 3)) * grid.cellSize; // 修改：2-3格距離
            // 垂直位置：只在可玩區域內，不包含邊界
            int randomRow = (int)random(1, grid.playableRows + 1); // 修改：不包含邊界
            spawnY = grid.originY + randomRow * grid.cellSize;
          }
        }
      } else {
        // Level 2+ 保持原來的邏輯
        boolean fromLeft = random(1) < 0.5;

        if (fromLeft) {
          spawnX = grid.originX - 2 * grid.cellSize;
          int randomRow = (int)random(1, grid.playableRows + 1);
          spawnY = grid.originY + randomRow * grid.cellSize;
        } else {
          spawnX = grid.originX + (grid.cols + 2) * grid.cellSize;
          int randomRow = (int)random(1, grid.playableRows + 1);
          spawnY = grid.originY + randomRow * grid.cellSize;
        }
      }

      enemies.add(new Enemy(spawnX, spawnY, randomType));
      lastEnemySpawnTime = millis();

      println("Spawned " + randomType + " at (" + (int)spawnX + ", " + (int)spawnY + ")");

      // Level 1 額外機制：30% 機率連續生成
      if (level == 1 && random(1) < 0.3) {
        // 0.5-1.5秒後再生成一個
        int extraDelay = (int)random(500, 1500);
        // 記錄額外生成時間
        lastEnemySpawnTime = millis() - enemySpawnInterval + extraDelay;
        println("Level 1 bonus spawn scheduled in " + extraDelay + "ms");
      }
    }

    // Spawn items - restrict item types by level
    if (millis() - lastItemSpawnTime > itemSpawnInterval) {
      String[] itemTypes;

      // Define item types based on level
      if (level == 3) {
        itemTypes = new String[]{"flip", "star"};
      } else {
        itemTypes = new String[]{};
      }

      // Only spawn items if there are item types available for this level
      if (itemTypes.length > 0) {
        String randomType = itemTypes[(int)random(itemTypes.length)];

        // Get available cells (playable area coordinates)
        ArrayList<PVector> availableCells = getAvailableGridCells();

        if (availableCells.size() > 0) {
          // Randomly select an available cell
          PVector selectedCell = availableCells.get((int)random(availableCells.size()));
          int playableRow = (int)selectedCell.x;
          int playableCol = (int)selectedCell.y;

          // Create item using playable area coordinates
          items.add(new Item(playableRow, playableCol, randomType));
          println("Spawned " + randomType + " at playable(" + playableRow + "," + playableCol + ")");
        }
      }

      lastItemSpawnTime = millis();
    }

    // Show player (remove p.update() call)
    if (p != null) p.show();

    // Update enemies
    for (int i = enemies.size() - 1; i >= 0; i--) {
      Enemy enemy = enemies.get(i);
      enemy.update();
      enemy.show();

      // Check enemy collision with player
      if (enemy.touches(p)) {
        if (!p.isInvincible) {
          p.die();
          gameState = GAME_LOSE;
        }
      }

      // Check enemy collision with items (only if items exist)
      if (level >= 3) { // Only check item collisions in level 3+
        for (int j = items.size() - 1; j >= 0; j--) {
          Item item = items.get(j);
          if (item.type.equals("flip") && item.touchesEnemy(enemy)) {
            item.applyEffectToEnemy(enemy);
            items.remove(j); // Remove consumed mushroom
            break;
          }
        }
      }

      // Remove enemies that are off screen
      if (enemy.isOffScreen()) {
        enemies.remove(i);
      }
    }

    // Update items (only if items exist)
    if (level >= 3) { // Only update items in level 3+
      for (int i = items.size() - 1; i >= 0; i--) {
        Item item = items.get(i);
        item.update();
        item.show();

        // Check item collision with player
        if (item.touches(p)) {
          item.applyEffect(p);
          items.remove(i);
        }
      }
    }

    // Update and show gridIndicators (dynamic gophers)
    for (int i = gridIndicators.size() - 1; i >= 0; i--) {
      GridIndicator indicator = gridIndicators.get(i);
      indicator.update();
      indicator.show();

      // GridIndicator collision with player
      if (indicator.touches(p)) {
        indicator.applyEffect(p);
      }

      // Remove inactive gophers that have expired
      if (!indicator.isActive) {
        gridIndicators.remove(i);
      }
    }

    // Check survival time - 使用當前關卡時間
    int currentLevelTime = millis() - currentLevelStartTime;
    int timeRemaining = levelDuration - currentLevelTime;

    // 全關卡加速機制：剩餘30秒時啟動
    boolean shouldSpeedUp = false;
    if (timeRemaining <= 30000 && timeRemaining > 0) { // 剩餘30秒或更少，但不為負數
      shouldSpeedUp = true;

      // 第一次觸發加速時記錄時間和顯示訊息
      if (!isSpeedingUp) {
        isSpeedingUp = true;
        speedUpStartTime = millis();
        speedUpMessageShown = false;
        println("SPEED UP ACTIVATED for Level " + level + "! Time remaining: " + (timeRemaining/1000) + "s");
      }
    } else {
      // 重置加速狀態（用於下一關）
      if (isSpeedingUp) {
        isSpeedingUp = false;
        speedUpMessageShown = false;
        println("Speed up deactivated for Level " + level);
      }
    }

    // 通知所有敵人是否需要加速
    for (Enemy enemy : enemies) {
      enemy.updateSpeedForAllLevels(shouldSpeedUp);
    }

    if (timeRemaining <= 0) {
      // 當前關卡完成 - 重置加速狀態
      isSpeedingUp = false;
      speedUpMessageShown = false;

      if (level < 3) {
        // 進入下一關
        level++;
        println("Level " + (level-1) + " completed! Starting Level " + level);
        startGame(); // 重新開始新關卡
      } else {
        // 所有關卡完成
        gameState = GAME_WIN;
      }
    }

    // Use UI manager to show all UI elements - 移除敵人數量參數
    ui.showGameUI(timeRemaining, level, p);
    ui.showSpeedUpMessage(isSpeedingUp, speedUpStartTime);
    ui.showDebugInfo(p, enemies, items, gridIndicators);
    ui.showControlsHelp();

    break;

  case GAME_LOSE:
    ui.showGameResult("YOU LOST!", backgroundImage);
    break;

  case GAME_WIN:
    ui.showGameResult("YOU WIN!", backgroundImage);
    break;

  default:
    background(0);
    break;
  }
}

void keyPressed() {
  if (gameState == GAME_PLAYING && p != null) {
    if (keyCode == UP    || key == 'w' || key == 'W') p.move("UP");
    if (keyCode == DOWN  || key == 's' || key == 'S') p.move("DOWN");
    if (keyCode == LEFT  || key == 'a' || key == 'A') p.move("LEFT");
    if (keyCode == RIGHT || key == 'd' || key == 'D') p.move("RIGHT");
  }

  if (gameState == GAME_HOME) {
    if (key >= '1' && key <= '3') {
      selectedLevel = key - '0';
      gameState = GAME_LEVEL_PREP; // 進入關卡準備頁面
    }
  } else if (gameState == GAME_LEVEL_PREP) {
    if (key == ' ') {
      // 開始遊戲 - Fix: use startGame() instead of startLevel()
      level = selectedLevel; // Set the level before starting
      startGame();
      gameState = GAME_PLAYING;
    } else if (key == ESC) {
      gameState = GAME_HOME; // 返回主選單
      key = 0; // 防止程式退出
    }
  }

  if (gameState == GAME_LOSE || gameState == GAME_WIN) {
    if (key == 'r' || key == 'R') {
      resetGame();
    }
  }
}

void resetGame() {
  gameState = GAME_HOME;
  enemies.clear();
  items.clear();
  gridIndicators.clear();
  level = 1;

  // 重置加速狀態
  isSpeedingUp = false;
  speedUpMessageShown = false;

  grid = new Grid();
  p = new Player();
  lastEnemySpawnTime = millis();
  lastItemSpawnTime = millis();
}

void startGame() {
  println("Starting game with level: " + level);
  gameState = GAME_PLAYING;

  // 重置加速狀態
  isSpeedingUp = false;
  speedUpMessageShown = false;

  // Recreate grid and player
  grid = new Grid();
  p = new Player();

  enemies.clear();
  items.clear();
  gridIndicators.clear();

  lastEnemySpawnTime = millis();
  lastItemSpawnTime = millis();
  currentLevelStartTime = millis(); // 記錄當前關卡開始時間

  // Set enemy spawn interval based on level - 按您的要求調整
  enemySpawnInterval = 4000;
  if (level == 2) {
    enemySpawnInterval -=500;
  } else if (level == 3) {
    enemySpawnInterval -=1000;
  }

  // Set item spawn interval (only relevant for level 3+)
  if (level >= 3) {
    itemSpawnInterval = 6000;
  } else {
    itemSpawnInterval = 999999;
  }

  println("Level " + level + " configuration:");
  println("  Enemy spawn interval: " + enemySpawnInterval + "ms");
  println("  Item spawn interval: " + itemSpawnInterval + "ms");
  println("  Level duration: " + (levelDuration/1000) + " seconds");
}

void loadSprites() {
  // Player sprites - use carrot images
  try {
    playerSprites[0] = loadImage("data/carrotMain.png");
    playerSprites[1] = loadImage("data/carrotUp.png");
    playerSprites[2] = loadImage("data/carrotRight.png");
    playerSprites[3] = loadImage("data/carrotDown.png");
    playerSprites[4] = loadImage("data/carrotLeft.png");
    playerSprites[5] = loadImage("data/carrotMain.png");

    // Load UI images
    titleImage = loadImage("data/Title.PNG");
    backgroundImage = loadImage("data/background.png");

    if (backgroundImage == null) {
      println("Warning: background.png not found, trying other variations...");
      backgroundImage = loadImage("data/background.PNG");
      if (backgroundImage == null) {
        backgroundImage = loadImage("data/startBG.png");
      }
      if (backgroundImage == null) {
        backgroundImage = loadImage("data/startBG.PNG");
      }
    }

    if (backgroundImage != null) {
      println("Background image loaded successfully: " + backgroundImage.width + "x" + backgroundImage.height);
    } else {
      println("Error: Background image not found! Please check if background.png exists in data folder.");
    }

    // player sprites
    for (int i = 0; i < playerSprites.length; i++) {
      if (playerSprites[i] != null) {
        println("Player sprite " + i + " loaded successfully");
      } else {
        println("Warning: Player sprite " + i + " failed to load");
      }
    }

    println("All sprites loading completed!");
  }
  catch (Exception e) {
    println("Error loading sprites: " + e.getMessage());
    // Create blank images as fallback
    for (int i = 0; i < playerSprites.length; i++) {
      playerSprites[i] = createImage(100, 100, RGB);
      playerSprites[i].loadPixels();
      for (int j = 0; j < playerSprites[i].pixels.length; j++) {
        playerSprites[i].pixels[j] = color(255, 140, 0); // 橙色後備
      }
      playerSprites[i].updatePixels();
    }
  }
}

// Fix getAvailableGridCells method
ArrayList<PVector> getAvailableGridCells() {
  ArrayList<PVector> availableCells = new ArrayList<PVector>();

  if (grid == null) return availableCells;

  // Only check playable area cells (using playable area relative coordinates)
  for (int row = 0; row < grid.playableRows; row++) {
    for (int col = 0; col < grid.playableCols; col++) {
      boolean occupied = false;

      // Check if player is in this cell
      if (p != null) {
        PVector playerPos = p.getCurrentGridPosition();
        if ((int)playerPos.x == row && (int)playerPos.y == col) {
          occupied = true;
        }
      }

      // Check if there's already an item
      for (Item item : items) {
        if (!item.collected && item.isInPlayableArea()) {
          // Convert to playable area coordinates for comparison
          int itemPlayableRow = item.gridRow - 1;
          int itemPlayableCol = item.gridCol - 1;
          if (itemPlayableRow == row && itemPlayableCol == col) {
            occupied = true;
            break;
          }
        }
      }

      if (!occupied) {
        availableCells.add(new PVector(row, col));
      }
    }
  }

  return availableCells;
}

// Optional: new method to directly spawn items at specified grid position
void spawnItemAtGridPosition(int row, int col, String itemType) {
  if (grid != null && row >= 0 && row < grid.rows && col >= 0 && col < grid.cols) {
    items.add(new Item(row, col, itemType));
  }
}
