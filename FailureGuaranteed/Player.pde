public class Player {
  private float x, y;
  private float r;
  private float speed;
  private float right, left, up, down;

  public Player() {
    x = width/2;
    y = height/2;
    r = 30;
    speed = 5;
  }

  public void update() {
    x = constrain(x + (right - left), r, width-r);
    y = constrain(y + (down - up), r, height-r);
    display();
  }

  public void moveDirection(float x, float y) {
    if (x == 1)
      right = speed;
    else if (x == -1)
      left = speed;
    else if (y == 1)
      up = speed;
    else if (y == -1)
      down = speed;
  }

  public void stopDirection(float x, float y) {
    if (x == 1)
      right = 0;
    else if (x == -1)
      left = 0;
    else if (y == 1)
      up = 0;
    else if (y == -1)
      down = 0;
  }

  public void display() {
    fill(255, 0, 0);
    ellipse(x, y, r*2, r*2);
  }
}
