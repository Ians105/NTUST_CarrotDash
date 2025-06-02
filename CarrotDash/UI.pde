class UI {
  // ==================== 字體與顏色設定 ====================
  // 修改建議：可以新增更多字體或調整顏色主題
  PFont notoFont; // 主要字體 - 可以更換為其他 .ttf/.otf 字體檔案

  // UI Colors - 顏色主題設定，可以整體更換遊戲風格
  color backgroundColor = color(0, 150);     // 背景色 - 調整透明度或顏色
  color textColor = color(255);              // 主要文字色 - 白色，可改為其他顏色
  color highlightColor = color(255, 255, 0); // 高亮色 - 黃色，用於重要提示
  color dangerColor = color(255, 100, 100);  // 危險色 - 紅色，用於警告
  color successColor = color(100, 255, 100); // 成功色 - 綠色，用於正面訊息
  color infoColor = color(200, 200, 255);    // 資訊色 - 淺藍，用於一般資訊

  // ==================== 字體大小設定 ====================
  // 修改建議：根據螢幕解析度調整字體大小比例
  int largeFontSize = 48;   // 大標題字體 - 可調整為 36-60
  int mediumFontSize = 32;  // 中等字體 - 可調整為 24-40
  int smallFontSize = 16;   // 小字體 - 可調整為 12-20
  int tinyFontSize = 12;    // 極小字體 - 可調整為 8-16

  // ==================== UI 位置設定 ====================
  // 修改建議：改變 UI 元素的位置和大小
  int gameInfoX;            // 遊戲資訊 X 座標 - 由程式計算置中
  int gameInfoY = 20;       // 遊戲資訊 Y 座標 - 可調整距離頂部的距離
  int gameInfoW = 300;      // 遊戲資訊寬度 - 可調整資訊框大小
  int gameInfoH = 80;       // 遊戲資訊高度 - 可調整資訊框大小

  int statusX;              // 玩家狀態 X 座標 - 由程式計算置中
  int statusY = 120;        // 玩家狀態 Y 座標 - 可調整在遊戲資訊下方的距離

  int enemyCountX;          // 敵人數量 X 座標 - 由程式計算右對齊
  int enemyCountY = 20;     // 敵人數量 Y 座標 - 可調整距離頂部的距離
  int enemyCountW = 150;    // 敵人數量寬度 - 可調整資訊框大小
  int enemyCountH = 60;     // 敵人數量高度 - 可調整資訊框大小

  // ==================== 建構函數 - 初始化設定 ====================
  UI() {
    // 計算置中位置 - 可修改為固定位置或其他對齊方式
    gameInfoX = (width - gameInfoW) / 2;  // 遊戲資訊置中
    statusX = width / 2;                  // 狀態資訊置中
    enemyCountX = width - 170;            // 敵人數量右對齊（距離右邊170像素）

    // ==================== 字體載入 ====================
    // 修改建議：更換字體檔案名稱，或添加更多備用字體
    try {
      // 主要字體檔案 - 可更換為您喜歡的字體
      notoFont = createFont("NotoSans-ExtraBold.ttf", 32);
      if (notoFont == null) {
        // 備用路徑1 - data資料夾中的字體
        notoFont = createFont("data/NotoSans-ExtraBold.ttf", 32);
      }
      if (notoFont == null) {
        // 備用路徑2 - .otf格式字體
        notoFont = createFont("NotoSans-ExtraBold.otf", 32);
      }
      if (notoFont == null) {
        // 備用路徑3 - data資料夾中的.otf字體
        notoFont = createFont("data/NotoSans-ExtraBold.otf", 32);
      }
      if (notoFont == null) {
        // 最後備用 - 系統內建字體
        notoFont = createFont("NotoSans-ExtraBold", 32);
      }
    }
    catch (Exception e) {
      // 字體載入失敗時的處理
      notoFont = null; // 使用系統預設字體
    }
  }

  // ==================== 字體設定方法 ====================
  // 修改建議：可添加粗體、斜體等字體樣式設定
  void setFont(int size) {
    if (notoFont != null) {
      textFont(notoFont, size); // 使用自訂字體
    } else {
      textSize(size);           // 使用系統預設字體
    }
  }

  // ==================== 主選單顯示 ====================
  // 修改建議：可添加動畫效果、按鈕懸浮效果等
  void showHomeMenu(PImage titleImage, PImage backgroundImage) {
    showBackground(backgroundImage);  // 顯示背景 - 可添加動畫背景
    showTitle(titleImage);           // 顯示標題 - 可添加淡入效果
    showMenuOptions();               // 顯示選項 - 可添加按鈕懸浮效果
  }

  // ==================== 背景顯示 ====================
  // 修改建議：可添加動態背景、粒子效果等
  void showBackground(PImage backgroundImage) {
    if (backgroundImage != null) {
      imageMode(CORNER);
      image(backgroundImage, 0, 0, width, height); // 顯示背景圖片
    } else {
      // 備用漸層背景 - 可修改顏色或漸層方向
      for (int i = 0; i <= height; i++) {
        float inter = map(i, 0, height, 0, 1);
        // 可修改這兩個顏色來改變漸層效果
        color c = lerpColor(color(50, 150, 50), color(20, 80, 20), inter);
        stroke(c);
        line(0, i, width, i);
      }
    }
  }

  // ==================== 標題顯示 ====================
  // 修改建議：可添加標題動畫、縮放效果、發光效果等
  void showTitle(PImage titleImage) {
    if (titleImage != null) {
      imageMode(CENTER);
      // 主選單：縮小50%
      // 添加呼吸效果
      float breathScale = 0.5 + sin(millis() * 0.002) * 0.05; // 0.45 到 0.55 之間變化
      image(titleImage, width/2, height/2 - 80, titleImage.width * breathScale, titleImage.height * breathScale);
    } else {
      // 文字標題保持不變
      textAlign(CENTER, CENTER);
      fill(0, 150);
      setFont(72);
      text("CARROT DASH", width / 2 + 3, height / 2 - 77);
      fill(255, 140, 0);
      text("CARROT DASH", width / 2, height / 2 - 80);
    }
  }

  // ==================== 選單選項顯示 ====================
  // 修改建議：可改為垂直排列、添加按鈕框、懸浮效果等
  void showMenuOptions() {
    textAlign(CENTER, CENTER);
    
    // ==================== 規則說明區域 ====================
    // 將規則說明向下移動，避免與標題重疊
    int centerY = height/2 + 10;
    
    /*// 說明區背景框 - 增加可讀性和視覺凸顯
    rectMode(CENTER);
    fill(0, 150); // 半透明黑色背景
    noStroke();
    // 繪製主要說明背景圓角矩形
    rect(width/2, centerY + 30, 740, 120, 15);*/
    
    // 標題 - 視覺增強
    fill(255, 255, 150); // 淺黃色標題
    setFont(26); // 較大字體
    text("GAME RULES", width/2, centerY - 20);
    
    // 說明文字陰影
    fill(0, 200);
    setFont(18);
    text("Each level lasts 60 seconds - Complete all 3 levels to win!", width/2 + 1, centerY + 1);
    text("Use WASD or Arrow Keys to move", width/2 + 1, centerY + 30 + 1);
    text("Avoid enemies and collect power-ups", width/2 + 1, centerY + 60 + 1);
    
    // 說明文字主體 - 白色文字
    fill(255);
    text("Each level lasts 60 seconds - Complete all 3 levels to win!", width/2, centerY);
    text("Use WASD or Arrow Keys to move", width/2, centerY + 30);
    text("Avoid enemies and collect power-ups", width/2, centerY + 60);
    
    // ==================== 關卡選擇區域 ====================
    // 在畫面下方顯示關卡選擇指示
    int levelY = height - 130; // 在畫面下方，但不太靠近底部
    
    // 關卡選擇背景
    fill(0, 170);
    rect(width/2, levelY + 30, 760, 100, 15);
    
    // 關卡選擇標題
    fill(255, 220, 150);
    setFont(26);
    text("SELECT A LEVEL", width/2, levelY - 20);
    
    // 設置三個關卡的水平位置
    int[] levelX = {width/2 - 250, width/2, width/2 + 250}; // 三個水平位置
    String[] levelNames = {"Level 1", "Level 2", "Level 3"};
    String[] keyNames = {"Press 1", "Press 2", "Press 3"};
    String[] difficultyTexts = {"Beginner", "Intermediate", "Advanced"};
    
    // 繪製三個關卡選項 - 只使用文字，不是按鈕
    for (int i = 0; i < 3; i++) {
      // 關鍵按鍵提示
      fill(255, 255, 200);
      setFont(24);
      text(keyNames[i], levelX[i], levelY);
      
      // 關卡名稱
      fill(255);
      setFont(20);
      text(levelNames[i], levelX[i], levelY + 30);
      
      // 難度說明
      fill(200, 200, 255);
      setFont(16);
      text(difficultyTexts[i], levelX[i], levelY + 60);
    }
    
    // 底部提示文字
    fill(150, 255, 150, 180);
    setFont(14);
    text("Press the number key to start a level", width/2, height - 30);
  }

  // ==================== 載入畫面 ====================
  void showLoadingScreen(PImage titleImage, PImage backgroundImage, int loadingStartTime) {
    // 顯示背景
    showBackground(backgroundImage);
    
    // ==================== 進度計算 ====================
    int elapsedTime = millis() - loadingStartTime;
    // 進度條載到100%的總時間縮短為4秒
    final int TOTAL_LOAD_TIME = 4000; // 縮短為4秒
    float progress = constrain((float)elapsedTime / TOTAL_LOAD_TIME, 0.0, 1.0);
    
    // ==================== 載入頁面標題 ====================
    if (titleImage != null) {
      imageMode(CENTER);
      // TitleImage 淡入時間與進度條載到100%時間相等 (4秒)
      float fadeScale = map(progress, 0.0, 1.0, 0.0, 0.5);
      image(titleImage, width/2, height/2 - 100, titleImage.width * fadeScale, titleImage.height * fadeScale);
    } else {
      // 備用文字標題
      textAlign(CENTER, CENTER);
      
      // 標題淡入效果
      float titleAlpha = map(progress, 0.0, 1.0, 50, 255);
      
      // 陰影
      fill(0, titleAlpha * 0.6);
      setFont(72);
      text("CARROT DASH", width / 2 + 3, height / 2 - 97);
      
      // 主標題
      fill(255, 140, 0, titleAlpha);
      text("CARROT DASH", width / 2, height / 2 - 100);
    }
    
    // ==================== 長條形進度條設定 ====================
    // 進度條位置與標題增加間距
    int barWidth = 400;       // 進度條寬度
    int barHeight = 30;       // 進度條高度
    int cornerRadius = 15;    // 圓角半徑
    
    // 進度條位置
    int barX = (width - barWidth) / 2;
    int barY = height- 150;  // 與標題增加間距
   
    // 繪製進度條外框
    noFill();
    stroke(255, 150);
    strokeWeight(2);
    rect(barX, barY, barWidth, barHeight, cornerRadius);
    
    // ==================== 進度條填充 ====================
    noStroke();
    
    // 載入填滿為橘色
    fill(255, 140, 0); // 橘色填充
    
    // 計算填充寬度（需要考慮圓角）
    int fillWidth = int(barWidth * progress);
    
    // 繪製進度填充（帶圓角）
    if (fillWidth > 0) {
      // 如果進度小於整個條寬，使用左邊圓角
      if (fillWidth < barWidth) {
        rect(barX + 2, barY + 2, fillWidth - 4, barHeight - 4, cornerRadius, 0, 0, cornerRadius);
      } else {
        // 如果進度已滿，四個角都是圓角
        rect(barX + 2, barY + 2, barWidth - 4, barHeight - 4, cornerRadius);
      }
    }
  }

  // ==================== 遊戲中 UI 主控制器 ====================
  // 修改建議：可添加更多遊戲資訊顯示，如分數、道具等
  void showGameUI(int survivalTime, int level, Player player, int enemyCount) {
    showGameInfo(survivalTime, level);    // 顯示關卡和時間資訊
    showPlayerStatus(player);             // 顯示玩家狀態效果
    showEnemyCount(enemyCount);          // 顯示敵人數量
  }

  // ==================== 遊戲資訊顯示 ====================
  // 修改建議：可添加分數、生命值、道具數量等資訊
  void showGameInfo(int timeRemaining, int level) {
    textAlign(CENTER, TOP);
    
    // 計算剩餘秒數
    int secondsRemaining = max(0, timeRemaining / 1000);
    
    // ==================== 時間顏色動態變化 ====================
    // 可修改時間警告的顏色和觸發時間
    color timeColor = textColor;
    if (secondsRemaining <= 10) {
      timeColor = dangerColor;              // 最後10秒紅色警告
    } else if (secondsRemaining <= 20) {
      timeColor = highlightColor;           // 最後20秒黃色警告
    } else if (secondsRemaining <= 30) {
      timeColor = color(255, 200, 0);       // 最後30秒橙色警告
    }
    
    // ==================== 關卡資訊顯示 ====================
    // 關卡資訊陰影
    fill(0, 150);
    setFont(largeFontSize); // 可調整關卡文字大小
    text("Level " + level, width/2 + 2, gameInfoY + 2);
    
    // 時間資訊陰影
    setFont(36); // 可調整時間文字大小
    text("Time: " + secondsRemaining + "s", width/2 + 2, gameInfoY + 52);
    
    // 關卡資訊主體
    fill(textColor); // 可修改關卡文字顏色
    setFont(largeFontSize);
    text("Level " + level, width/2, gameInfoY);
    
    // 時間資訊主體（動態顏色）
    fill(timeColor);
    setFont(36);
    text("Time: " + secondsRemaining + "s", width/2, gameInfoY + 50);
    
    // ==================== 加速狀態指示 ====================
    // 可修改加速狀態的顯示樣式和觸發條件
    if (secondsRemaining <= 30 && secondsRemaining > 0) {
      // 加速提示陰影
      fill(0, 150);
      setFont(smallFontSize);
      text("SPEED BOOST ACTIVE", width/2 + 1, gameInfoY + 91);
      
      // 加速提示主體
      fill(highlightColor); // 可修改加速提示顏色
      text("SPEED BOOST ACTIVE", width/2, gameInfoY + 90);
    }
  }

  // ==================== 玩家狀態顯示 ====================
  // 修改建議：可添加更多狀態效果，改變顯示位置或樣式
  void showPlayerStatus(Player player) {
    setFont(smallFontSize);
    textAlign(CENTER, TOP);
    int currentY = statusY; // 起始 Y 座標
    int lineHeight = 20;    // 行高 - 可調整狀態之間的間距

    // ==================== 翻轉狀態 ====================
    if (player.isFlipped) {
      // 翻轉狀態陰影
      fill(0, 150);
      text("FLIPPED!", statusX + 2, currentY + 2);
      // 翻轉狀態主體 - 可修改顏色
      fill(255, 0, 255); // 紫色，可修改為其他顏色
      text("FLIPPED!", statusX, currentY);
      currentY += lineHeight;
    }

    // ==================== 無敵狀態 ====================
    if (player.isInvincible) {
      // 無敵狀態陰影
      fill(0, 150);
      text("INVINCIBLE!", statusX + 2, currentY + 2);
      // 無敵狀態主體
      fill(highlightColor); // 可修改無敵狀態顏色
      text("INVINCIBLE!", statusX, currentY);
      currentY += lineHeight;
    }

    // ==================== 格線追蹤狀態 ====================
    if (player.showGridIndicator) {
      // 格線追蹤陰影
      fill(0, 150);
      text("GRID TRACKER!", statusX + 2, currentY + 2);
      // 格線追蹤主體
      fill(successColor); // 可修改格線追蹤顏色
      text("GRID TRACKER!", statusX, currentY);
      currentY += lineHeight;
    }
  }

  // ==================== 敵人數量顯示 ====================
  // 修改建議：可改為左對齊、置中對齊，或添加敵人圖示
  void showEnemyCount(int enemyCount) {
    textAlign(RIGHT, TOP); // 右對齊 - 可修改為其他對齊方式
    setFont(smallFontSize);

    // 敵人數量陰影
    fill(0, 150);
    text("Enemies: " + enemyCount, enemyCountX + 2, enemyCountY + 2);

    // 敵人數量主體
    fill(dangerColor); // 紅色 - 可修改為其他顏色
    text("Enemies: " + enemyCount, enemyCountX, enemyCountY);
  }

  // ==================== 加速訊息顯示 ====================
  // 修改建議：可改變動畫效果、顯示時間、文字內容等
  void showSpeedUpMessage(boolean isSpeedingUp, int speedUpStartTime) {
    if (isSpeedingUp) {
      int elapsedTime = millis() - speedUpStartTime;
      
      // 顯示時間設定 - 可修改顯示持續時間
      if (elapsedTime <= 3000) { // 3秒顯示時間
        // 閃爍效果 - 可修改閃爍頻率
        boolean shouldShow = (elapsedTime / 500) % 2 == 0; // 每500毫秒切換
        
        if (shouldShow) {
          textAlign(CENTER, CENTER);
          
          // ==================== 主要加速訊息 ====================
          // 陰影效果
          fill(0, 200);
          setFont(largeFontSize + 12); // 可調整文字大小
          text("SPEEDING UP!", width/2 + 3, height/2 + 3);
          
          // 主要文字 - 可修改顏色和文字內容
          fill(255, 255, 0, 255); // 純黃色
          text("SPEEDING UP!", width/2, height/2);
          
          // ==================== 副標題訊息 ====================
          setFont(mediumFontSize);
          fill(255, 255, 100, 200); // 可修改副標題顏色
          text("All enemies are faster!", width/2, height/2 + 60); // 可修改副標題內容
        }
      }
    }
  }

  // ==================== 遊戲結果顯示 ====================
  // 修改建議：可添加動畫效果、分數顯示、排行榜等
  void showGameResult(String message, PImage backgroundImage) {
    // 顯示背景
    showBackground(backgroundImage);

    textAlign(CENTER, CENTER);

    // ==================== 結果訊息顯示 ====================
    // 結果訊息陰影
    fill(0, 200);
    setFont(largeFontSize); // 可調整結果文字大小
    text(message, width/2 + 3, height/2 - 37); // message 可為 "YOU WIN!" 或 "YOU LOST!"
    
    // 重新開始提示陰影
    setFont(24);
    text("Press R to restart", width/2 + 2, height/2 + 22);

    // 結果訊息主體
    fill(textColor); // 可修改結果文字顏色
    setFont(largeFontSize);
    text(message, width/2, height/2 - 40);
    
    // 重新開始提示主體
    setFont(24);
    text("Press R to restart", width/2, height/2 + 20); // 可修改重新開始提示文字
  }

  // ==================== 除錯資訊顯示 ====================
  // 修改建議：可添加更多除錯資訊，改變顯示位置或樣式
  void showDebugInfo(Player player, ArrayList<Enemy> enemies, ArrayList<Item> items, ArrayList<GridIndicator> gridIndicators) {
    // 只有按下 'd' 鍵時才顯示 - 可修改觸發鍵
    if (keyPressed && key == 'd') {
      textAlign(LEFT, TOP);
      setFont(tinyFontSize); // 可調整除錯文字大小

      // 除錯資訊位置 - 可修改顯示位置
      int debugX = width - 290;    // 距離右邊290像素
      int debugY = height - 190;   // 距離底部190像素
      int lineHeight = 15;         // 行高

      // ==================== 除錯資訊陰影 ====================
      fill(0, 150);
      text("=== DEBUG INFO ===", debugX + 1, debugY + 1);
      debugY += lineHeight;

      // 玩家資訊
      if (player != null) {
        PVector playerPos = player.getCurrentGridPosition();
        text("Player: (" + (int)player.x + ", " + (int)player.y + ")", debugX + 1, debugY + 1);
        debugY += lineHeight;
        text("Grid: (" + (int)playerPos.x + ", " + (int)playerPos.y + ")", debugX + 1, debugY + 1);
        debugY += lineHeight;
      }

      // 遊戲物件數量資訊
      text("Enemies: " + enemies.size(), debugX + 1, debugY + 1);
      debugY += lineHeight;
      text("Items: " + items.size(), debugX + 1, debugY + 1);
      debugY += lineHeight;
      text("Gophers: " + gridIndicators.size(), debugX + 1, debugY + 1);
      debugY += lineHeight;
      text("FPS: " + (int)frameRate, debugX + 1, debugY + 1);
      debugY += lineHeight;
      text("Font: " + (notoFont != null ? "NotoSans-ExtraBold" : "Default"), debugX + 1, debugY + 1);

      // 重置位置準備繪製主要文字
      debugY = height - 190;

      // ==================== 除錯資訊主體 ====================
      fill(255, 255, 0); // 黃色除錯文字 - 可修改顏色
      text("=== DEBUG INFO ===", debugX, debugY);
      debugY += lineHeight;

      // 重複繪製主要除錯資訊（無陰影版本）
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
      debugY += lineHeight;
      text("Font: " + (notoFont != null ? "NotoSans-ExtraBold" : "Default"), debugX, debugY);
    }
  }

  // ==================== 控制說明顯示 ====================
  // 修改建議：可改變觸發鍵、顯示位置、控制說明內容等
  void showControlsHelp() {
    // 只有按下 'h' 鍵時才顯示 - 可修改觸發鍵
    if (keyPressed && key == 'h') {
      textAlign(CENTER, TOP);
      int lineHeight = 20;         // 行高 - 可調整
      int helpY = height/2 - 100;  // 起始 Y 座標

      // ==================== 控制說明標題 ====================
      // 標題陰影
      fill(0, 150);
      setFont(20); // 可調整標題文字大小
      text("CONTROLS", width/2 + 1, height/2 - 129);

      // ==================== 控制說明內容陰影 ====================
      setFont(16); // 可調整說明文字大小

      // 各項控制說明 - 可修改說明內容
      text("WASD or Arrow Keys - Move", width/2 + 1, helpY + 1);
      helpY += lineHeight;
      text("D - Toggle Debug Info", width/2 + 1, helpY + 1);
      helpY += lineHeight;
      text("H - Show/Hide Help", width/2 + 1, helpY + 1);
      helpY += lineHeight;
      text("R - Restart (in game over)", width/2 + 1, helpY + 1);
      helpY += lineHeight;
      text("1/2/3 - Select Level (in menu)", width/2 + 1, helpY + 1);
      helpY += lineHeight * 2; // 額外間距

      // 遊戲目標說明陰影
      setFont(14);
      text("Goal: Complete all 3 levels!", width/2 + 1, helpY + 1);

      // 重置位置準備繪製主要文字
      helpY = height/2 - 100;

      // ==================== 控制說明主體 ====================
      // 標題主體
      fill(textColor); // 可修改標題顏色
      setFont(20);
      text("CONTROLS", width/2, height/2 - 130);

      // 控制說明主體
      setFont(16);
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

      // 遊戲目標主體
      setFont(14);
      fill(infoColor); // 可修改目標說明顏色
      text("Goal: Complete all 3 levels!", width/2, helpY);
    }
  }

  // ==================== 位置更新方法 ====================
  // 修改建議：當視窗大小改變時重新計算UI元素位置
  void updatePositions() {
    gameInfoX = (width - gameInfoW) / 2;  // 重新計算遊戲資訊置中位置
    statusX = width / 2;                  // 重新計算狀態資訊置中位置
    enemyCountX = width - 170;            // 重新計算敵人數量右對齊位置
  }
}
