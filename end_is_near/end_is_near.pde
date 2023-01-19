//import processing.javafx.*;
import processing.sound.*;
import java.awt.Image;
import java.awt.Toolkit;
import java.awt.image.PixelGrabber;
SoundFile OST, breakRock, shoot, itemGet;

//Save variables
final String fileName = "saveInfo.txt";
String[] saveData = new String [2];

//Map
int mapWidth, mapHeight;
ArrayList<int[][]> maps = new ArrayList<int[][]>(5);
int[][] activeMap;
MapGenerator mapGenerator = new MapGenerator();
int[] textureTiles = new int[mapWidth];
int tileSize = 64;
int visTilesX, visTilesY;
int fadeStart = 0, transitioningTo = 0;

//Images
PImage stalagmite, ceilHole, floorHole, floorDiggable, shot, vignette, hitVignette, door, doorOpen, ship, menu, loading;
PImage[] player = new PImage[3];
PImage[] topWall = new PImage[2];
PImage[] ground = new PImage[3];
PImage[] wall = new PImage[3];
PImage[] topWallSide = new PImage[2];
PImage[] npcMeelee = new PImage[4];
PImage[] bg = new PImage[2];
PImage[] endScreens = new PImage[3];
PImage[] introScreens = new PImage[4];
PImage[] items = new PImage[3];
PImage[] UI = new PImage[2];

PFont pixelatedFont;
//PShader vignetteShader;

//Player variables
final int TIME_LIMIT = 60000;
float posX, posY, speedX = 0, speedY = 0;
int time, health, delayInt, vignetteCounter;
boolean countDownActive = false;
int ending = 3, counter = -1, level = -1;
int[] inventory;

JSONObject textJson;
String[] introText;
String[] endText;

//Objects
ArrayList<NPC> npcList;
ArrayList<Bullet> bulletList = new ArrayList<Bullet>();
ArrayList<Pickup> itemList = new ArrayList<Pickup>();

//SETTINGS FUNCTION -----------------
void settings() {
  loadSave();
  if (int(saveData[0])==1){
    fullScreen();
    //else size(displayWidth, displayHeight, P2D);
  }
  else size(1280, 720);
  noSmooth();
}

void setup() {
  //((PGraphicsOpenGL)g).textureSampling(2);
  frameRate(60);
  textAlign(CENTER, CENTER);
  visTilesX = ceil(width/tileSize);
  visTilesY = ceil(height/tileSize);

  //load images
  loading = loadImagePng("Loading.png", tileSize*8, tileSize*4);
  thread("load");
}

