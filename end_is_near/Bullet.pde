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

    image(shot, x*tileSize-posX*tileSize+width/2-tileSize/2, y*tileSize-posY*tileSize+height/2-tileSize/2, tileSize/2, tileSize/2);
  }

  private void checkCollision() {
    if (getMapPos(floor(x),floor(y)) == 1 || getMapPos(floor(x),floor(y)) == 2) {
      bulletList.remove(this);
    }
    for (int i = 0; i < npcList.size(); i++) {
      if (friendly && dist(x, y, npcList.get(i).xPos, npcList.get(i).yPos) < 0.6 && npcList.get(i).death == 0) {
        npcList.get(i).death = millis();
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
