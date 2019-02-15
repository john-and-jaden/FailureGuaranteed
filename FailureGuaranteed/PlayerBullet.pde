public class PlayerBullet extends DestroyableObject {
  private float x, y;
  private float radius;
  private float speed;
  private int damage;
  private PVector direction;
  
  public PlayerBullet(float x, float y, PVector direction, float spawnDistance) {
    // You can modify this
    radius = 5;
    speed = 5;
    damage = 1;
    
    // Don't modify this
    this.x = x + (direction.x * (radius + spawnDistance));
    this.y = y + (direction.y * (radius + spawnDistance));
    this.direction = direction;
  }
  
  public void update() {
    x += direction.x * speed;
    y += direction.y * speed;
    
    if (isOffScreen()) {
      flag();
    }
    
    for (Enemy e : ec.enemies) {
      if (dist(x, y, e.x, e.y) < radius + e.radius) {
        e.takeDamage(damage);
        flag();
      }
    }
    
    display();
  }
  
  private void display() {
    fill(0, 0, 255);
    ellipse(x, y, radius * 2, radius * 2);
  }
  
  private boolean isOffScreen() {
    return x < radius || x > width - radius || y < radius || y > height - radius;
  }
}
