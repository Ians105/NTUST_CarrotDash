class Grid {
  int rows, cols;
  int cellSize = 100;
  int offset = 50;
  float originX, originY;

  Grid() {
    if (level == 1) {
      rows = 3;
      cols = 3;
    } else if (level == 2) {
      rows = 5;
      cols = 3;
    } else if (level == 3) {
      rows = 5;
      cols = 5;
    }

    originX = width / 2 - (cols * cellSize) / 2;
    originY = height / 2 - (rows * cellSize) / 2;
  }

  void show() {
    rectMode(CORNER);
    stroke(255);
    noFill();
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        float x = originX + c * cellSize;
        float y = originY + r * cellSize;
        square(x, y, cellSize);
      }
    }

  }


  float leftBound() {
    return originX;
  }

  float rightBound() {
    return originX + cols * cellSize;
  }

  float topBound() {
    return originY;
  }

  float bottomBound() {
    return originY + rows * cellSize;
  }
}
