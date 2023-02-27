//import processing.javafx.*;
import processing.sound.*;
import java.awt.Image;
import java.awt.Toolkit;
import java.awt.image.PixelGrabber;
SoundFile OST, digSound, shoot, itemGet;

//Save variables
final String fileName = "saveInfo.txt";
String[] saveData = new String [2];

//Map
int mapWidth, mapHeight;
final int[][] MAP_SIZES = {{65, 50}, {55, 46}, {45, 40}, {30, 26}};
Map[] maps;
MapGenerator mapGenerator = new MapGenerator();
int[] textureTiles = new int[mapWidth];
int tileSize = 64;
int visTilesX, visTilesY;
int fadeStart = 0, transitioningTo = 0;
final int[] NON_DIGGABLE = {0, 8, 10, 11}, WALKABLE = {0, 5, 10}; 

//Images
PImage floorHole, shot, vignette, hitVignette, ship, menu, loading;
PImage[] player = new PImage[3];
PImage[] npcMeelee = new PImage[4];
PImage[] bg = new PImage[2];
PImage[] endScreens = new PImage[3];
PImage[] introScreens = new PImage[4];
PImage[] items = new PImage[4];
PImage[] UI = new PImage[2];
PImage[] ceilHole = new PImage[2];
int tileType;
PImage[][] worldTiles = new PImage[3][16];

PFont pixelatedFont;
// PShader vignetteShader;

//Player variables
final int TIME_LIMIT = 60000, MOV_SPEED = 4;
float posX, posY, speedX = 0, speedY = 0, movSpeed;
int time, health, delayInt, vignetteCounter;
boolean countDownActive = false;
int ending = 3, counter = -1, level = -1;
int[] inventory;
boolean[] pressedKeys = {false,false,false,false};

JSONObject textJson;
String[] introText, endText, textUI;

//Objects
ArrayList<Bullet> bulletList = new ArrayList<Bullet>();

//SETTINGS FUNCTION -----------------
void settings() {
  loadSave();
  if (int(saveData[0])==1){
    fullScreen(P2D);
  } else size(displayWidth, displayHeight, P2D);
}

void setup() {  
  surface.setTitle("SPeace");
  ((PGraphicsOpenGL)g).textureSampling(2);
  frameRate(60);
  textAlign(CENTER, CENTER);
  visTilesX = ceil(width/tileSize);
  visTilesY = ceil(height/tileSize);
  //load images
  loading = loadImagePng("Loading.png", tileSize*8, tileSize*4);
  thread("load");
}

