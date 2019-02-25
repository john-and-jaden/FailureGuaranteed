
public class Enemy {
  public final int PATROL = 0, TRACK = 1, ATTACK = 2;
  private float x, y;
  private PVector direction;
  private float radius;
  private int health;
  private float shootCooldown;
  private float disengageDelay;
  private float attackVisionDistance;
  private float attackVisionAngle;
  private float forwardVisionLength;
  private float proximityDetectionRadius;
  private float heatVisionLength;
  private float heatSenseThreshold;
  private int currentRoutine;
  private float routineTimer;
  private int state;
  private float disengageTimer;
  private HeatTrailParticle targetParticle;
  private float shootTimer;
  private int currentHealth;
  int totalNumQuotaAttributes;
  private boolean disabled;
  EnemyState patrolState;
  EnemyState trackingState;
  EnemyState attackingState;

  public Enemy() {
    // You can change this
    x = width - random(radius, width / 6);
    y = height / 2 + random(-height / 3, height / 3); 
    direction = new PVector(-1, 0);
    radius = random(8, 16);
    health = (int) random(3, 6);
    disengageDelay = 1;
    attackVisionDistance = random(200, 600);
    attackVisionAngle = random(PI/24, PI/4);
    forwardVisionLength = random(50, 150);
    proximityDetectionRadius = random(20, 80);
    heatVisionLength = random(20, 80);
    heatSenseThreshold = random(0, 190);
    shootCooldown = 5;
    totalNumQuotaAttributes = 17;

    // Don't change this
    state = PATROL;
    currentRoutine = 0;
    disengageTimer = 0;
    state = 0;
    initStates();
    currentHealth = health;
    disabled = false;
  }

  public void update() {
    if (disabled)
      return;
    updateCurrentRoutineAndTimer();
    disengage();
    search();
    shoot();

    switch (state) {
    case PATROL: 
      movePatrol();
      break;
    case TRACK: 
      trackHeat();
      break;
    case ATTACK: 
      followPlayer();
      break;
    }
    display();
  }

