public class Enemy extends DestroyableObject {
  private float x, y;
  private PVector direction;
  private float radius;
  private int health;
  int currentRoutine;
  float routineTimer;
  private float shootCooldown;
  private float shootTimer;
  private int currentHealth;
  
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
    
    // Don't change this
    currentRoutine = 0;
    initRoutines();
    currentHealth = health;
  }

  public void update() {
    shootTimer += timer.deltaTime;
    updateCurrentRoutineAndTimer();
    if (x <= radius || x >= width - radius) {
      direction.x = - direction.x;
    }
    if (y <= radius || y >= height - radius) {
      direction.y = - direction.y;
    }
    direction.rotate(0.1 * routines[currentRoutine].rotationSpeed);
    x = constrain(x + direction.x * routines[currentRoutine].forwardSpeed, radius, width - radius);
    y = constrain(y + direction.y * routines[currentRoutine].forwardSpeed, radius, height - radius);
    shootCooldown = routines[currentRoutine].shootCooldown;
    shoot();
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
      }
    }
  }

  public void takeDamage(int damage) {
    currentHealth -= damage;
    if (currentHealth <= 0 && !isFlagged()) {
      flag();
    }
  }
  
  private void display() {
    fill(255, 0, 0);
    line(x, y, x + direction.x * 50, y + direction.y * 50);
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

  private void initRoutine(Routine routine) {
    // you can change tweak those parameters
    int quota = 100;
    int maxValue = 50;
    int remainder = quota;
    int unassigned = 3;

    // generate array of numbers
    int[] array = new int[5];
    int currentIndex = 0;
    while (remainder > 0) {
      float assigningValue = (int) random(1, constrain(remainder - unassigned, 1, maxValue - array[currentIndex]) + 1);
      array[currentIndex] += assigningValue;
      unassigned--;
      remainder -= assigningValue;
      currentIndex++;
      if (currentIndex > 4) {
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

    // assign each value from the array to one of the quota values in the routine
    routine.forwardVisionLength = array[0];
    routine.proximityDetectionRadius = array[1];
    routine.heatSenseThreshold = array[2];
    routine.shootCooldown = 25 / array[3];
    routine.health = array[4];
    
    // assign the non-quota values
    routine.duration = (int)random(1, 5);
    routine.forwardSpeed = random(0, 10);
    routine.rotationSpeed = random(0, 5);
  }


  public void shoot() {
    if (shootTimer > shootCooldown) {
      enemyBullets.add(new EnemyBullet(x, y, direction.copy(), radius));
      shootTimer = 0;
    }
  }

}