void load() {
  if(((double)Toolkit.getDefaultToolkit().getScreenResolution())/96.0 != 1) {
    double scalingFactor = ((double)Toolkit.getDefaultToolkit().getScreenResolution())/96.0;
    surface.setSize((int)(displayWidth*scalingFactor), (int)(displayHeight*scalingFactor));
  }
  pixelatedFont = createFont("BestTen-DOT.otf", 50);
  textFont(pixelatedFont);
  textJson = loadJSONObject(saveData[1] + "_Text.json");
  introText = textJson.getJSONArray("intro").getStringArray();
  endText = (String[])textJson.getJSONArray("endings").getStringArray();
  textUI = textJson.getJSONArray("UI").getStringArray();
  menu = loadImagePng("C1.png", width, height);
  worldTiles[0] = loadImagePng("Tilemap0.png", tileSize*4, 4, 4);
  worldTiles[1] = loadImagePng("Tilemap1.png", tileSize*4, 4, 4);
  worldTiles[2] = loadImagePng("Tilemap2.png", tileSize*4, 4, 4);
  player[0] = loadImagePng("Char1.png", tileSize);
  player[1] = loadImagePng("Char2.png", tileSize);
  player[2] = loadImagePng("Char3.png", tileSize);
  ceilHole[0] = loadImagePng("Land0_1.png", tileSize);
  ceilHole[1] = loadImagePng("Land0_2.png", tileSize);
  npcMeelee[0] = loadImagePng("Char7.png", tileSize);
  npcMeelee[1] = loadImagePng("Char8.png", tileSize);
  npcMeelee[2] = loadImagePng("Char9.png", tileSize);
  npcMeelee[3] = loadImagePng("Char10.png", tileSize);
  bg[0] = loadImagePng("BG0.png", tileSize);
  bg[1] = loadImagePng("BG1.png", tileSize);
  shot = loadImagePng("Shot.png", tileSize/4);
  items[0] = loadImagePng("Key.png", tileSize);
  items[1] = loadImagePng("Item4.png", tileSize);
  items[2] = loadImagePng("Item1.png", tileSize);
  items[3] = loadImagePng("Item6.png", tileSize);
  vignette = loadImagePng("Vig.png", width, height);
  // vignetteShader = loadShader("Vignette.glsl");
  UI[0] = loadImagePng("Frame1.png", tileSize/4, tileSize*4);
  UI[1] = loadImagePng("LifeFrame.png", tileSize, tileSize*2);
  introScreens[0] = loadImagePng("E2.png", width, height);
  introScreens[1] = loadImagePng("E3.png", width, height);
  introScreens[2] = loadImagePng("E4.png", width, height);
  introScreens[3] = loadImagePng("E5.png", width, height);
  hitVignette = loadImagePng("HitVig.png", width, height);
  digSound = new SoundFile(this, "Break.wav");
  digSound.amp(0.5);
  shoot = new SoundFile(this, "Shoot1.wav");
  itemGet = new SoundFile(this, "ItemGet.wav");
  level = -2;
  OST = new SoundFile(this, "OST.mp3");
  OST.loop();
  ship = loadImagePng("Nave.png", tileSize*6, tileSize*9);
  endScreens[0] = loadImagePng("D0.png", width, height);
  endScreens[1] = loadImagePng("D1.png", width, height);
  endScreens[2] = loadImagePng("E9.png", width, height);
}