  public void updateCurrentRoutineAndTimer() {
    routineTimer += timer.deltaTime;
    if (state == PATROL) {
      if (routineTimer > patrolState.routines[currentRoutine].duration) {
        routineTimer = 0;
        if (currentRoutine == patrolState.routines.length - 1) {
          currentRoutine = 0;
        } else {
          currentRoutine++;
          shootCooldown = patrolState.routines[currentRoutine].shootCooldown;
        }
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
    int unassigned = totalNumQuotaAttributes;

    // generate array of numbers
    int[] array = new int[totalNumQuotaAttributes];
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
    for (int i = 0; i < 3; i++) {
      patrolState.routines[i].forwardVisionLength = array[0];
      patrolState.routines[i].proximityDetectionRadius = array[1];
      patrolState.routines[i].heatSenseThreshold = array[2];
      patrolState.routines[i].health = array[3];
    }

    // health is an attribute common to all states
    trackingState.routines[0].health = array[3];
    attackingState.routines[0].health = array[3];

    // assign each value from the array to one of the quota values in the routine
    for (int i = 0; i < 3; i++) {
      patrolState.routines[i].shootCooldown = array[4 + i];
    }

    trackingState.routines[0].rotationSpeed = array[7];
    trackingState.routines[0].forwardVisionLength = array[8];
    trackingState.routines[0].proximityDetectionRadius = array[9];
    trackingState.routines[0].heatSenseThreshold = array[10];
    trackingState.routines[0].shootCooldown = array[11];

    attackingState.routines[0].rotationSpeed = array[12];
    attackingState.routines[0].forwardVisionLength = array[13];
    attackingState.routines[0].proximityDetectionRadius = array[14];
    attackingState.routines[0].heatSenseThreshold = array[15];
    attackingState.routines[0].shootCooldown = array[16];    

    // assign non quota values
    for (int i =0; i < 3; i++) {
      patrolState.routines[i].forwardSpeed = random(0, 10);
      patrolState.routines[i].rotationSpeed = random(0, 0.1);
    }

    trackingState.routines[0].forwardSpeed = random(0, 10);
    attackingState.routines[0].forwardSpeed = random(0, 10);
  }

  private void movePatrol() {
    direction.rotate(patrolState.routines[currentRoutine].rotationSpeed);
    x = constrain(x + direction.x * patrolState.routines[currentRoutine].forwardSpeed, radius, width - radius);
    y = constrain(y + direction.y * patrolState.routines[currentRoutine].forwardSpeed, radius, height - radius);
    bounceOffWalls();
  }

  private void trackHeat() {
    if (targetParticle == null)
      return;

    PVector targetDirection = new PVector(targetParticle.x - x, targetParticle.y - y);
    float heading = modAngle(targetDirection.heading() - direction.heading());
    heading = -Math.signum(heading - PI);

    direction.rotate(0.12 * heading);
    x = constrain(x + direction.x * 5, radius, width - radius);
    y = constrain(y + direction.y * 5, radius, height - radius);
    bounceOffWalls();
  }

  private void followPlayer() {
    PVector targetDirection = new PVector(player.x - x, player.y - y);
    float heading = modAngle(targetDirection.heading() - direction.heading());
    heading = -Math.signum(heading - PI);

    direction.rotate(0.04 * heading);
    if (dist(player.x, player.y, x, y) > player.radius + forwardVisionLength) {
      x = constrain(x + direction.x * 5, radius, width - radius);
      y = constrain(y + direction.y * 5, radius, height - radius);
    }
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
    // Attack Vision
    if (state == ATTACK) {
      PVector targetDirection = new PVector(player.x - x, player.y - y);
      float heading = modAngle(targetDirection.heading() - direction.heading());
      float range = Math.abs(heading - PI);
      if (range > PI - attackVisionAngle && dist(player.x, player.y, x, y) < attackVisionDistance) {
        setState(ATTACK);
      }
    }

    // Forward Vision
    for (int i = 0; i < forwardVisionLength; i++) {
      float detectX = x + direction.x * i;
      float detectY = y + direction.y * i;
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
      } else if (targetParticle.heatLevel > heatSenseThreshold && state == TRACK) {
        if (dist(targetParticle.x, targetParticle.y, x, y) < radius) {
          setState(TRACK);
          targetParticle = targetParticle.next;
        }
        for (HeatTrailParticle p : heatTrail.particles) {
          for (int i = 0; i < heatVisionLength; i++) {
            float detectX = x + direction.x * i;
            float detectY = y + direction.y * i;
            if (dist(p.x, p.y, detectX, detectY) < p.radius) {
              setState(TRACK);
              targetParticle = p.next;
            }
          }
        }
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
    if (currentHealth <= 0 && !disabled) {
      disable();
    }
  }

  public void respawn() {
    // You can change this
    x = width - random(radius, width / 6);
    y = height / 2 + random(-height / 3, height / 3); 
    direction = new PVector(-1, 0);
    radius = random(8, 16);
    health = (int) random(3, 6);
    disengageDelay = 1;
    attackVisionDistance = random(200, 600);
    attackVisionAngle = random(PI/24, PI/4);
    forwardVisionLength = random(50, 150);
    proximityDetectionRadius = random(20, 80);
    heatVisionLength = random(20, 80);
    heatSenseThreshold = random(0, 190);
    shootCooldown = 5;

    // Don't change this
    initStates();
    state = PATROL;
    currentRoutine = 0;
    disengageTimer = 0;
    state = 0;
    currentHealth = health;
    disabled = false;
  }

  private void disable() {
    disabled = true;
    currentHealth = 0;
    x = -radius*2;
    y = -radius*2;
  }

  private void display() {
    if (state == ATTACK) {
      fill(255, 100, 0, 50);
      noStroke();
      arc(x, y, attackVisionDistance, attackVisionDistance, direction.heading() - attackVisionAngle, direction.heading() + attackVisionAngle, PIE);
    }

    fill(0, 100, 255, 25);
    noStroke();
    ellipse(x, y, proximityDetectionRadius * 2, proximityDetectionRadius * 2);

    stroke(200, 0, 255);
    strokeWeight(2);
    line(x, y, x + direction.x * forwardVisionLength, y + direction.y * forwardVisionLength);
    
    fill(255, 0, 0);
    stroke(0);
    strokeWeight(2);
    ellipse(x, y, radius * 2, radius * 2);
    textSize(20);
    textAlign(CENTER, CENTER);
    fill(0);
    text(currentHealth, x, y + radius*2);
  }
  
  private float modAngle(float a) {
    if (a < 0)
      return a + TWO_PI;
    return a;
  }
}
