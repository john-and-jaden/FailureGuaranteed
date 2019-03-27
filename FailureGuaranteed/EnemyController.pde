public class EnemyController {
  public ArrayList<Enemy> enemies;
  private int numberEnemies;

  float attackTimerWeight;
  float trackTimerWeight;
  float lifetimeWeight;
  float damageDealtWeight;

  EnemyController() {
    // You can modify this
    numberEnemies = 4;
    attackTimerWeight = 0.8;
    trackTimerWeight = 0.6;
    lifetimeWeight = 0.3;
    damageDealtWeight = 1;

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
      // normalize attributes
      // get highest of each

      // an alternate way to do this would be to use the totals, which would create a smaller difference between fitnesses
      float maxAttackTimer = -1;
      float maxTrackTimer = -1;
      float maxLifetime = -1;
      int maxDamageDealt = -1;
      
      for (Enemy e : enemies) {
        if (e.attackTimer > maxAttackTimer)
          maxAttackTimer = e.attackTimer;
        if (e.trackTimer > maxTrackTimer)
          maxTrackTimer = e.trackTimer;
        if (e.lifetime > maxLifetime)
          maxLifetime = e.lifetime;
        if (e.damageDealt > maxDamageDealt)
          maxDamageDealt = e.damageDealt;
      }
      
      println("Max Attack Timer:" + maxAttackTimer);
      println("Max Track Timer:" + maxTrackTimer);
      println("Max Lifetime:" + maxLifetime);
      println("Max Damage Dealt:" + maxDamageDealt);
      
      float totalFitness = 0;
      for (Enemy e : enemies) {
        e.fitness = 0;
        if (maxAttackTimer != 0)
          e.fitness += (e.attackTimer / maxAttackTimer) * attackTimerWeight;
        if (maxTrackTimer != 0)
          e.fitness += (e.trackTimer / maxTrackTimer) * trackTimerWeight;
        if (maxLifetime != 0)
          e.fitness += (e.lifetime / maxLifetime) * lifetimeWeight;
        if (maxDamageDealt != 0)
          e.fitness += (e.damageDealt / maxDamageDealt) * damageDealtWeight;
        totalFitness += e.fitness;
      }
      
      for (Enemy e : enemies) {
        e.relativeFitness = e.fitness / totalFitness; 
      }
      
      Enemy child = getFittestEnemy();
      
      for (Enemy e : enemies) {
        println(e.fitness);
        e.respawn();
      }
    }
  }
  
  private Enemy getFittestEnemy() {
    float max = 0;
    Enemy fittest = enemies.get(0);
    
    for (Enemy e : enemies) {
      if (e.relativeFitness > max) {
        max = e.relativeFitness;
        fittest = e;
      }
    }
    
    return fittest;
  }
}
