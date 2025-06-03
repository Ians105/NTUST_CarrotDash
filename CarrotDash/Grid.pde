class Grid {
  int rows, cols;
  int playableRows, playableCols; // Player movable range
  int cellSize;
  int offset = 50;
  float originX, originY;
  PImage gridImage;

  Grid() {
    // Set game grid size (player movable range)
    if (level == 1) {
      playableRows = 3;
      playableCols = 3;
      gridImage = loadImage("data/3x3 Grid-1.png");
    } else if (level == 2) {
      playableRows = 3;
      playableCols = 5;
      gridImage = loadImage("data/3x5 Grid-1.png"); // 正確：Level 2 是 3x5
    } else if (level == 3) {
      playableRows = 5;
      playableCols = 5;
      gridImage = loadImage("data/5x5 Grid-1.png");
    } else {
      // Default fallback
      playableRows = 3;
      playableCols = 3;
      gridImage = loadImage("data/3x3 Grid.png");
    }

    // Expand grid range, extend outward by one ring for placing gridIndicator
    rows = playableRows + 2; // Add one row top and bottom
    cols = playableCols + 2; // Add one column left and right

    // Dynamically calculate grid size to fit screen and maintain reasonable proportions
    calculateOptimalGridSize();
  }
  
  void calculateOptimalGridSize() {
    // Calculate available screen space for centering - 減少可用空間
    float availableWidth = width * 0.5;   // 減少：70% → 50%
    float availableHeight = height * 0.6;  // 減少：80% → 60%
    
    // Calculate most suitable cell size based on playable grid dimensions (not expanded)
    float maxCellWidth = availableWidth / playableCols;
    float maxCellHeight = availableHeight / playableRows;
    
    // Take smaller value to ensure grid is square and doesn't exceed screen
    cellSize = (int)min(maxCellWidth, maxCellHeight);
    
    // Set reasonable cell size range - 縮小範圍
    cellSize = constrain(cellSize, 60, 100); // 減少：80-150 → 60-100
    
    // Calculate grid start position - 完全置中
    float totalPlayableWidth = playableCols * cellSize;
    float totalPlayableHeight = playableRows * cellSize;
    
    // 置中計算：將可玩區域置於螢幕中央
    float playableOriginX = (width - totalPlayableWidth) / 2;
    float playableOriginY = (height - totalPlayableHeight) / 2;
    
    // 計算擴展網格的起始位置（向外擴展一圈）
    originX = playableOriginX - cellSize; // 向左擴展一格
    originY = playableOriginY - cellSize; // 向上擴展一格
    
    println("Grid centered (SMALLER) - Origin: (" + originX + ", " + originY + ")");
    println("Playable area: " + playableCols + "x" + playableRows + ", Cell size: " + cellSize);
    println("Available space used: " + (int)(totalPlayableWidth * 100 / width) + "% width, " + 
            (int)(totalPlayableHeight * 100 / height) + "% height");
  }

  void show() {
    if (gridImage != null) {
      // Calculate playable area size and position
      float playableGridWidth = playableCols * cellSize;
      float playableGridHeight = playableRows * cellSize;
      
      // Calculate playable area start position (excluding outer ring)
      float playableOriginX = originX + cellSize; // Skip left gridIndicator column
      float playableOriginY = originY + cellSize; // Skip top gridIndicator row
      
      // Show game grid image - 縮放到與遊戲網格完全相同的大小和位置
      imageMode(CORNER);
      image(gridImage, playableOriginX, playableOriginY, playableGridWidth, playableGridHeight);
      
      // Debug: show grid row-column labels (only when debug key is pressed)
      if (keyPressed && key == 't') {
        showDebugGrid();
      }
      
    } else {
      // Fallback: if image loading failed, show error message
      fill(255, 100, 100);
      textAlign(CENTER, CENTER);
      textSize(24);
      text("Grid Image Not Found", width/2, height/2);
      text("Expected: data/" + getExpectedGridImageName(), width/2, height/2 + 30);
    }
  }
  
  // Helper method to get expected grid image name
  String getExpectedGridImageName() {
    if (level == 1) return "3x3 Grid.png";
    else if (level == 2) return "3x5 Grid.png"; // 修正：Level 2 是 3x5
    else if (level == 3) return "5x5 Grid.png";
    else return "3x3 Grid.png";
  }

  // Check if playable cell (keep only one definition)
  boolean isPlayableCell(int row, int col) {
    return row >= 1 && row <= playableRows && 
           col >= 1 && col <= playableCols;
  }

  // Check if gridIndicator position
  boolean isGridIndicatorCell(int row, int col) {
    // Check if on grid border
    boolean isOnBorder = (row == 0 || row == rows - 1 || col == 0 || col == cols - 1);
    boolean isValidPosition = (row >= 0 && row < rows && col >= 0 && col < cols);
    
    return isOnBorder && isValidPosition;
  }

  // Debug: show grid coordinates (simplified)
  void showDebugGrid() {
    fill(255, 200);
    textAlign(CENTER, CENTER);
    textSize(10);
    
    // Show only playable area coordinates
    for (int r = 1; r <= playableRows; r++) {
      for (int c = 1; c <= playableCols; c++) {
        float cellCenterX = originX + c * cellSize + cellSize/2;
        float cellCenterY = originY + r * cellSize + cellSize/2;
        
        // Playable area - semi-transparent overlay
        fill(255, 255, 255, 80);
        noStroke();
        rectMode(CENTER);
        rect(cellCenterX, cellCenterY, cellSize-4, cellSize-4);
        
        // Show absolute coordinates
        fill(0, 0, 0, 200);
        textSize(10);
        text("(" + r + "," + c + ")", cellCenterX, cellCenterY - 8);
        
        // Show playable area relative coordinates
        int playableRow = r - 1;
        int playableCol = c - 1;
        fill(0, 150, 0, 200);
        text("[" + playableRow + "," + playableCol + "]", cellCenterX, cellCenterY + 8);
      }
    }
    
    // Show grid info in corner
    fill(255, 255, 0, 200);
    noStroke();
    rectMode(CORNER);
    rect(width - 220, 10, 210, 120);
    
    fill(0);
    textAlign(LEFT, TOP);
    textSize(12);
    text("=== Grid Debug ===", width - 210, 20);
    text("Level: " + level + " (" + playableCols + "x" + playableRows + ")", width - 210, 35);
    text("Cell Size: " + cellSize, width - 210, 50);
    text("Origin: (" + (int)originX + ", " + (int)originY + ")", width - 210, 65);
    text("Playable Origin: (" + (int)(originX + cellSize) + ", " + (int)(originY + cellSize) + ")", width - 210, 80);
    text("Grid Size: " + (int)(playableCols * cellSize) + "x" + (int)(playableRows * cellSize), width - 210, 95);
    text("Image Size: " + (gridImage != null ? gridImage.width + "x" + gridImage.height : "N/A"), width - 210, 110);
    
    // Show player current position if available
    if (p != null) {
      PVector playerAbsPos = p.getAbsoluteGridPosition();
      
      // Highlight player position
      if (playerAbsPos.x >= 1 && playerAbsPos.x <= playableRows && 
          playerAbsPos.y >= 1 && playerAbsPos.y <= playableCols) {
        float playerCellX = originX + (int)playerAbsPos.y * cellSize + cellSize/2;
        float playerCellY = originY + (int)playerAbsPos.x * cellSize + cellSize/2;
        
        fill(255, 0, 0, 150);
        noStroke();
        rectMode(CENTER);
        rect(playerCellX, playerCellY, cellSize-4, cellSize-4);
      }
    }
  }

  // Boundary methods - return playable area boundaries (absolute coordinates)
  float leftBound() {
    return originX + cellSize; // Skip left gridIndicator column
  }

  float rightBound() {
    return originX + (cols - 1) * cellSize; // Exclude right gridIndicator column
  }

  float topBound() {
    return originY + cellSize; // Skip top gridIndicator row
  }

  float bottomBound() {
    return originY + (rows - 1) * cellSize; // Exclude bottom gridIndicator row
  }
  
  // Extended grid boundaries (including gridIndicator area)
  float fullLeftBound() {
    return originX;
  }

  float fullRightBound() {
    return originX + cols * cellSize;
  }

  float fullTopBound() {
    return originY;
  }

  float fullBottomBound() {
    return originY + rows * cellSize;
  }
  
  // Helper method to get grid cell coordinates
  PVector getGridCell(int row, int col) {
    if (row >= 0 && row < rows && col >= 0 && col < cols) {
      return new PVector(originX + col * cellSize, originY + row * cellSize);
    }
    return null;
  }
  
  // Helper method to snap position to grid
  PVector snapToGrid(float x, float y) {
    int col = (int)((x - originX) / cellSize);
    int row = (int)((y - originY) / cellSize);
    col = constrain(col, 1, cols - 2); // Limit to playable area
    row = constrain(row, 1, rows - 2);
    return new PVector(originX + col * cellSize, originY + row * cellSize);
  }
  
  // Get grid cell center position
  PVector getGridCellCenter(int row, int col) {
    if (row >= 0 && row < rows && col >= 0 && col < cols) {
      float centerX = originX + col * cellSize + cellSize / 2;
      float centerY = originY + row * cellSize + cellSize / 2;
      return new PVector(centerX, centerY);
    }
    return null;
  }

  // Check which grid cell position belongs to
  PVector getGridPosition(float x, float y) {
    int col = (int)((x - originX) / cellSize);
    int row = (int)((y - originY) / cellSize);
    
    if (row >= 0 && row < rows && col >= 0 && col < cols) {
      return new PVector(row, col);
    }
    return null;
  }

  // Check if grid cell is within boundaries
  boolean isValidGridPosition(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }
}
