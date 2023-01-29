public class Bullet {
  float x, y, speed, direction;
  boolean friendly;

  public Bullet (float x, float y, float speed, float direction, boolean friendly) {
    this.x = x;
    this.y = y;
    this.speed = speed;
    this.direction = direction;
    this.friendly = friendly;
  }

  public void update() {
    x += speed * cos(direction);
    y += speed * sin(direction);
    
    checkCollision();

    image(shot, x*tileSize-posX*tileSize+width/2-tileSize/4, y*tileSize-posY*tileSize+height/2-tileSize/4);
  }

  private void checkCollision() {
    if (getMapPos(x, y) == 1 || getMapPos(x, y) == 2) {
      bulletList.remove(this);
    }
    for (int i = 0; i < maps[level].npcList.size(); i++) {
      if (friendly && dist(x, y, maps[level].npcList.get(i).xPos, maps[level].npcList.get(i).yPos) < 0.6 && maps[level].npcList.get(i).death == 0) {
        maps[level].npcList.get(i).death = millis();
        bulletList.remove(this);
        break;
      }
    }
    if (!friendly && dist(x, y, posX, posY) < 0.6) {
      bulletList.remove(this);
      health -= 30;
    }
  }
}
