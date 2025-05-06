class Player {
  float x, y, w, h;
  int spriteIndex, spriteAnimationIndex;
  boolean isAlive=true;

  Player() {
    w = 100;
    y = 100;
    x = xMidPosition - (w/2);
    y = yMidPosition - (h/2);
  }
}
