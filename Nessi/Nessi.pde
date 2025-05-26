// Game modes
final int GAME_HOME = 0;
final int GAME_RUN = 1;
final int GAME_WIN = 2;
final int GAME_LOSE = 3;

// Speed for grid like movement
final int SPEED = 100;

PImage[] playerSprites = new PImage[6];

// Grid variables
int gridSize = 0;
int gridCellSize = 100;

//int gameState = GAME_HOME;
int gameState = GAME_RUN;

int level = 1;

int[] roundStateList;
ArrayList<PImage> bgImageList;
Player p;

void setup() {
  size(1600, 900);
  loadSprites();
  p = new Player();
}

void draw() {
  switch(gameState) {
  case 1:
    background(0);
    drawGrid(1);
    p.show();
    break;
  case 2:
  case 3:
  default:
  }
}

void drawGrid(int level) {
  int numRows = 0, numCols = 0;
  if (level == 1) {
    numRows = 3;
    numCols = 3;
  } else if (level == 2) {
    numRows = 4;
    numCols = 4;
  } else if (level == 3) {
    numRows = 5;
    numCols = 5;
  }

  pushMatrix();
  translate(width/2, height/2);

  // initial x and initial y
  int offset = gridCellSize/2;
  int ix = -offset-(numCols/2)*gridCellSize;
  int iy = -offset-(numRows/2)*gridCellSize;

  stroke(255);
  strokeWeight(1);
  noFill();

  for (int r = 0; r<numRows; r++) {
    for (int c = 0; c<numCols; c++) {
      square(ix + c*gridCellSize, iy + r*gridCellSize, gridCellSize);
    }
  }
  popMatrix();
}

void keyPressed() {
  if (keyCode == UP || keyCode == 'W') p.move("UP");
  if (keyCode == DOWN || keyCode == 'S') p.move("DOWN");
  if (keyCode == LEFT || keyCode == 'A') p.move("LEFT");
  if (keyCode == RIGHT || keyCode == 'D') p.move("RIGHT");
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
}
