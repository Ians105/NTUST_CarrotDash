final int GAME_HOME = 0;
final int GAME_RUN = 1;
final int GAME_WIN = 2;
final int GAME_LOSE = 3;

int gameState = GAME_HOME;

int[] roundStateList;
float xMidPosition, yMidPosition;
ArrayList<PImage> bgImageList;

void setup() {
 fullScreen();
}

void draw() {
  background(0);
}
