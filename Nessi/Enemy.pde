class Enemy {
  float x, y, w, h;
  float step = SPEED/2;
  boolean fromLeft;
  int lastStepTime = 0;

  Enemy(Grid grid) {
    w = SPRITE_SIZE;
    h = SPRITE_SIZE;

    fromLeft = random(1) < 0.5;

    int row = int(random(grid.rows));
    y = grid.topBound() + row * grid.cellSize;

    if (fromLeft) {
      x = -w;  // fully off-screen to the left
    } else {
      x = width;  // fully off-screen to the right
    }

    lastStepTime = millis();
  }


  void move() {
    if (millis() - lastStepTime >= 500) {
      if (fromLeft) x += step;
      else x -= step;

      lastStepTime = millis();
    }
  }

  void show() {
    fill(255, 0, 0);
    if (fromLeft) image(enemySprites[0][0], x, y);
    else image(enemySprites[0][1], x, y);
  }

  boolean isOffScreen() {
    return x < -w || x > width + w;
  }

  boolean collidesWith(Player p) {
    return p.isAlive &&
      x < p.x + p.w &&
      x + w > p.x &&
      y < p.y + p.h &&
      y + h > p.y;
  }
}
