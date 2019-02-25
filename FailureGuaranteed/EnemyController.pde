public class EnemyController {
  public ArrayList<Enemy> enemies;
  private int numberEnemies;

  EnemyController() {
    // You can modify this
    numberEnemies = 3;
    
    // Don't modify this
    enemies = new ArrayList<Enemy>(numberEnemies);
    for (int i = 0; i < numberEnemies; i++) {
      enemies.add(new Enemy());
    }
  }
  
  void update() {
    ArrayList<Enemy> flaggedEnemies = new ArrayList<Enemy>();  
    for (Enemy e : enemies) {
      e.update(); 
      if (e.isFlagged())
        flaggedEnemies.add(e);
    }
    enemies.removeAll(flaggedEnemies);
  }
}
