public class Bullet extends DestroyableObject {
  protected float x, y;
  protected float radius;
  protected float speed;
  protected int damage;
  protected PVector direction;
  
   public Bullet(float x, float y, PVector direction, float spawnDistance) {
    radius = 5;
    speed = 5;
    damage = 1;
    
    this.x = x + (direction.x * (radius + spawnDistance));
    this.y = y + (direction.y * (radius + spawnDistance));
    this.direction = direction;
  }
}
