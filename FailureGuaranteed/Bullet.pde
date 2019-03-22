public abstract class Bullet extends DestroyableObject {
  protected float x, y;
  protected float radius;
  protected float speed;
  protected int damage;
  protected PVector direction;
  
  public Bullet(float x, float y, PVector direction, float speed, int damage) {
    this.x = x;
    this.y = y;
    this.direction = direction;
    this.speed = speed;
    this.damage = damage;
  }

  public Bullet(float x, float y, PVector direction) {
    this.x = x;
    this.y = y;
    this.direction = direction;
    display();
  }

  protected void update() {
    if (isFlagged())
      return;
    
    x += direction.x * speed;
    y += direction.y * speed;

    if (isOffScreen()) {
      flag();
    }
  }
  
  protected abstract void display();
  
  private boolean isOffScreen() {
    return x < radius || x > width - radius || y < radius || y > height - radius;
  }
}
