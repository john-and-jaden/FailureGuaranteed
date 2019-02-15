public class PlayerBullet extends Bullet {
  public PlayerBullet(float x, float y, PVector direction, float spawnDistance) {
    super(x, y, direction, spawnDistance);
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
