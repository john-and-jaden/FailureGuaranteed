public class Enemy {
  private float x, y;
  private float speedX, speedY;
  private float radius;
  
  public void init() {
    x = width;
    y = height / 2;
  }
  
  public void update() {
    x += speedX;
    y += speedY;
  }
  
  public void display() {
    ellipse(x, y, radius, radius);
  }
}
