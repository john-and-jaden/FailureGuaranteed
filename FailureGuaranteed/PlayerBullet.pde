public class PlayerBullet extends Bullet {
  public PlayerBullet(float x, float y, PVector direction, float spawnDistance) {
    super(x, y, direction, spawnDistance);
    // You can modify this
    radius = 5;
    speed = 5;
    damage = 1;
  }

  public void update() {
    if (isFlagged())
      return;
    
    super.update();
    
    for (Enemy e : enemyController.enemies) {
      if (dist(x, y, e.x, e.y) < radius + e.radius) {
        e.takeDamage(damage);
        flag();
      }
    }

    display();
  }

  protected void display() {
    fill(0, 0, 255);
    ellipse(x, y, radius * 2, radius * 2);
  }
}
