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
int level;

ArrayList<PImage> bgImageList;

void setup() {
  //size(1600, 900);
  fullScreen();
  loadSprites();
  p = new Player();
  grid = new Grid();
  frameRate(60);
}

void draw() {
  if (!p.isAlive) {
    gameState = GAME_LOSE;
  }

  switch(gameState) {
  case GAME_RUN:
    background(0);
    grid.show();
    p.show();

    // Spawn enemies every 2 seconds
    if (millis() - lastEnemySpawnTime > enemySpawnInterval) {
      enemies.add(new Enemy(grid));
      lastEnemySpawnTime = millis();
    }

    for (int i = enemies.size() - 1; i >= 0; i--) {
      Enemy e = enemies.get(i);
      e.move();
      e.show();

      if (e.collidesWith(p)) {
        p.die();
      }

      if (e.isOffScreen()) {
        enemies.remove(i);
      }
    }

    int survivalTime = millis() - gameStartTime;
    if (survivalTime >= 90000) {
      gameState = GAME_WIN;
    }

    fill(255);
    textSize(32);
    textAlign(LEFT, TOP);
    text("Time: " + (survivalTime / 1000) + "s", 20, 20);


    break;
  case GAME_LOSE:
    loadGameResult("YOU LOST!");
    break;

  case GAME_WIN:
    loadGameResult("YOU WIN!");
    break;

  case GAME_HOME:
    background(50);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(48);
    text("Choose a Level", width / 2, height / 2 - 150);
    textSize(32);
    text("Press 1 for Level 1", width / 2, height / 2 - 50);
    text("Press 2 for Level 2", width / 2, height / 2);
    text("Press 3 for Level 3", width / 2, height / 2 + 50);
    break;

  default:
  }
}

void keyPressed() {
  if (gameState == GAME_RUN) {
    if (keyCode == UP    || key == 'w' || key == 'W') p.move("UP", grid);
    if (keyCode == DOWN  || key == 's' || key == 'S') p.move("DOWN", grid);
    if (keyCode == LEFT  || key == 'a' || key == 'A') p.move("LEFT", grid);
    if (keyCode == RIGHT || key == 'd' || key == 'D') p.move("RIGHT", grid);
  }

  if (gameState == GAME_HOME) {
    if (keyCode == '1') {
      level = 1;
      startGame();
    } else if (keyCode == '2') {
      level = 2;
      startGame();
    } else if (keyCode == '3') {
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
  p = new Player();
  grid = new Grid();
  lastEnemySpawnTime = millis();
  lastItemSpawnTime = millis();
}

void startGame() {
  gameState = GAME_RUN;
  p = new Player();
  grid = new Grid();
  enemies.clear();
  lastEnemySpawnTime = millis();
  gameStartTime = millis();

  if (level == 1) enemySpawnInterval = 3000;
  else if (level == 2) enemySpawnInterval = 2000;
  else if (level == 3) enemySpawnInterval = 1000;
}


void loadSprites() {
  /*
  playerSprites:
   0 - default,
   1 - up,
   2 - right,
   3 - down,
   4 - left,
   5 - defeated
   */
  for (int i = 0; i<6; i++) {
    playerSprites[i] = loadImage("assets/player_"+i+".png");
  }

  /*
  enemySprites:
   0 0 - default, right
   0 1 - default, left
   1 0 - ghost
   */
  for (int i = 0; i<2; i++) {
    for (int j = 0; j<2; j++) {
      if (i==1) break;
      enemySprites[i][j] = loadImage("assets/enemy_"+i+j+".png");
    }
  }

  /*
  itemSprite:
   0 - danger
   1 - lucky
   2 - flip
   */
   
}

void loadGameResult(String message) {
  fill(0, 200);
  noStroke();
  rectMode(CENTER);
  rect(width / 2, height / 2, 600, 300);

  fill(255);
  textSize(48);
  textAlign(CENTER, CENTER);
  text(message, width/2, height/2 - 40);
  textSize(24);
  text("Press R to restart", width/2, height/2 + 20);
}
