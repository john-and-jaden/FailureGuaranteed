public class EnemyController {
  ArrayList<Enemy> enemies;

  void init() {
    enemies = new ArrayList<Enemy>(15);
    for (int i = 0; i < enemies.size(); i++) {
      enemies.add(new Enemy());
      enemies.get(i).init();
    }
  }
}
