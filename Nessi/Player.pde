class Player {
  float x, y, w, h;
  int spriteIndex, spriteAnimationIndex;
  boolean isAlive=true;

  Player() {
    w = 100;
    h = 100;
    x = width/2;
    y = height/2;
  }

  void show() {
    circle(x, y, w);
  }

  void move(String direction) {
    if (direction.equals("UP")    ) y -= gridCellSize;
    if (direction.equals("DOWN")  ) y += gridCellSize;
    if (direction.equals("LEFT")  ) x -= gridCellSize;
    if (direction.equals("RIGHT") ) x += gridCellSize;
  }
}
