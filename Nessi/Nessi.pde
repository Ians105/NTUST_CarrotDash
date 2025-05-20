final int GAME_HOME = 0;
final int GAME_RUN = 1;
final int GAME_WIN = 2;
final int GAME_LOSE = 3;
final int SPEED = 0;
int gridSize = 0;
int gridCellSize = 100;

int gameState = GAME_HOME;

int[] roundStateList;
ArrayList<PImage> bgImageList;
Player p;

void setup() {
  size(1600, 900);
  p = new Player();
}

void draw() {
  background(0);
  drawGrid(1);
  p.show();
  noLoop();
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
  if (keyCode == UP || keyCode == 'w') p.move("UP");
  if (keyCode == DOWN) p.move("DOWN");
  if (keyCode == LEFT) p.move("LEFT");
  if (keyCode == RIGHT) p.move("RIGHT");
}
