public class EnemyController {
  public ArrayList<Enemy> enemies;
  private int numberEnemies;

  EnemyController() {
    // You can modify this
    numberEnemies = 1;
    
    // Don't modify this
    enemies = new ArrayList<Enemy>(numberEnemies);
    for (int i = 0; i < numberEnemies; i++) {
      enemies.add(new Enemy());
    }
  }
  
  void update() {
    boolean allDisabled = true;
    
    for (Enemy e : enemies) {
      e.update();
      if (!allDisabled) {
        continue;
      }
      if (!e.disabled) {
        allDisabled = false;
      }
    }
    
    if (allDisabled) {
      for (Enemy e : enemies) {
        e.respawn();
      }
    }
  }
}
