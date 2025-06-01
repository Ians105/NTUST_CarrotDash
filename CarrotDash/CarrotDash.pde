// Game modes
final int GAME_HOME = 0;
final int GAME_RUN = 1;
final int GAME_WIN = 2;
final int GAME_LOSE = 3;

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

// Background and UI Images
PImage titleImage;
PImage backgroundImage;

// GridIndicator Variables
ArrayList<GridIndicator> gridIndicators = new ArrayList<GridIndicator>();

// UI Manager
UI ui;

void setup() {
  //size(1600, 900);
  fullScreen();
  loadSprites();
  
  // Initialize UI manager
  ui = new UI();
  
  // Initialize grid and player when level is already set
  grid = new Grid();
  p = new Player();
  
  frameRate(60);
}

void draw() {
  switch(gameState) {
    case GAME_RUN:
      // Show background image
      if (backgroundImage != null) {
        imageMode(CORNER);
        image(backgroundImage, 0, 0, width, height);
      } else {
        background(50, 150, 50);
      }
      
      if (grid != null) grid.show();

      // Spawn enemies every interval - restrict enemy types by level
      if (millis() - lastEnemySpawnTime > enemySpawnInterval) {
        String[] enemyTypes;
        
        // Define enemy types based on level
        if (level == 1) {
          enemyTypes = new String[]{"pest"}; // Level 1: only pest (gopher will be handled by GridIndicator)
        } else if (level == 2) {
          enemyTypes = new String[]{"pest", "bird"}; // Level 2: pest and bird (gopher still in GridIndicator)
        } else if (level == 3) {
          enemyTypes = new String[]{"pest", "bird"}; // Level 3: pest and bird (gopher still in GridIndicator)
        } else {
          enemyTypes = new String[]{"pest"}; // Default fallback
        }
        
        String randomType = enemyTypes[(int)random(enemyTypes.length)];
        
        // Generate monsters at 2 grids outside the grid
        float spawnX, spawnY;
        
        // Randomly choose to spawn from left or right
        boolean fromLeft = random(1) < 0.5;
        
        if (fromLeft) {
          // Enter from left, spawn 2 grids outside left edge
          spawnX = grid.originX - 2 * grid.cellSize;
          // Randomly select a row in playable area
          int randomRow = (int)random(1, grid.playableRows + 1); // 1 to playableRows
          spawnY = grid.originY + randomRow * grid.cellSize;
        } else {
          // Enter from right, spawn 2 grids outside right edge
          spawnX = grid.originX + (grid.cols + 2) * grid.cellSize;
          // Randomly select a row in playable area
          int randomRow = (int)random(1, grid.playableRows + 1); // 1 to playableRows
          spawnY = grid.originY + randomRow * grid.cellSize;
        }
        
        enemies.add(new Enemy(spawnX, spawnY, randomType));
        lastEnemySpawnTime = millis();
        
        println("Spawned " + randomType + " at (" + spawnX + ", " + spawnY + ") from " + (fromLeft ? "left" : "right"));
      }

      // Spawn items - restrict item types by level
      if (millis() - lastItemSpawnTime > itemSpawnInterval) {
        String[] itemTypes;
        
        // Define item types based on level
        if (level == 1) {
          itemTypes = new String[]{}; // Level 1: no items (gopher effect comes from GridIndicator)
        } else if (level == 2) {
          itemTypes = new String[]{}; // Level 2: no items yet (gopher effect still from GridIndicator)
        } else if (level == 3) {
          itemTypes = new String[]{"flip", "star"}; // Level 3: scarecrow(star) and poisonmushroom(flip)
        } else {
          itemTypes = new String[]{}; // Default: no items
        }
        
        // Only spawn items if there are item types available for this level
        if (itemTypes.length > 0) {
          String randomType = itemTypes[(int)random(itemTypes.length)];
          
          // Get available cells (playable area coordinates)
          ArrayList<PVector> availableCells = getAvailableGridCells();
          
          if (availableCells.size() > 0) {
            // Randomly select an available cell
            PVector selectedCell = availableCells.get((int)random(availableCells.size()));
            int playableRow = (int)selectedCell.x; // Playable area relative coordinates
            int playableCol = (int)selectedCell.y; // Playable area relative coordinates
            
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
              break; // Exit inner loop to avoid index error
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

      // Check survival time
      int survivalTime = millis() - gameStartTime;
      if (survivalTime >= 60000) {
        gameState = GAME_WIN;
      }

      // Use UI manager to show all UI elements
      ui.showGameUI(survivalTime, level, p, enemies.size());
      ui.showDebugInfo(p, enemies, items, gridIndicators);
      ui.showControlsHelp();

      break;
      
    case GAME_LOSE:
      ui.showGameResult("YOU LOST!", backgroundImage);
      break;

    case GAME_WIN:
      ui.showGameResult("YOU WIN!", backgroundImage);
      break;

    case GAME_HOME:
      ui.showHomeMenu(titleImage, backgroundImage);
      break;

    default:
      background(0);
  }
}

void keyPressed() {
  if (gameState == GAME_RUN && p != null) {
    if (keyCode == UP    || key == 'w' || key == 'W') p.move("UP");
    if (keyCode == DOWN  || key == 's' || key == 'S') p.move("DOWN");
    if (keyCode == LEFT  || key == 'a' || key == 'A') p.move("LEFT");
    if (keyCode == RIGHT || key == 'd' || key == 'D') p.move("RIGHT");
  }

  if (gameState == GAME_HOME) {
    if (key == '1') {
      level = 1;
      startGame();
    } else if (key == '2') {
      level = 2;
      startGame();
    } else if (key == '3') {
      level = 3;
      startGame();
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
  gridIndicators.clear(); // Clear gridIndicators
  level = 1; // Reset to default level
  grid = new Grid(); // Recreate grid
  p = new Player(); // Recreate player
  lastEnemySpawnTime = millis();
  lastItemSpawnTime = millis();
}

void startGame() {
  println("Starting game with level: " + level);
  gameState = GAME_RUN;
  
  // Recreate grid and player
  grid = new Grid();
  p = new Player();
  
  enemies.clear();
  items.clear();
  gridIndicators.clear(); // Clear all gophers
  
  lastEnemySpawnTime = millis();
  lastItemSpawnTime = millis();
  gameStartTime = millis();

  // Set enemy spawn interval based on level and complexity
  if (level == 1) {
    enemySpawnInterval = 5000;  // Level 1: 5 seconds (easier, only pest)
  } else if (level == 2) {
    enemySpawnInterval = 4000;  // Level 2: 4 seconds (pest + bird)
  } else if (level == 3) {
    enemySpawnInterval = 3000;  // Level 3: 3 seconds (all enemies + items)
  } else {
    enemySpawnInterval = 4000;  // Default 4 seconds
  }
  
  // Set item spawn interval (only relevant for level 3+)
  if (level >= 3) {
    itemSpawnInterval = 6000; // 6 seconds for items in level 3
  } else {
    itemSpawnInterval = 999999; // Very long interval (effectively disabled) for levels 1-2
  }
  
  println("Level " + level + " configuration:");
  println("  Enemy spawn interval: " + enemySpawnInterval + "ms");
  println("  Item spawn interval: " + itemSpawnInterval + "ms");
}

void loadSprites() {
  // Player sprites - use carrot images
  try {
    playerSprites[0] = loadImage("data/carrotMain.png");    // default
    playerSprites[1] = loadImage("data/carrotUp.png");      // up
    playerSprites[2] = loadImage("data/carrotRight.png");   // right
    playerSprites[3] = loadImage("data/carrotDown.png");    // down
    playerSprites[4] = loadImage("data/carrotLeft.png");    // left
    playerSprites[5] = loadImage("data/carrotMain.png");    // defeated

    // Load UI images - 修正背景圖片文件名
    titleImage = loadImage("data/Title.PNG");
    backgroundImage = loadImage("data/background.png"); // 修正：改為 background.png
    
    // 檢查背景圖片是否成功加載
    if (backgroundImage == null) {
      println("Warning: background.png not found, trying other variations...");
      // 嘗試其他可能的文件名
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
    
    // 檢查 player sprites 是否加載成功
    for (int i = 0; i < playerSprites.length; i++) {
      if (playerSprites[i] != null) {
        println("Player sprite " + i + " loaded successfully");
      } else {
        println("Warning: Player sprite " + i + " failed to load");
      }
    }
    
    println("All sprites loading completed!");
  } catch (Exception e) {
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

// Remove the old loadGameResult method since it's now in UI class

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
