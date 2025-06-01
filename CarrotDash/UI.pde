class UI {
  // UI Colors
  color backgroundColor = color(0, 150);
  color textColor = color(255);
  color highlightColor = color(255, 255, 0);
  color dangerColor = color(255, 100, 100);
  color successColor = color(100, 255, 100);
  color infoColor = color(200, 200, 255);
  
  // UI Sizes
  int largeFontSize = 48;
  int mediumFontSize = 32;
  int smallFontSize = 16;
  int tinyFontSize = 12;
  
  // UI Positions and Sizes
  int gameInfoX = 10;
  int gameInfoY = 10;
  int gameInfoW = 300;
  int gameInfoH = 240;
  
  int statusX = 320;
  int statusY = 120;
  
  int enemyCountX;
  int enemyCountY = 10;
  int enemyCountW = 210;
  int enemyCountH = 60;
  
  UI() {
    // Calculate positions based on screen size
    enemyCountX = width - 220;
  }
  
  // Show game running UI
  void showGameUI(int survivalTime, int level, Player player, int enemyCount) {
    showGameInfo(survivalTime, level);
    showLevelFeatures(level);
    showPlayerStatus(player);
    showEnemyCount(enemyCount);
  }
  
  // Show basic game information
  void showGameInfo(int survivalTime, int level) {
    // Semi-transparent background
    fill(backgroundColor);
    noStroke();
    rectMode(CORNER);
    rect(gameInfoX, gameInfoY, gameInfoW, gameInfoH);
    
    // Time and level display
    fill(textColor);
    textSize(mediumFontSize);
    textAlign(LEFT, TOP);
    text("Time: " + (survivalTime / 1000) + "s", gameInfoX + 10, gameInfoY + 10);
    text("Level: " + level, gameInfoX + 10, gameInfoY + 50);
  }
  
  // Show level-specific features
  void showLevelFeatures(int level) {
    textSize(smallFontSize);
    fill(infoColor);
    text("Level " + level + " Features:", gameInfoX + 10, gameInfoY + 90);
    
    int featureY = gameInfoY + 110;
    int lineHeight = 20;
    
    if (level == 1) {
      text("• Pest enemies", gameInfoX + 10, featureY);
      text("• Gopher (GridIndicator)", gameInfoX + 10, featureY + lineHeight);
    } else if (level == 2) {
      text("• Pest enemies", gameInfoX + 10, featureY);
      text("• Bird enemies (teleport)", gameInfoX + 10, featureY + lineHeight);
      text("• Gopher (GridIndicator)", gameInfoX + 10, featureY + lineHeight * 2);
    } else if (level == 3) {
      text("• Pest enemies", gameInfoX + 10, featureY);
      text("• Bird enemies (teleport)", gameInfoX + 10, featureY + lineHeight);
      text("• Gopher (GridIndicator)", gameInfoX + 10, featureY + lineHeight * 2);
      text("• Scarecrow (invincibility)", gameInfoX + 10, featureY + lineHeight * 3);
      text("• Poison Mushroom (flip)", gameInfoX + 10, featureY + lineHeight * 4);
    }
  }
  
  // Show player status effects
  void showPlayerStatus(Player player) {
    textSize(smallFontSize);
    int currentY = statusY;
    int lineHeight = 20;
    
    if (player.isFlipped) {
      fill(255, 0, 255);
      text("FLIPPED!", statusX, currentY);
      currentY += lineHeight;
    }
    
    if (player.isInvincible) {
      fill(highlightColor);
      text("INVINCIBLE!", statusX, currentY);
      currentY += lineHeight;
    }
    
    if (player.showGridIndicator) {
      fill(successColor);
      text("GRID TRACKER!", statusX, currentY);
      currentY += lineHeight;
    }
  }
  
  // Show enemy count
  void showEnemyCount(int enemyCount) {
    fill(backgroundColor);
    rect(enemyCountX, enemyCountY, enemyCountW, enemyCountH);
    
    fill(dangerColor);
    textAlign(LEFT, TOP);
    textSize(smallFontSize);
    text("Enemies: " + enemyCount, enemyCountX + 20, enemyCountY + 20);
  }
  
  // Show home menu
  void showHomeMenu(PImage titleImage, PImage backgroundImage) {
    // Background
    showBackground(backgroundImage);
    
    // Title
    showTitle(titleImage);
    
    // Menu options
    showMenuOptions();
  }
  
  // Show background
  void showBackground(PImage backgroundImage) {
    if (backgroundImage != null) {
      imageMode(CORNER);
      image(backgroundImage, 0, 0, width, height);
    } else {
      // Fallback gradient background
      for (int i = 0; i <= height; i++) {
        float inter = map(i, 0, height, 0, 1);
        color c = lerpColor(color(50, 150, 50), color(20, 80, 20), inter);
        stroke(c);
        line(0, i, width, i);
      }
    }
  }
  
  // Show title
  void showTitle(PImage titleImage) {
    if (titleImage != null) {
      // Calculate scale to fit within 60% of screen width and 25% of screen height
      float maxTitleWidth = width * 0.6;
      float maxTitleHeight = height * 0.25;
      float titleScale = min(maxTitleWidth / titleImage.width, maxTitleHeight / titleImage.height);
      
      float titleW = titleImage.width * titleScale;
      float titleH = titleImage.height * titleScale;
      
      imageMode(CENTER);
      image(titleImage, width/2, height/2 - 100, titleW, titleH);
    } else {
      // Fallback text title
      fill(255, 140, 0);
      textAlign(CENTER, CENTER);
      textSize(72);
      text("CARROT DASH", width / 2, height / 2 - 100);
    }
  }
  
  // Show menu options
  void showMenuOptions() {
    // Menu background
    fill(0, 180);
    rectMode(CENTER);
    rect(width/2, height/2 + 100, 500, 250);
    
    // Menu text
    fill(textColor);
    textAlign(CENTER, CENTER);
    textSize(36);
    text("Choose a Level", width / 2, height / 2 + 20);
    
    textSize(28);
    text("Press 1 for Level 1 (3x3)", width / 2, height / 2 + 60);
    text("Press 2 for Level 2 (4x4)", width / 2, height / 2 + 100);
    text("Press 3 for Level 3 (5x5)", width / 2, height / 2 + 140);
    
    // Instructions
    textSize(20);
    fill(infoColor);
    text("Use WASD or Arrow Keys to move", width / 2, height / 2 + 180);
  }
  
  // Show game result (win/lose)
  void showGameResult(String message, PImage backgroundImage) {
    // Background
    showBackground(backgroundImage);
    
    // Result dialog
    fill(0, 200);
    noStroke();
    rectMode(CENTER);
    rect(width / 2, height / 2, 600, 300);

    // Result text
    fill(textColor);
    textSize(largeFontSize);
    textAlign(CENTER, CENTER);
    text(message, width/2, height/2 - 40);
    
    textSize(24);
    text("Press R to restart", width/2, height/2 + 20);
  }
  
  // Show debug information
  void showDebugInfo(Player player, ArrayList<Enemy> enemies, ArrayList<Item> items, ArrayList<GridIndicator> gridIndicators) {
    if (keyPressed && key == 'd') {
      // Debug panel background
      fill(0, 200);
      rect(width - 300, height - 200, 290, 190);
      
      // Debug information
      fill(255, 255, 0);
      textAlign(LEFT, TOP);
      textSize(tinyFontSize);
      
      int debugX = width - 290;
      int debugY = height - 190;
      int lineHeight = 15;
      
      text("=== DEBUG INFO ===", debugX, debugY);
      debugY += lineHeight;
      
      if (player != null) {
        PVector playerPos = player.getCurrentGridPosition();
        text("Player: (" + (int)player.x + ", " + (int)player.y + ")", debugX, debugY);
        debugY += lineHeight;
        text("Grid: (" + (int)playerPos.x + ", " + (int)playerPos.y + ")", debugX, debugY);
        debugY += lineHeight;
      }
      
      text("Enemies: " + enemies.size(), debugX, debugY);
      debugY += lineHeight;
      text("Items: " + items.size(), debugX, debugY);
      debugY += lineHeight;
      text("Gophers: " + gridIndicators.size(), debugX, debugY);
      debugY += lineHeight;
      text("FPS: " + (int)frameRate, debugX, debugY);
    }
  }
  
  // Show controls help
  void showControlsHelp() {
    if (keyPressed && key == 'h') {
      // Help panel background
      fill(0, 220);
      rectMode(CENTER);
      rect(width/2, height/2, 400, 300);
      
      // Help text
      fill(textColor);
      textAlign(CENTER, TOP);
      textSize(20);
      text("CONTROLS", width/2, height/2 - 130);
      
      textSize(16);
      int helpY = height/2 - 100;
      int lineHeight = 20;
      
      text("WASD or Arrow Keys - Move", width/2, helpY);
      helpY += lineHeight;
      text("D - Toggle Debug Info", width/2, helpY);
      helpY += lineHeight;
      text("H - Show/Hide Help", width/2, helpY);
      helpY += lineHeight;
      text("R - Restart (in game over)", width/2, helpY);
      helpY += lineHeight;
      text("1/2/3 - Select Level (in menu)", width/2, helpY);
      helpY += lineHeight * 2;
      
      textSize(14);
      fill(infoColor);
      text("Goal: Survive for 60 seconds!", width/2, helpY);
    }
  }
  
  // Update UI positions (call when screen size changes)
  void updatePositions() {
    enemyCountX = width - 220;
  }
}