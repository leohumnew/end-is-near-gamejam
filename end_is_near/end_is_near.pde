import java.util.Arrays;

//Save variables
final String fileName = "saveInfo.txt";
String[] saveData = new String [1];

//Map
int mapWidth = 60, mapHeight = 40;
int map[][] = new int[mapWidth][mapHeight];
MapGenerator mapGenerator = new MapGenerator();
int[] textureTiles = new int[mapWidth];
int tileSize = 64;
int visTilesX, visTilesY;

//Images
PImage stalagmite, ceilHole, floorHole, floorDiggable, shot;
PImage[] player = new PImage[3];
PImage[] topWall = new PImage[2];
PImage[] ground = new PImage[3];
PImage[] wall = new PImage[3];
PImage[] topWallSide = new PImage[2];
PImage[] npcMeelee = new PImage[2];
PImage[] bg = new PImage[2];
PImage[] endScreens = new PImage[2];
PImage[] items = new PImage[1];

PFont pixelatedFont;

//Player variables
float posX = int(random(4,mapWidth-5))-0.5, posY = int(random(5,mapHeight-6))-0.5, speedX = 0, speedY = 0;
int time, timeLimit = 60000, health = 100, delayInt;
boolean countDownActive = false;
int ending = -1;
int[] inventory = {-1};

//Objects
ArrayList<NPC> npcList;
ArrayList<Bullet> bulletList = new ArrayList<Bullet>();
ArrayList<Pickup> itemList = new ArrayList<Pickup>();

//SETTINGS FUNCTION -----------------
void settings() {
  loadSave();
  if (int(saveData[0])==1)fullScreen(P2D);
  else size(1280, 720, P2D);
}

void setup() {
  frameRate(60);
  ((PGraphicsOpenGL)g).textureSampling(2);
  visTilesX = ceil(width/tileSize);
  visTilesY = ceil(height/tileSize);
  map = mapGenerator.mapGenerate(5, mapWidth, mapHeight, ceil(posX)-4, ceil(posY)-5);
  for (int i = 0; i < textureTiles.length; i++) {
    textureTiles[i] = int(random(0, mapWidth*mapHeight));
  }
  npcList = mapGenerator.getNPCs();
  
  pixelatedFont = createFont("MotorolaScreentype.ttf", 50);
  textFont(pixelatedFont);
  //load images
  ground[0] = loadImage("Suelo0_0.png");
  ground[1] = loadImage("Suelo0_1.png");
  ground[2] = loadImage("Suelo0_2.png");
  wall[0] = loadImage("Pared0_0.png");
  wall[1] = loadImage("Pared0_1.png");
  wall[2] = loadImage("Pared0_2.png");
  topWall[0] = loadImage("Pared0_4.png");
  topWall[1] = loadImage("Pared0_5.png");
  topWallSide[0] = loadImage("Pared0_6.png");
  topWallSide[1] = loadImage("Pared0_7.png");
  stalagmite = loadImage("Estalagmita0.png");
  player[0] = loadImage("Char1.png");
  player[1] = loadImage("Char2.png");
  player[2] = loadImage("Char3.png");
  ceilHole = loadImage("Entr.png");
  npcMeelee[0] = loadImage("Char7.png");
  npcMeelee[1] = loadImage("Char8.png");
  bg[0] = loadImage("BG0.png");
  bg[1] = loadImage("BG1.png");
  endScreens[0] = loadImage("D0.png");
  endScreens[1] = loadImage("D1.png");
  shot = loadImage("Shot.png");
  items[0] = loadImage("Key.png");
}

