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
    ArrayList<Enemy> flaggedEnemies = new ArrayList<Enemy>();
    for (Enemy e : enemies) {
      e.update(); 
      e.display();
      if (e.isFlagged())
        flaggedEnemies.add(e);
    }
    enemies.removeAll(flaggedEnemies);
  }
}
