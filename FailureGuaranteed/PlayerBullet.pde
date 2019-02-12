public class PlayerBullet {
  private float x, y;
  private float radius;
  private float speed;
  private int damage;
  private PVector direction;
  
  public PlayerBullet(float x, float y, PVector direction, float spawnDistance) {
    this.x = x + (direction.x * (radius + spawnDistance));
    this.y = y + (direction.y * (radius + spawnDistance));
    this.direction = direction;
    
    speed = 5;
    damage = 1;
  }
  
  public void update() {
    x += direction.x * speed;
    y += direction.y * speed;
    
    if (isOffScreen()) {
      //destroy self 
    }
    
    for (Enemy e : ec.enemies) {
      if (dist(x, y, e.x, e.y) < radius + e.radius) {
        //damage enemy
      }
    }
  }
  
  private boolean isOffScreen() {
    return x < radius || x > width - radius || y < radius || y > height - radius;
  }
}