void draw() {
  background(#08141E);
  if (level > 0) {
    if (level < 4 && ((mousePressed && mouseButton == RIGHT) || (keyPressed && key == 'e')) && millis()-delayInt > 80) {
      dig();
      delayInt = millis();
    } else if (level == 4 && millis()-delayInt > 4000) {
      ending = 2;
      changeScene(-3);
    }
    move();
    // shader(vignetteShader);
    drawMap();
    // resetShader();
    for (int i = 0; i < bulletList.size(); i++) {
      bulletList.get(i).update();
    }
    maps[level].updateNpcs();
    maps[level].updateItems();
    drawPlayer();
    image(vignette, 0, 0);
    drawUI();
  } else if (level == -1) {
    image(loading, width-tileSize*8, height-tileSize*4);
  } else if (level == -2) {
    image(menu, 0, 0, width, height);
  } else if (level == -3) {
    textSize(50);
    //Endings: 0 (death suffocation), 1 (death killed), 2 (escape but not saved earth), 3 (intro)
    if (ending == 3) {
      if (millis()-delayInt > 3000 && transitioningTo == 0) {
        if (counter >= 3) {
          changeScene(1);
        } else {
          changeScene(-3);
        }
      }
      image(introScreens[counter], 0, 0);
      fill(255);
      text(introText[counter], width/16, height/5*3.8, width/16*14, height/5);
      textSize(30);
      text(textUI[8], 0, height/5*4.7, width, height/20);
    } else {
      image(endScreens[ending], 0, 0);
      fill(255);
      text(endText[ending], width/16, height/5*3.7, width/16*14, height/5);
      textSize(30);
      text(textUI[9], 0, height/5*4.7, width, height/20);
    }
  } else if (level == -4 && transitioningTo == 0) changeScene(-3);
  if (fadeStart > 0) {
    if (millis()-fadeStart <= 1000)fill(#08141E, map(millis()-fadeStart, 0, 1000, 0, 255));
    else if (transitioningTo != 0) {
      fill(#08141E, 255);
      teleport(transitioningTo);
    } else fill(#08141E, map(millis()-fadeStart, 1000, 2000, 255, 0));
    if (millis()-fadeStart > 2000) fadeStart = 0;
    noStroke();
    rect(0, 0, width, height);
    stroke(255);
  }
  fill(255);
  text(frameRate, 150,100);
}

//MAP FUNCTIONS ------------------
int getMapPos(float x, float y) {
  x = floor(x);
  y = floor(y);
  if (x < 0) x = mapWidth+x;
  else if (x >= mapWidth) x = x-mapWidth;
  if (y < 0) y = mapHeight+y;
  else if (y >= mapHeight) y = y-mapHeight;
  return maps[level].map[int(x)][int(y)];
}
void setMapPos(float x, float y, int value) {
  x = floor(x);
  y = floor(y);
  if (x < 0) x = mapWidth+x;
  else if (x >= mapWidth) x = x-mapWidth;
  if (y < 0) y = mapHeight+y;
  else if (y >= mapHeight) y = y-mapHeight;
  if(maps[level].map[int(x)][int(y)] != 5) maps[level].map[int(x)][int(y)] = value;
}

//PLAYER FUNCTIONS ------------------
void move() {
  //collision
  movSpeed = MOV_SPEED/frameRate;
  if (speedX > 0 && contains(WALKABLE, getMapPos(posX+0.4+speedX*movSpeed, posY+0.45)) && !contains(new int[]{1}, getMapPos(posX+0.4+speedX*movSpeed, posY))) posX += speedX * movSpeed;
  else if (speedX < 0 && contains(WALKABLE, getMapPos(posX-0.4+speedX*movSpeed, posY+0.45)) && !contains(new int[]{1}, getMapPos(posX-0.4+speedX*movSpeed, posY))) posX += speedX * movSpeed;
  if (speedY > 0 && contains(WALKABLE, getMapPos(posX+0.4, posY+0.45+speedY*movSpeed)) && contains(WALKABLE, getMapPos(posX-0.4, posY+0.45+speedY*movSpeed))) posY += speedY * movSpeed;
  else if (speedY < 0 && contains(WALKABLE, getMapPos(posX+0.4, posY+speedY*movSpeed)) && contains(WALKABLE, getMapPos(posX-0.4, posY+speedY*movSpeed))) posY += speedY * movSpeed;
  if (posX < 0) posX = mapWidth-0.05;
  else if (posX >= mapWidth) posX = 0;
  if (posY < 0) posY = mapHeight-0.05;
  else if (posY >= mapHeight) posY = 0;
}
void keyPressed() {
  if (level > 0) {
    if (countDownActive == false) {
      countDownActive = true;
      time = millis();
    }
    if (key == 'w' || key == 'W' || keyCode == UP) {
      pressedKeys[0] = true;
      speedY = -1;
    } else if (key == 's' || key == 'S' || keyCode == DOWN) {
      pressedKeys[1] = true;
      speedY = 1;
    } else if (key == 'a' || key == 'A' || keyCode == LEFT) {
      pressedKeys[2] = true;
      speedX = -1;
    } else if (key == 'd' || key == 'D' || keyCode == RIGHT) {
      pressedKeys[3] = true;
      speedX = 1;
    } else if (key == 'q' || key == 'Q') {
      shoot();
    } else if (key == 'e' || key == 'E') {
      if (getMapPos(posX, posY) == 5 && level > 1) changeScene(level-1);
      else if (getMapPos(posX, posY) == 11 && level < 3) changeScene(level+1);
    }
  } else if (level == -3) {
    if (key == ' ') {
      changeScene(1);
    }
  } else if (level == -2 && key == ' ') {
    changeScene(-3);
  }
}
void keyReleased() {
  if (key == 'w' || key == 'W' || keyCode == UP) {
    pressedKeys[0] = false;
    if (pressedKeys[1]) speedY = 1;
    else speedY = 0;
  } else if (key == 's' || key == 'S' || keyCode == DOWN) {
    pressedKeys[1] = false;
    if (pressedKeys[0]) speedY = -1;
    else speedY = 0;
  } else if (key == 'a' || key == 'A' || keyCode == LEFT) {
    pressedKeys[2] = false;
    if (pressedKeys[3]) speedX = 1;
    else speedX = 0;
  } else if (key == 'd' || key == 'D' || keyCode == RIGHT) {
    pressedKeys[3] = false;
    if (pressedKeys[2]) speedX = -1;
    else speedX = 0;
  }
}

void dig() {
  if ((speedX != 0 || speedY != 0) /*&& digCooldown == 0*/) {
    if (digSound != null && !digSound.isPlaying()) digSound.play();

    if (speedX != 0) {
      if (!contains(NON_DIGGABLE, getMapPos(posX+speedX, posY+0.4))) setMapPos(posX+speedX, posY+0.4, 0);
      if (!contains(NON_DIGGABLE, getMapPos(posX+speedX, posY-0.4))) setMapPos(posX+speedX, posY-0.4, 0);
      //Check new surrounding tiles
      if (getMapPos(posX+speedX, posY-1.4) == 1) {
        if (getMapPos(posX+speedX, posY-2.4) == 1) setMapPos(posX+speedX, posY-1.4, 2);
        else setMapPos(posX+speedX, posY-1.4, 4);
      }
      if (getMapPos(posX+speedX, posY+1.4) == 2) setMapPos(posX+speedX, posY+1.4, 4);
    }

    if (speedY != 0) {
      if (!contains(NON_DIGGABLE, getMapPos(posX+0.4, posY+speedY))) setMapPos(posX+0.4, posY+speedY, 0);
      if (!contains(NON_DIGGABLE, getMapPos(posX-0.4, posY+speedY))) setMapPos(posX-0.4, posY+speedY, 0);
      //Check new surrounding tiles
      if (speedY > 0) {
        if (getMapPos(posX+0.4, posY+2) == 1 && getMapPos(posX+0.4, posY+3) != 1 && getMapPos(posX+0.4, posY+3) != 2) setMapPos(posX+0.4, posY+2, 4);
        else if (getMapPos(posX+0.4, posY+2) == 2) setMapPos(posX+0.4, posY+2, 4);
        if (getMapPos(posX-0.4, posY+2) == 1 && getMapPos(posX-0.4, posY+3) != 1 && getMapPos(posX-0.4, posY+3) != 2) setMapPos(posX-0.4, posY+2, 4);
        else if (getMapPos(posX-0.4, posY+2) == 2) setMapPos(posX-0.4, posY+2, 4);
      } else {
        if (getMapPos(posX+0.4, posY-2) == 1) {
          if (getMapPos(posX+0.4, posY-3) == 1) setMapPos(posX+0.4, posY-2, 2);
          else setMapPos(posX+0.4, posY-2, 4);
        }
        if (getMapPos(posX-0.4, posY-2) == 1) {
          if (getMapPos(posX-0.4, posY-3) == 1) setMapPos(posX-0.4, posY-2, 2);
          else setMapPos(posX-0.4, posY-2, 4);
        }
      }
    }
  } else if (getMapPos(posX, posY) == 10 && level > 0 && level < 3) {
    if (digSound != null && !digSound.isPlaying()) digSound.play();
    setMapPos(posX, posY, 11);
    changeScene(level+1);
  }
}

//Shoot
void shoot() {
  if(shoot != null)shoot.play();
  bulletList.add(new Bullet(posX+0.3, posY+0.4, 0.1, atan2(mouseY-height/2,mouseX-width/2), true));
}
void mousePressed() {
  if (mouseButton == LEFT && level > 0) {
    shoot();
  }
}

void drawPlayer() {
  if (speedX == 0 && speedY == 0) {
    image(player[0], width/2-tileSize/2, height/2-tileSize/2, tileSize, tileSize);
  } else {
    if (frameCount%16 < 8) image(player[1], width/2-tileSize/2, height/2-tileSize/2, tileSize, tileSize);
    else image(player[2], width/2-tileSize/2, height/2-tileSize/2, tileSize, tileSize);
  }
}

//DRAW FUNCTIONS --------------------
float tilePosX, tilePosY;
int jOriginal, iOriginal;
void drawMap() {
  int currentTile;
  for (int i = floor(posX)-visTilesX; i < floor(posX)+visTilesX; i++) {
    for (int j = floor(posY)-visTilesY; j < floor(posY)+visTilesY; j++) {
      tilePosX = tileSize*(i-posX) + width/2;
      tilePosY = tileSize*(j-posY) + height/2;
      iOriginal = i;
      jOriginal = j;
      if (i < 0) i = mapWidth+i;
      else if (i >= mapWidth) i = i-mapWidth;
      if (j < 0) j = mapHeight+j;
      else if (j >= mapHeight) j = j-mapHeight;

      currentTile = getMapPos(i, j);
      if (currentTile==0) { //Floor
        image(worldTiles[tileType][posSeed(3, i+j)], tilePosX, tilePosY);
      } else if (currentTile==1){ //Wall
        if (getMapPos(i+1,j) != 1 || getMapPos(i,j+1) != 1 || getMapPos(i-1,j) != 1 || getMapPos(i,j-1) != 1 || getMapPos(i+1,j+1) != 1 || getMapPos(i-1,j-1) != 1 || getMapPos(i+1,j-1) != 1 || getMapPos(i-1,j+1) != 1) image(worldTiles[tileType][posSeed(3, i+j)+5], tilePosX, tilePosY);
        else if (contains(textureTiles, i*j) || contains(textureTiles, int(i*j/2))) image(bg[posSeed(2, i*j)], tilePosX, tilePosY);
      } else if (currentTile==2) { //Top wall
        image(worldTiles[tileType][posSeed(2, i+j)+3], tilePosX, tilePosY);
      } else if (currentTile==3) { //Stalagmite
        image(worldTiles[tileType][12], tilePosX, tilePosY);
      } else if (currentTile==4) { //Top wall side
        image(worldTiles[tileType][posSeed(2, i+j)+8], tilePosX, tilePosY);
      } else if (currentTile==5 && getMapPos(i, j+2) == 5 && getMapPos(i+2, j) == 5) { //Ceiling hole
        image((level == 3) ? ceilHole[1] : ceilHole[0], tilePosX, tilePosY, tileSize*3, tileSize*3);
      } else if (currentTile==8) { //Door
        if (inventory[0] == 0) {
          image(worldTiles[tileType][10], tilePosX, tilePosY);
        } else {
          image(worldTiles[tileType][14], tilePosX, tilePosY);
        }
      } else if (currentTile == 9) { //Ship
        tilePosX = (i-5)*tileSize-posX*tileSize+width/2;
        tilePosY = (j-8)*tileSize-posY*tileSize+height/2;
        image(ship, tilePosX, tilePosY);
      } else if (currentTile == 10) image(worldTiles[tileType][11], tilePosX, tilePosY); //Diggable floor
      else if (currentTile == 11) image(worldTiles[tileType][15], tilePosX, tilePosY); //Dug floor
      
      i = iOriginal;
      j = jOriginal;
    }
  }
}

int posSeed(int num, int pos) {
  return pos % num;
}

void drawUI() {
  noStroke();
  fill(255);

  if (vignetteCounter != 0) {
    if (millis()-vignetteCounter > 200) vignetteCounter = 0;
    tint(255, map(millis()-vignetteCounter, 0, 200, 255, 0));
    image(hitVignette, 0, 0, width, height);
    tint(255, 255);
  }

  if (countDownActive && millis() > time+TIME_LIMIT) {
    countDownActive = false;
    ending = 1;
    changeScene(-3);
  }
  if (countDownActive) rect(width-width/20, height/5*4, width/30, 0-map(millis(), time+TIME_LIMIT, time, 0, height/5*3)+4);
  else rect(int(width-width/20+2), int(height/5*4-2), int(width/30-4), 0-int(height/5*3-4));
  image(UI[0], width-width/20, height/5, width/30, height/5*3);
  fill(255,0,0);
  rect(width/25, height/27, 1.5*tileSize, map(health,0,100,0,4*tileSize));
  image(UI[1], width/25, height/27, 1.5*tileSize, 4*tileSize);
  //Inventory
  for (int i = 0; i < inventory.length; i++) {
    if (inventory[i] != -1) {
      image(items[inventory[i]], width/20+tileSize*2*i, height-tileSize*3);
      if (inventory[i] == 1) {
        textSize(10);
        text("Left Click", width/20+tileSize*2*i, height-tileSize*2);
      } else if (inventory[i] == 2) {
        textSize(10);
        text("Right Click", width/20+tileSize*2*i, height-tileSize*2);
      }
    }
  }
  //Level transition
  if (getMapPos(posX, posY) == 10) banner(textUI[12]);
  //Tutorial
  if (level == 1 && !countDownActive) {
    drawKey("W", textUI[2], width/2-tileSize/2, height/2-tileSize*2, false);
    drawKey("D", textUI[3], width/2+tileSize, height/2-tileSize/2, false);
    drawKey("S", textUI[4], width/2-tileSize/2, height/2+tileSize, false);
    drawKey("A", textUI[5], width/2-tileSize*2, height/2-tileSize/2, false);
    drawKey("Left Mouse", textUI[6], width/2-tileSize*4, height/2-3*tileSize, true);
    drawKey("Right Mouse", textUI[7], width/2+tileSize*2, height/2-3*tileSize, true);
    banner(textUI[0]);
  }
}

//LEVELS
void changeScene(int n) {
  if (transitioningTo == 0) {
    fadeStart = millis();
    transitioningTo = n;
  }
}
//-3 = cinematic, -2 = menu, -1 = loading, 1 = main floor, 2 = second floor, 3 = third floor, 4 = spaceship
void teleport(int num) {
  transitioningTo = 0;
  bulletList.clear();
  switch (num) {
    case -3:
      countDownActive = false;
      delayInt = millis();
      level = -3;
      counter++;
    break;
    case 1:
      level = -1;
      tileType = 0;
      inventory = new int[]{1,2,-1};
      health = 100;
      maps = new Map[5];
      mapWidth = MAP_SIZES[0][0];
      mapHeight = MAP_SIZES[0][1];
      if (maps[1] == null) {
        posX = int(random(4,mapWidth-5))-0.5;
        posY = int(random(5,mapHeight-6))-0.5;
        maps[1] = new Map(mapGenerator.mapGenerate(7, mapWidth, mapHeight, ceil(posX)-4, ceil(posY)-5, num), mapGenerator.npcs, mapGenerator.pickups, mapGenerator.upLoc, mapGenerator.downLoc);
        for (int i = 0; i < textureTiles.length; i++) {
          textureTiles[i] = int(random(0, mapWidth*mapHeight));
        }
      }
      if (level > num && level >= 0) {
        posX = maps[num].downLoc[0]-0.5;
        posY = maps[num].downLoc[1]-0.5;
      }
      level = 1;
      counter = -1;
    break;
    case 2:
    case 3:
      tileType = num-1;
      mapWidth = MAP_SIZES[num-1][0];
      mapHeight = MAP_SIZES[num-1][1];
      if (maps[num] == null) {
        maps[num] = new Map(mapGenerator.mapGenerate(4, mapWidth, mapHeight, ceil(posX/1.25)-4, ceil(posY/1.25)-5, num), mapGenerator.npcs, mapGenerator.pickups, mapGenerator.upLoc, mapGenerator.downLoc);
        for (int i = 0; i < textureTiles.length; i++) {
          textureTiles[i] = int(random(0, mapWidth*mapHeight));
        }
      }
      if (level < num) {
        posX = maps[num].upLoc[0]-0.5;
        posY = maps[num].upLoc[1]-0.5;
      } else {
        posX = maps[num].downLoc[0]-0.5;
        posY = maps[num].downLoc[1]-0.5;
      }
      level = num;
    break;
    case 4:
      mapWidth = MAP_SIZES[num-1][0];
      mapHeight = MAP_SIZES[num-1][1];
      posX = mapWidth/2;
      posY = mapHeight/2;
      maps[4] = new Map(mapGenerator.mapGenerate(0, mapWidth, mapHeight, ceil(posX)-4, ceil(posY)-5, num), new ArrayList<NPC>(0), new ArrayList<Pickup>(0), mapGenerator.upLoc, mapGenerator.downLoc);
      countDownActive = false;
      delayInt = millis();
      level = 4;
    break;	
  }
}

//SAVE INFO -------------------------
void createSave() {
  saveData[0] = "1";
  saveData[1] = "en";
}

void loadSave() {
  if (dataFile(fileName).isFile()) {
    saveData=loadStrings(dataPath(fileName));
  } else {
    createSave();
    saveSave();
  }
}

void saveSave() {
  saveStrings(dataPath(fileName), saveData);
}

//UTILS
boolean contains(int[] arr, int key) {
  for (int i : arr) {
      if (i == key) {
          return true;
      }
  }
  return false;
}

void drawKey(String keyToShow, String alt, int x, int y, boolean wide) {
  fill(0);
  if (wide) rect(x, y, 2*tileSize, tileSize, tileSize/8);
  else rect(x, y, tileSize, tileSize, tileSize/8);
  fill(255);
  textSize(25);
  if (wide)text(keyToShow, x+tileSize, y+tileSize/3);
  else text(keyToShow, x+tileSize/2, y+tileSize/3);
  textSize(18);
  if (wide)text(alt, x+tileSize, y+tileSize/3*2.2);
  else text(alt, x+tileSize/2, y+tileSize/3*2.2);
}

void banner(String text) {
  fill(0);
  textSize(50);
  stroke(255);
  rect(width/6, height/1.22, width/6*4, height/10);
  fill(255);
  text(text, width/6, height/1.22, width/6*4, height/10);
}

PImage[] loadImagePngCpyPx(Image image, int w, int h, int xNum, int yNum) {
  PImage[] retval = new PImage[xNum*yNum];
  for (int i = 0; i < xNum*yNum; i++) {
    retval[i] = createImage(w/xNum,h/yNum,ARGB);
  }
  try {
    for (int i = 0; i < yNum; i++) {
      for (int j = 0; j < xNum; j++) {
        PixelGrabber grabber = new PixelGrabber(image, w/xNum*j, h/yNum*i, w/xNum, h/yNum, retval[i*xNum+j].pixels, 0, w/xNum);
        grabber.grabPixels();
      }
    }
  }
  catch (InterruptedException e1) {
    println("Problem loading loadImagePng, defaulting to loadImage().  Error: " + e1);
    exit();
  }
  return retval;
}
PImage[] loadImagePng(String inFile, int size, int xNum, int yNum) { return loadImagePngCpyPx(Toolkit.getDefaultToolkit().getImage(dataPath(inFile)).getScaledInstance(size, size, Image.SCALE_DEFAULT), size, size, xNum, yNum); }
PImage loadImagePng(String inFile, int w, int h) { return loadImagePngCpyPx(Toolkit.getDefaultToolkit().getImage(dataPath(inFile)).getScaledInstance(w, h, Image.SCALE_DEFAULT), w, h, 1, 1)[0]; }
PImage loadImagePng(String inFile, int size) { return loadImagePngCpyPx(Toolkit.getDefaultToolkit().getImage(dataPath(inFile)).getScaledInstance(size, size, Image.SCALE_DEFAULT), size, size, 1, 1)[0]; }