void load() {
  for (int i = 0; i < 5; i++) {
    maps.add(new int[1][1]);
  }
  pixelatedFont = createFont("MotorolaScreentype.ttf", 50);
  textFont(pixelatedFont);
  textJson = loadJSONObject(saveData[1] + "_Text.json");
  introText = textJson.getJSONArray("intro").getStringArray();
  endText = (String[])textJson.getJSONArray("endings").getStringArray();
  menu = loadImagePng("C1.png", width, height);
  ground[0] = loadImagePng("Suelo0_0.png", tileSize);
  ground[1] = loadImagePng("Suelo0_1.png", tileSize);
  ground[2] = loadImagePng("Suelo0_2.png", tileSize);
  wall[0] = loadImagePng("Pared0_0.png", tileSize);
  wall[1] = loadImagePng("Pared0_1.png", tileSize);
  wall[2] = loadImagePng("Pared0_2.png", tileSize);
  topWall[0] = loadImagePng("Pared0_4.png", tileSize);
  topWall[1] = loadImagePng("Pared0_5.png", tileSize);
  topWallSide[0] = loadImagePng("Pared0_6.png", tileSize);
  topWallSide[1] = loadImagePng("Pared0_7.png", tileSize);
  stalagmite = loadImagePng("Estalagmita0.png", tileSize);
  player[0] = loadImagePng("Char1.png", tileSize);
  player[1] = loadImagePng("Char2.png", tileSize);
  player[2] = loadImagePng("Char3.png", tileSize);
  ceilHole = loadImagePng("Entr.png", tileSize);
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
  vignette = loadImagePng("Vig.png", width, height);
  //vignetteShader = loadShader("Vignette.glsl");
  door = loadImagePng("Pared0_EN.png", tileSize);
  UI[0] = loadImagePng("Frame1.png");
  UI[1] = loadImagePng("LifeFrame.png");
  introScreens[0] = loadImagePng("E2.png", width, height);
  introScreens[1] = loadImagePng("E3.png", width, height);
  introScreens[2] = loadImagePng("E4.png", width, height);
  introScreens[3] = loadImagePng("E5.png", width, height);
  hitVignette = loadImagePng("HitVig.png", width, height);
  breakRock = new SoundFile(this, "Break.wav");
  breakRock.amp(0.5);
  shoot = new SoundFile(this, "Shoot1.wav");
  itemGet = new SoundFile(this, "ItemGet.wav");
  level = -2;
  OST = new SoundFile(this, "OST.mp3");
  OST.loop();
  doorOpen = loadImagePng("Pared0_3.png", tileSize);
  ship = loadImagePng("Nave.png");
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
    drawMap();
    for (int i = 0; i < bulletList.size(); i++) {
      bulletList.get(i).update();
    }
    for (int i = 0; i < npcList.size(); i++) {
      npcList.get(i).drawNPC();
    }
    for (int i = 0; i < itemList.size(); i++) {
      itemList.get(i).update();
    }
    drawPlayer();
    image(vignette, 0, 0);
    //shader(vignetteShader);
    drawUI();
  } else if (level == -1) {
    image(loading, width-tileSize*8, height-tileSize*4);
  } else if (level == -2) {
    image(menu, 0, 0, width, height);
  } else if (level == -3) {
    textSize(50);
    //Endings: 0 (death suffocation), 1 (death killed), 2 (escape but not saved earth), 3 (intro)
    if (ending == 3) {
      if (millis()-delayInt > 2500 && transitioningTo == 0) {
        if (counter >= 3) {
          changeScene(1);
        } else {
          changeScene(-3);
        }
      }
      image(introScreens[counter], 0, 0);
      fill(255);
      text(introText[counter], width/16, height/5*3.8, width/16*14, height/5);
    } else {
      image(endScreens[ending], 0, 0);
      fill(255);
      text(endText[ending], width/16, height/5*3.7, width/16*14, height/5);
      textSize(30);
      text("SPACE to play again", 0, height/5*4.7, width, height/20);
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
  text(frameRate, 100,100);
}

//MAP FUNCTIONS ------------------
int getMapPos(int x, int y) {
  if (x < 0) x = mapWidth+x;
  else if (x >= mapWidth) x = x-mapWidth;
  if (y < 0) y = mapHeight+y;
  else if (y >= mapHeight) y = y-mapHeight;
  return activeMap[x][y];
}
void setMapPos(int x, int y, int value) {
  if (x < 0) x = mapWidth+x;
  else if (x >= mapWidth) x = x-mapWidth;
  if (y < 0) y = mapHeight+y;
  else if (y >= mapHeight) y = y-mapHeight;
  if(activeMap[x][y] != 5)activeMap[x][y] = value;
}

//PLAYER FUNCTIONS ------------------
void move() {
  //collision
  if (speedX > 0 && contains(new int[]{0,5}, getMapPos(floor(posX+0.4+speedX),floor(posY+0.45))) && !contains(new int[]{1}, getMapPos(floor(posX+0.4+speedX),floor(posY)))) posX += speedX;
  else if (speedX < 0 && contains(new int[]{0,5}, getMapPos(floor(posX-0.4+speedX),floor(posY+0.45))) && !contains(new int[]{1}, getMapPos(floor(posX-0.4+speedX),floor(posY)))) posX += speedX;
  if (speedY > 0 && contains(new int[]{0,5}, getMapPos(floor(posX+0.4),floor(posY+0.45+speedY))) && contains(new int[]{0,5}, getMapPos(floor(posX-0.4),floor(posY+0.45+speedY)))) posY += speedY;
  else if (speedY < 0 && contains(new int[]{0,5}, getMapPos(floor(posX+0.4),floor(posY+speedY))) && contains(new int[]{0,5}, getMapPos(floor(posX-0.4),floor(posY+speedY)))) posY += speedY;
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
    if (key == ' '){
      changeScene(2);
    }
    if (key == 'w' || key == 'W' || keyCode == UP) {
      speedY = -0.1;
    } else if (key == 's' || key == 'S' || keyCode == DOWN) {
      speedY = 0.1;
    } else if (key == 'a' || key == 'A' || keyCode == LEFT) {
      speedX = -0.1;
    } else if (key == 'd' || key == 'D' || keyCode == RIGHT) {
      speedX = 0.1;
    }
  } else if (level == -3 && ending != 3) {
    if (key == ' ') {
      changeScene(1);
    }
  } else if (level == -2 && key == ' ') {
    changeScene(-3);
  }
}
void keyReleased() {
  if (key == 'w' || key == 'W' || keyCode == UP || key == 's' || key == 'S' || keyCode == DOWN) {
    speedY = 0;
  } else if (key == 'a' || key == 'A' || keyCode == LEFT || key == 'd' || key == 'D' || keyCode == RIGHT) {
    speedX = 0;
  }
}