void draw() {
  if (ending == -1) {
    background(0);
    if (mousePressed && mouseButton == RIGHT && millis()-delayInt > 80) {
      dig();
      delayInt = millis();
    }
    drawMap();
    move();
    for (int i = 0; i < itemList.size(); i++) {
      itemList.get(i).update();
    }
    for (int i = 0; i < bulletList.size(); i++) {
      bulletList.get(i).update();
    }
    for (int i = 0; i < npcList.size(); i++) {
      npcList.get(i).drawNPC();
    }
    drawPlayer();
    drawUI();
  } else {
    image(endScreens[ending], 0, 0, width, height);
    textSize(50);
    textAlign(CENTER);
    switch (ending) {
      case 0:
        text("\"And thus was Earth's only chance lost, but no one cared anymore;\ntruth was, Earth's last hope was long gone.\"", width/10, height-20, width/10*8, -height/5);
      break;
      case 1:
        text("\"Though he didn't suffocate, he proved himself useless, once more;\nI should have definitely gone with the Space dog.\"", width/10, height-20, width/10*8, -height/5);
      break;
    }
  }
}

//MAP FUNCTIONS ------------------
int getMapPos(int x, int y) {
  if (x < 0) x = mapWidth+x;
  else if (x >= mapWidth) x = x-mapWidth;
  if (y < 0) y = mapHeight+y;
  else if (y >= mapHeight) y = y-mapHeight;
  return map[x][y];
}
void setMapPos(int x, int y, int value) {
  if (x < 0) x = mapWidth+x;
  else if (x >= mapWidth) x = x-mapWidth;
  if (y < 0) y = mapHeight+y;
  else if (y >= mapHeight) y = y-mapHeight;
  if(map[x][y] != 5)map[x][y] = value;
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
  if (countDownActive == false) {
    countDownActive = true;
    time = millis();
  }
  if (key == 'w' || key == 'W' || keyCode == UP) {
    speedY = -0.1;
  } else if (key == 's' || key == 'S' || keyCode == DOWN) {
    speedY = 0.1;
  } else if (key == 'a' || key == 'A' || keyCode == LEFT) {
    speedX = -0.1;
  } else if (key == 'd' || key == 'D' || keyCode == RIGHT) {
    speedX = 0.1;
  // dig
  } else if (key == 'e') {
    dig();
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
  if (speedX > 0) {
    setMapPos(floor(posX+1), floor(posY+0.4), 0);
    setMapPos(floor(posX+1), floor(posY-0.4), 0);
    if (getMapPos(floor(posX+1), floor(posY-0.4)-1) == 1) {
      if (getMapPos(floor(posX+1), floor(posY-0.4)-2) == 1) setMapPos(floor(posX+1), floor(posY-0.4)-1, 2);
      else setMapPos(floor(posX+1), floor(posY-0.4)-1, 4);
    }
    if (getMapPos(floor(posX+1), floor(posY+0.4)+1) == 2) setMapPos(floor(posX+1), floor(posY+0.4)+1, 4);
  } else if (speedX < 0) {
    setMapPos(floor(posX-1), floor(posY+0.4), 0);
    setMapPos(floor(posX-1), floor(posY-0.4), 0);
    if (getMapPos(floor(posX-1), floor(posY-0.4)-1) == 1) {
      if (getMapPos(floor(posX-1), floor(posY-0.4)-2) == 1) setMapPos(floor(posX-1), floor(posY-0.4)-1, 2);
      else setMapPos(floor(posX-1), floor(posY-0.4)-1, 4);
    }
    if (getMapPos(floor(posX-1), floor(posY+0.4)+1) == 2) setMapPos(floor(posX-1), floor(posY+0.4)+1, 4);
  } else if (speedY > 0) {
    setMapPos(floor(posX+0.4), floor(posY+1), 0);
    if (getMapPos(floor(posX+0.4), floor(posY+1)+1) == 1 && (getMapPos(floor(posX+0.4), floor(posY+1)+2) != 1 && getMapPos(floor(posX+0.4), floor(posY+1)+2) != 2)) setMapPos(floor(posX+0.4), floor(posY+1)+1, 4);
    else if (getMapPos(floor(posX+0.4), floor(posY+1)+1) == 2) setMapPos(floor(posX+0.4), floor(posY+1)+1, 4);
    setMapPos(floor(posX-0.4), floor(posY+1), 0);
    if (getMapPos(floor(posX-0.4), floor(posY+1)+1) == 1 && (getMapPos(floor(posX-0.4), floor(posY+1)+2) != 1 && getMapPos(floor(posX-0.4), floor(posY+1)+2) != 2)) setMapPos(floor(posX-0.4), floor(posY+1)+1, 4);
    else if (getMapPos(floor(posX-0.4), floor(posY+1)+1) == 2) setMapPos(floor(posX-0.4), floor(posY+1)+1, 4);
  } else if (speedY < 0) {
    setMapPos(floor(posX+0.4), floor(posY-1), 0);
    setMapPos(floor(posX-0.4), floor(posY-1), 0);
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
  if (mouseButton == LEFT) {
    if(mouseX < width/2){
      if(mouseY < height/2) bulletList.add(new Bullet(posX+0.5, posY+0.5, 0.1, atan((mouseY-height/2)/(mouseX-width/2))-PI, true));
      else bulletList.add(new Bullet(posX+0.5, posY+0.5, 0.1, atan((mouseY-height/2)/(mouseX-width/2))+PI, true));
    }
    else bulletList.add(new Bullet(posX+0.5, posY+0.5, 0.1, atan((mouseY-height/2)/(mouseX-width/2)), true));
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

      if (map[i][j]==0) {
        image(ground[floor(posSeed(3, i+j))], tilePosX, tilePosY, tileSize, tileSize);
      } else if (map[i][j]==1 && (getMapPos(i+1,j) != 1 || getMapPos(i,j+1) != 1 || getMapPos(i-1,j) != 1 || getMapPos(i,j-1) != 1 || getMapPos(i+1,j+1) != 1 || getMapPos(i-1,j-1) != 1 || getMapPos(i+1,j-1) != 1 || getMapPos(i-1,j+1) != 1)) {
        image(wall[floor(posSeed(3, i+j))], tilePosX, tilePosY, tileSize, tileSize);
      } else if (map[i][j]==2) {
        image(topWall[floor(posSeed(2, i+j))], tilePosX, tilePosY, tileSize, tileSize);
      } else if (map[i][j]==3) {
        image(stalagmite, tilePosX, tilePosY, tileSize, tileSize);
      } else if (map[i][j]==4) {
        image(topWallSide[floor(posSeed(2, i+j))], tilePosX, tilePosY, tileSize, tileSize);
      } else if (map[i][j]==5 && getMapPos(i, j+2) == 5 && getMapPos(i+2, j) == 5) {
        image(ceilHole, tilePosX, tilePosY, tileSize*3, tileSize*3);
      } else if (map[i][j] == 1 && (contains(textureTiles, i*j) || contains(textureTiles, int(i*j/2)))) {
        image(bg[floor(posSeed(2, i*j))], tilePosX, tilePosY, tileSize, tileSize);
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
  fill(0);
  stroke(255);
  rect(int(width-width/20), int(height/5), int(width/30), int(height/5*3));
  stroke(0);
  fill(255);
  if (countDownActive && millis() > time+timeLimit) {
    countDownActive = false;
    ending = 1;
  }
  if (countDownActive) rect(int(width-width/20+2), int(height/5*4-2), int(width/30-4), int(0-map(millis(), time+timeLimit, time, 0, height/5*3)+4));
  else rect(int(width-width/20+2), int(height/5*4-2), int(width/30-4), 0-int(height/5*3-4));
  fill(255,0,0);
  rect(width/4, height/20, map(health,0,100,0,width/2), height/30);
  fill(255);

  //Inventory
  for (int i = 0; i < inventory.length; i++) {
    if (inventory[i] != -1) {
      image(items[i], width/20+tileSize*2*i, height-tileSize*2, tileSize*2, tileSize*2);
    }
  }
}

//SAVE INFO -------------------------
void createSave() {
  saveData[0] = "1";
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
    return Arrays.stream(arr).anyMatch(i -> i == key);
}
