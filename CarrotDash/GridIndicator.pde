class GridIndicator {
  float x, y, w, h;
  PImage[] sprites;
  int gridRow, gridCol;
  boolean isActive = false;
  int activateTime = 0;
  int displayDuration = 3000; // 顯示 3 秒
  
  // Animation variables
  int animFrame = 0;
  int lastAnimTime = 0;
  int animSpeed = 500;

  GridIndicator(int row, int col) {
    this.w = 80;
    this.h = 80;
    this.gridRow = row;
    this.gridCol = col;
    
    // Calculate position
    if (grid != null) {
      x = grid.originX + gridCol * grid.cellSize + (grid.cellSize - w) / 2;
      y = grid.originY + gridRow * grid.cellSize + (grid.cellSize - h) / 2;
    } else {
      x = col * 100 + 10;
      y = row * 100 + 10;
    }
    
    loadSprites();
  }
  
  void loadSprites() {
    sprites = new PImage[3];
    
    // GridIndicator uses gopher images
    sprites[0] = loadImage("data/Gopher.PNG");
    sprites[1] = loadImage("data/halfGopher.PNG");
    sprites[2] = loadImage("data/littleGopher.PNG");
    
    // Check if images loaded successfully
    for (int i = 0; i < sprites.length; i++) {
      if (sprites[i] == null) {
        sprites[i] = createImage(80, 80, RGB);
        sprites[i].loadPixels();
        for (int j = 0; j < sprites[i].pixels.length; j++) {
          sprites[i].pixels[j] = color(0, 255, 255); // Cyan fallback
        }
        sprites[i].updatePixels();
      }
    }
  }

  void update() {
    // Update animation
    if (millis() - lastAnimTime > animSpeed) {
      animFrame = (animFrame + 1) % sprites.length;
      lastAnimTime = millis();
    }
    
    // Check if should deactivate
    if (isActive && millis() - activateTime > displayDuration) {
      isActive = false;
    }
  }

  void show() {
    if (isActive && sprites != null && animFrame < sprites.length) {
      // Add emergence effect
      pushMatrix();
      translate(x + w/2, y + h/2);
      
      // Scale effect when appearing
      float timeAlive = millis() - activateTime;
      float scaleEffect = 1.0;
      if (timeAlive < 300) {
        scaleEffect = map(timeAlive, 0, 300, 0.3, 1.0);
      }
      scale(scaleEffect);
      
      imageMode(CENTER);
      if (sprites[animFrame] != null) {
        image(sprites[animFrame], 0, 0, w, h);
      } else {
        // Fallback display
        fill(139, 69, 19); // Brown color for gopher
        noStroke();
        ellipse(0, 0, w * 0.8, h * 0.8);
      }
      popMatrix();
      
      // Debug: show grid position
      if (keyPressed && key == 't') {
        fill(255, 255, 0);
        textAlign(CENTER, CENTER);
        textSize(12);
        text("Gopher(" + gridRow + "," + gridCol + ")", x + w/2, y - 15);
      }
    }
  }

  boolean touches(Player p) {
    return isActive && p.isAlive && 
           dist(x + w/2, y + h/2, p.x + p.w/2, p.y + p.h/2) < (w + p.w) * 0.4;
  }

  void applyEffect(Player player) {
    if (isActive) {
      // Gopher: activate grid tracker
      player.activateGridIndicator();
      isActive = false; // Deactivate after being touched
      println("Player touched gopher - Grid indicator activated!");
    }
  }
  
  // Activate gopher at this position
  void activate() {
    isActive = true;
    activateTime = millis();
    println("Gopher activated at (" + gridRow + ", " + gridCol + ")");
  }
  
  // Check if at specified position
  boolean isAtPosition(int row, int col) {
    return gridRow == row && gridCol == col;
  }
  
  // Update position (for dynamic positioning)
  void setPosition(int row, int col) {
    this.gridRow = row;
    this.gridCol = col;
    
    if (grid != null) {
      x = grid.originX + gridCol * grid.cellSize + (grid.cellSize - w) / 2;
      y = grid.originY + gridRow * grid.cellSize + (grid.cellSize - h) / 2;
    }
  }
}
