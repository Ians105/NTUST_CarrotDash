class Player {
  float x, y, w, h;
  int spriteIndex = 0;
  boolean isAlive=true;

  int lastMoveTime = 0;
  String lastMoveDirection = "";

  Player() {
    w = 100;
    h = 100;
    x = width/2 - w/2;
    y = height/2 - h/2;
  }

  void show() {
    // After 0.5 seconds and isAlive, return to the default sprite.
    if (isAlive && millis() - lastMoveTime > 500) {
      spriteIndex = 0;
    }

    // Debug mode
    //circle(x, y, w);

    image(playerSprites[spriteIndex], x, y);
  }

  void move(String direction) {
    if (!isAlive) return;
    
    boolean repeatedDirection = direction.equals(lastMoveDirection);
    
    if (repeatedDirection /*|| touchedEnemy*/) {
      die();
      return;
    }

    if (direction.equals("UP")) {
      y -= SPEED;
      spriteIndex = 1;
    }
    if (direction.equals("RIGHT")) {
      x += SPEED;
      spriteIndex = 2;
    }
    if (direction.equals("DOWN")) {
      y += SPEED;
      spriteIndex = 3;
    }
    if (direction.equals("LEFT")) {
      x -= SPEED;
      spriteIndex = 4;
    }

    lastMoveTime = millis();
    lastMoveDirection = direction;
  }

  void die() {
    isAlive = false;
    spriteIndex = 5;
  }
}
