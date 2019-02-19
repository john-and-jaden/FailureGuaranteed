public class Enemy extends DestroyableObject {
  private float x, y;
  private PVector direction;
  private float radius;
  private int health;
  Routine[] routines;
  int currentRoutine;
  float routineTimer;
  private float shootCooldown;
  private float shootTimer;
  private int currentHealth;
  
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
      routines[i] = new Routine();
      routines[i].forwardSpeed = random(0, 5);
      routines[i].rotationSpeed = random(0, 0.1);
      routines[i].duration = (int)random(1, 4);
      routines[i].shootCooldown = random(0.01, 0.7);
    }
  }

  public void shoot() {
    if (shootTimer > shootCooldown) {
      enemyBullets.add(new EnemyBullet(x, y, direction.copy(), radius));
      shootTimer = 0;
    }
  }

  private class Routine {
    // routine specific
    int duration;
    
    // movement specific
    float forwardSpeed;
    float rotationSpeed;
    
    // bullet specific
    float shootCooldown;
  }
}
