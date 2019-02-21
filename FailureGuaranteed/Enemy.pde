public class Enemy extends DestroyableObject {
  public final int PATROL = 0, TRACK = 1, ATTACK = 2;
  
  private float x, y;
  private PVector direction;
  private float radius;
  private int health;
  private float shootCooldown;
  private float disengageDelay;
  private float forwardVisionLength;
  private float proximityDetectionRadius;
  private float heatSenseThreshold;
  
  Routine[] routines;
  private int currentRoutine;
  private float routineTimer;
  private int state;
  private float disengageTimer;
  private HeatTrailParticle targetParticle;
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
      routines[i].duration = (int) random(1, 4);
      
      // movement specific
      routines[i].forwardSpeed = random(0, 5);
      routines[i].rotationSpeed = random(0, 0.1);
      
      // detection & vision specific
      
      
      
      routines[i].shootCooldown = random(0.01, 0.7);
    }
  }
  
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
  
  private float modAngle(float a) {
    if (a < 0)
      return a + TWO_PI;
    return a;
  }
}
