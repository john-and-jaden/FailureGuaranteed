public class Enemy extends DestroyableObject {
  private float x, y;
  private PVector direction;
  private float radius;
  private int health;
  private float shootCooldown;
  private float disengageDelay;
  private float forwardVisionLength;
  private float proximityDetectionRadius;
  private float heatSenseThreshold;
  private int currentRoutine;
  private float routineTimer;
  private int state;
  private float disengageTimer;
  private HeatTrailParticle targetParticle;
  private float shootTimer;
  private int currentHealth;
  
  int totalNumAttributes;
  
  EnemyState patrolState;
  EnemyState trackingState;
  EnemyState attackingState;
  
  public Enemy() {
    // You can change this
    x = width - random(0, 50);
    y = height / 2 + random(-50, 50); 
    direction = new PVector(-1, 0);
    radius = 5;
    health = 5;
    shootCooldown = 0.1;
    disengageDelay = 3;
    forwardVisionLength = 30;
    proximityDetectionRadius = 20;
    heatSenseThreshold = 10;
    // Don't change this
    state = PATROL;
    currentRoutine = 0;
    disengageTimer = 0;
    state = 0;
    initRoutines();
    currentHealth = health;
  }

  public void update() {
    updateCurrentRoutineAndTimer();
    disengage();
    search();
    shoot();
    
    switch (state) {
      case PATROL: movePatrol();
        println("State: PATROL");
        break;
      case TRACK: trackHeat();
        println("State: TRACK");
        break;
      case ATTACK: followPlayer();
        println("State: ATTACK");
        break;
    }
    display();
  }
  
  public void updateCurrentRoutineAndTimer() {
    routineTimer += timer.deltaTime;
    if (routineTimer > routines[currentRoutine].duration) {
      routineTimer = 0;
      if (currentRoutine == routines.length - 1) {
        currentRoutine = 0;
      } else {
        currentRoutine++;
        shootCooldown = routines[currentRoutine].shootCooldown;
      }
    }
  }
  
  private void initStates() {
    patrolState = new EnemyState(PATROL);
    trackingState = new EnemyState(TRACK);
    attackingState = new EnemyState(ATTACK);
    // you can tweak those parameters
    int quota = 1000;
    int maxValue = 50;
    int remainder = quota;
    int unassigned = totalNumAttributes;
    
    // generate array of numbers
    int[] array = new int[totalNumAttributes];
    int currentIndex = 0;
    while (remainder > 0) {
      float assigningValue = (int) random(1, constrain(remainder - unassigned, 1, maxValue - array[currentIndex]) + 1);
      array[currentIndex] += assigningValue;
      unassigned--;
      remainder -= assigningValue;
      currentIndex++;
      if (currentIndex > array.length - 1) {
        currentIndex = 0;
      }
    }

    // randomize array order
    for (int i = 0; i < array.length; i++) {
      int newIndex = (int)random(0, array.length);
      int temp = array[i];
      array[i] = array[newIndex];
      array[newIndex] = temp;
    }
    
    // attributes common to all routines of patrol state
    for(int i = 0; i < 3; i++) {
     patrolState.routines[i].forwardVisionLength = array[0];
     patrolState.routines[i].proximityDetectionRadius = array[1];
     patrolState.routines[i].heatSenseThreshold = array[2];
     patrolState.routines[i].health = array[3];
    }
    
    // health is an attribute common to all states
    trackingState.routines[0].health = array[3];
    attackingState.routines[0].health = array[3];
    
    // assign each value from the array to one of the quota values in the routine
    for(int i = 0; i < 3; i++) {
      patrolState.routines[i].shootCooldown = array[4 + i];  
    }
    
    trackingState.rotationSpeed = array[7];
    trackingState.forwardVisionLength = array[8];
    trackingState.proximityDetectionRadius = array[9];
    trackingState.heatSenseThreshold = array[10];
    trackingState.shootCooldown = array[11];
    
    attackingState.rotationSpeed = array[12];
    attackingState.forwardVisionLength = array[13];
    attackingState.proximityDetectionRadius = array[14];
    attackingState.heatSenseThreshold = array[15];
    attackingState.shootCooldown = array[16];    
    
    // assign non quota values
    trackingState.routines[0].forwardSpeed = random();
  }
  
  private void movePatrol() {
    direction.rotate(routines[currentRoutine].rotationSpeed);
    x = constrain(x + direction.x * routines[currentRoutine].forwardSpeed, radius, width - radius);
    y = constrain(y + direction.y * routines[currentRoutine].forwardSpeed, radius, height - radius);
    bounceOffWalls();
  }
  
  private void trackHeat() {
    if (targetParticle == null)
      return;
    
    PVector targetDirection = new PVector(targetParticle.x - x, targetParticle.y - y);
    float heading = modAngle(targetDirection.heading() - direction.heading());
    heading = -Math.signum(heading - PI);
    
    direction.rotate(0.12 * heading);
    x = constrain(x + direction.x * 2, radius, width - radius);
    y = constrain(y + direction.y * 2, radius, height - radius);
    bounceOffWalls();
  }
  
  private void followPlayer() {
    PVector targetDirection = new PVector(player.x - x, player.y - y);
    float heading = modAngle(targetDirection.heading() - direction.heading());
    heading = -Math.signum(heading - PI);
    
    direction.rotate(0.04 * heading);
    x = constrain(x + direction.x * 5, radius, width - radius);
    y = constrain(y + direction.y * 5, radius, height - radius);
    bounceOffWalls();
  }
  
  private void bounceOffWalls() {
    if (x <= radius || x >= width - radius) {
      direction.x = -direction.x;
    }
    
    if (y <= radius || y >= height - radius) {
      direction.y = -direction.y;
    }
  }
  
  private void search() {
    // Forward Vision
    for (int i = 0; i < forwardVisionLength; i++) {
      float detectX = direction.x * i;
      float detectY = direction.y * i;
      if (dist(player.x, player.y, detectX, detectY) < player.radius) {
        setState(ATTACK);
      }
    }
    
    // Proximity Vision
    if (dist(player.x, player.y, x, y) < proximityDetectionRadius + player.radius) {
      setState(ATTACK);
    }
  
    // Heat Vision
    if (targetParticle == null && state == PATROL) {
      for (HeatTrailParticle p : heatTrail.particles) {
        if (targetParticle != null) {
          continue;
        }
        if (dist(p.x, p.y, x, y) < radius && p.heatLevel > heatSenseThreshold) {
          setState(TRACK);
          targetParticle = p.next;
        }
      }
    } else if (targetParticle != null) {
      if (targetParticle.heatLevel <= 0) {
        targetParticle = null;
        if (state == TRACK) {
          setState(PATROL);
        }
      } else if (dist(targetParticle.x, targetParticle.y, x, y) < radius && targetParticle.heatLevel > heatSenseThreshold && state == TRACK) {
        setState(TRACK);
        targetParticle = targetParticle.next;
      }
    }
  }
  
  private void setState(int state) {
    this.state = state;
    disengageTimer = 0;
  }
  
  private void disengage() {
    if (state != PATROL) {
      disengageTimer += timer.deltaTime;
      if (disengageTimer > disengageDelay) {
        state = PATROL;
        disengageTimer = 0;
      }
    }
  }
  
  private void shoot() {
    shootTimer += timer.deltaTime;
    
    if (shootTimer > shootCooldown) {
      enemyBullets.add(new EnemyBullet(x, y, direction.copy(), radius));
      shootTimer = 0;
    }
  }

  public void takeDamage(int damage) {
    currentHealth -= damage;
    if (currentHealth <= 0 && !isFlagged()) {
      flag();
    }
  }
  
  private void display() {
    fill(0, 100, 255, 100);
    stroke(0, 255, 0);
    strokeWeight(1);
    ellipse(x, y, proximityDetectionRadius * 2, proximityDetectionRadius * 2);
    stroke(200, 0, 255, 200);
    strokeWeight(2);
    line(x, y, x + direction.x * forwardVisionLength, y + direction.y * forwardVisionLength);
    fill(255, 0, 0);
    ellipse(x, y, radius * 2, radius * 2);
  }
  
  private void initRoutines() {
    routines = new Routine[3];
    for (int i = 0; i < routines.length; i++) {
      // routine specific
      routines[i] = new Routine();
      initRoutine(routines[i]);
    }
  }

  

  // moved the Routine class  
  /*
  private class Routine {
    // routine specific
    int duration;
    
    // movement specific
    float forwardSpeed;
    float rotationSpeed;
    
    // detection & vision specific
    float forwardVisionLength;
    float proximityDetectionRadius;
    float heatSenseThreshold;
    
    // attack specific
    float shootCooldown;
    
    // health
    int health;
  }
  */
  
  private float modAngle(float a) {
    if (a < 0)
      return a + TWO_PI;
    return a;
  }
}