void dig() {
  if(breakRock != null && !breakRock.isPlaying())breakRock.play();
  if (speedX > 0) {
    if (!contains(new int[]{0,8}, getMapPos(floor(posX+1), floor(posY+0.4)))) setMapPos(floor(posX+1), floor(posY+0.4), 0);
    if (!contains(new int[]{0,8}, getMapPos(floor(posX+1), floor(posY-0.4)))) setMapPos(floor(posX+1), floor(posY-0.4), 0);
    if (getMapPos(floor(posX+1), floor(posY-0.4)-1) == 1) {
      if (getMapPos(floor(posX+1), floor(posY-0.4)-2) == 1) setMapPos(floor(posX+1), floor(posY-0.4)-1, 2);
      else setMapPos(floor(posX+1), floor(posY-0.4)-1, 4);
    }
    if (getMapPos(floor(posX+1), floor(posY+0.4)+1) == 2) setMapPos(floor(posX+1), floor(posY+0.4)+1, 4);
  } else if (speedX < 0) {
    if (!contains(new int[]{0,8}, getMapPos(floor(posX-1), floor(posY+0.4)))) setMapPos(floor(posX-1), floor(posY+0.4), 0);
    if (!contains(new int[]{0,8}, getMapPos(floor(posX-1), floor(posY-0.4)))) setMapPos(floor(posX-1), floor(posY-0.4), 0);
    if (getMapPos(floor(posX-1), floor(posY-0.4)-1) == 1) {
      if (getMapPos(floor(posX-1), floor(posY-0.4)-2) == 1) setMapPos(floor(posX-1), floor(posY-0.4)-1, 2);
      else setMapPos(floor(posX-1), floor(posY-0.4)-1, 4);
    }
    if (getMapPos(floor(posX-1), floor(posY+0.4)+1) == 2) setMapPos(floor(posX-1), floor(posY+0.4)+1, 4);
  } else if (speedY > 0) {
    if (!contains(new int[]{0,8}, getMapPos(floor(posX+0.4), floor(posY+1)))) setMapPos(floor(posX+0.4), floor(posY+1), 0);
    if (getMapPos(floor(posX+0.4), floor(posY+1)+1) == 1 && (getMapPos(floor(posX+0.4), floor(posY+1)+2) != 1 && getMapPos(floor(posX+0.4), floor(posY+1)+2) != 2)) setMapPos(floor(posX+0.4), floor(posY+1)+1, 4);
    else if (getMapPos(floor(posX+0.4), floor(posY+1)+1) == 2) setMapPos(floor(posX+0.4), floor(posY+1)+1, 4);
    if (!contains(new int[]{0,8}, getMapPos(floor(posX-0.4), floor(posY+1)))) setMapPos(floor(posX-0.4), floor(posY+1), 0);
    if (getMapPos(floor(posX-0.4), floor(posY+1)+1) == 1 && (getMapPos(floor(posX-0.4), floor(posY+1)+2) != 1 && getMapPos(floor(posX-0.4), floor(posY+1)+2) != 2)) setMapPos(floor(posX-0.4), floor(posY+1)+1, 4);
    else if (getMapPos(floor(posX-0.4), floor(posY+1)+1) == 2) setMapPos(floor(posX-0.4), floor(posY+1)+1, 4);
  } else if (speedY < 0) {
    if (!contains(new int[]{0,8}, getMapPos(floor(posX+0.4), floor(posY-1)))) setMapPos(floor(posX+0.4), floor(posY-1), 0);
    if (!contains(new int[]{0,8}, getMapPos(floor(posX-0.4), floor(posY-1)))) setMapPos(floor(posX-0.4), floor(posY-1), 0);
    if (getMapPos(floor(posX+0.4), floor(posY-1)-1) == 1) {
      if (getMapPos(floor(posX+0.4), floor(posY-1)-2) == 1) setMapPos(floor(posX+0.4), floor(posY-1)-1, 2);
      else setMapPos(floor(posX+0.4), floor(posY-1)-1, 4);
    }
    if (getMapPos(floor(posX-0.4), floor(posY-1)-1) == 1) {
      if (getMapPos(floor(posX-0.4), floor(posY-1)-2) == 1) setMapPos(floor(posX-0.4), floor(posY-1)-1, 2);
      else setMapPos(floor(posX-0.4), floor(posY-1)-1, 4);
    }
  }
}

