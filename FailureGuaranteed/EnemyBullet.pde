public class EnemyBullet extends Bullet {
  Enemy parent;
  
  public EnemyBullet(float x, float y, PVector direction, float spawnDistance, float speed, int damage, Enemy parent) {
    super(x, y, direction, speed, damage);
    // You can modify this
    radius = 3;
    this.x += (direction.x * (radius + spawnDistance));
    this.y += (direction.y * (radius + spawnDistance));
    this.parent = parent;
    display();
  }

  public void update() {
    super.update();

    if (dist(x, y, player.x, player.y) < radius + player.radius) {
      player.takeDamage(damage);
      parent.damageDealt += damage;
      flag();
    }

    display();
  }

  protected void display() {
    fill(255, 0, 0);
    ellipse(x, y, radius * 2, radius * 2);
  }
}
