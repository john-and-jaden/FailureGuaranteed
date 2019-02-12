public class EnemyController {
  ArrayList<Enemy> enemies;
  int numberEnemies = 1;

  EnemyController() {
    enemies = new ArrayList<Enemy>(numberEnemies);
    for (int i = 0; i < numberEnemies; i++) {
      enemies.add(new Enemy());
    }
  }

  void update() {
    for (Enemy e : enemies) {
      e.update(); 
      e.display();
    }
  }
}
