public class EnemyBullet extends Bullet {
  public EnemyBullet(float x, float y, PVector direction, float spawnDistance, float speed, int damage) {
    super(x, y, direction, spawnDistance, speed, damage);
    // You can modify this
    radius = 3;
  }

  public void update() {
    super.update();

    if (dist(x, y, player.x, player.y) < radius + player.radius) {
      player.takeDamage(damage);
      flag();
    }

    display();
  }

  protected void display() {
    fill(255, 0, 0);
    ellipse(x, y, radius * 2, radius * 2);
  }
}