//Shoot
void mousePressed() {
  if (mouseButton == LEFT && level > 0) {
    if(shoot != null)shoot.play();
    bulletList.add(new Bullet(posX+0.3, posY+0.4, 0.1, atan2(mouseY-height/2,mouseX-width/2), true));
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
      tilePosX = i*tileSize-posX*tileSize+width/2;
      tilePosY = j*tileSize-posY*tileSize+height/2;
      iOriginal = i;
      jOriginal = j;
      if (i < 0) i = mapWidth+i;
      else if (i >= mapWidth) i = i-mapWidth;
      if (j < 0) j = mapHeight+j;
      else if (j >= mapHeight) j = j-mapHeight;

      currentTile = getMapPos(i, j);
      if (currentTile==0) {
        image(ground[floor(posSeed(3, i+j))], tilePosX, tilePosY);
      } else if (currentTile==1 && (getMapPos(i+1,j) != 1 || getMapPos(i,j+1) != 1 || getMapPos(i-1,j) != 1 || getMapPos(i,j-1) != 1 || getMapPos(i+1,j+1) != 1 || getMapPos(i-1,j-1) != 1 || getMapPos(i+1,j-1) != 1 || getMapPos(i-1,j+1) != 1)) {
        image(wall[floor(posSeed(3, i+j))], tilePosX, tilePosY);
      } else if (currentTile==2) {
        image(topWall[floor(posSeed(2, i+j))], tilePosX, tilePosY);
      } else if (currentTile==3) {
        image(stalagmite, tilePosX, tilePosY);
      } else if (currentTile==4) {
        image(topWallSide[floor(posSeed(2, i+j))], tilePosX, tilePosY);
      } else if (currentTile==5 && getMapPos(i, j+2) == 5 && getMapPos(i+2, j) == 5) {
        image(ceilHole, tilePosX, tilePosY, tileSize*3, tileSize*3);
      } else if (currentTile==8) {
        if (inventory[0] == 0) {
          image(doorOpen, tilePosX, tilePosY, tileSize, tileSize);
        } else {
          image(door, tilePosX, tilePosY, tileSize, tileSize);
        }
      } else if (currentTile == 1 && (contains(textureTiles, i*j) || contains(textureTiles, int(i*j/2)))) {
        image(bg[floor(posSeed(2, i*j))], tilePosX, tilePosY);
      } else if (currentTile == 9) {
        tilePosX = (i-5)*tileSize-posX*tileSize+width/2;
        tilePosY = (j-8)*tileSize-posY*tileSize+height/2;
        image(ship, tilePosX, tilePosY, tileSize*6, tileSize*9);
      }
      
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
  rect(width/20, height/25, map(health,0,100,0,4*tileSize), 1.5*tileSize);
  image(UI[1], width/20, height/25, 4*tileSize, 1.5*tileSize);
  fill(255);
  stroke(0);

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

  //Tutorial
  if (level == 1 && !countDownActive) {
    drawKey("W", "UP", width/2-tileSize/2, height/2-tileSize*2, false);
    drawKey("A", "LEFT", width/2-tileSize*2, height/2-tileSize/2, false);
    drawKey("S", "DOWN", width/2-tileSize/2, height/2+tileSize, false);
    drawKey("D", "RIGHT", width/2+tileSize, height/2-tileSize/2, false);
    drawKey("Right Mouse", "DIG", width/2+tileSize*2, height/2-3*tileSize, true);
    drawKey("Left Mouse", "SHOOT", width/2-tileSize*4, height/2-3*tileSize, true);
    banner("Save the Earth. Avoid the alien Tenshi.");
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
  if (level > 0) maps.set(level, activeMap);
  transitioningTo = 0;
  switch (num) {
    case -3:
      delayInt = millis();
      level = -3;
      counter++;
    break;
    case 1:
      level = -1;
      inventory = new int[]{1,2,-1};
      health = 100;
      mapWidth = 65;
      mapHeight = 50;
      posX = int(random(4,mapWidth-5))-0.5;
      posY = int(random(5,mapHeight-6))-0.5;
      maps.set(1, mapGenerator.mapGenerate(7, mapWidth, mapHeight, ceil(posX)-4, ceil(posY)-5, 0));
      for (int i = 0; i < textureTiles.length; i++) {
        textureTiles[i] = int(random(0, mapWidth*mapHeight));
      }
      npcList = mapGenerator.getNPCs();
      level = 1;
      counter = -1;
    break;
    case 2:
      level = 2;
      mapWidth = ceil(mapWidth/4*3);
      mapHeight = ceil(mapHeight/4*3);
      maps.set(2, mapGenerator.mapGenerate(2, mapWidth, mapHeight, ceil(posX)-4, ceil(posY)-5, 0));
      for (int i = 0; i < textureTiles.length; i++) {
        textureTiles[i] = int(random(0, mapWidth*mapHeight));
      }
      npcList = mapGenerator.getNPCs();
    break;
    case 4:
      posX = 15;
      posY = 10;
      maps.set(4, mapGenerator.mapGenerate(0, mapWidth, mapHeight, ceil(posX)-2, ceil(posY)+2, 1));
      countDownActive = false;
      delayInt = millis();
      level = 4;
    break;	
  }
  if (num > 0) activeMap = maps.get(num);
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

PImage loadImagePngCpyPx(Image image, String inFile) {
  int [] data= new int [1];
  PImage retval = createImage(1,1,ARGB);
  try {
    PixelGrabber grabber = new PixelGrabber(image, 0, 0, -1, -1, true);

    if (grabber.grabPixels()) {
      int w = grabber.getWidth();
      int h = grabber.getHeight();
      retval = createImage(w,h,ARGB);

      data = (int[]) grabber.getPixels();
      arrayCopy(data,retval.pixels);
    }
  }
  catch (InterruptedException e1) {
    println("Problem loading loadImagePng, defaulting to loadImage().  Error: " + e1);
    return loadImage(inFile);
  }
  return retval;
}
PImage loadImagePng(String inFile, int w, int h) { return loadImagePngCpyPx(Toolkit.getDefaultToolkit().getImage(dataPath(inFile)).getScaledInstance(w, h, Image.SCALE_DEFAULT), inFile); }
PImage loadImagePng(String inFile, int size) { return loadImagePngCpyPx(Toolkit.getDefaultToolkit().getImage(dataPath(inFile)).getScaledInstance(size, size, Image.SCALE_DEFAULT), inFile); }
PImage loadImagePng(String inFile) { return loadImagePngCpyPx(Toolkit.getDefaultToolkit().getImage(dataPath(inFile)), inFile); }
