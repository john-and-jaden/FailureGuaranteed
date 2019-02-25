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
  
  EnemyState[] states;
  private int currentRoutine;
  private int currentState;
  private float disengageTimer;
  private float routineTimer;
  private float shootTimer;
  private int currentHealth;
  private HeatTrailParticle targetParticle;
  int totalNumQuotaAttributes;
  private boolean disabled;

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
    currentState = PATROL;
    currentRoutine = 0;
    disengageTimer = 0;
    currentState = 0;
    initStates();
    currentHealth = health;
    disabled = false;
  }

  public void update() {
    if (disabled)
      return;
    updateRoutines();
    disengage();
    search();
    shoot();

    switch (currentState) {
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

  public void updateRoutines() {
    routineTimer += timer.deltaTime;
    if (routineTimer > states[currentState].routines[currentRoutine].duration) {
      routineTimer = 0;
      if (currentRoutine == states[currentState].routines.length - 1) {
        currentRoutine = 0;
      } else {
        currentRoutine++;
      }
    }
  }

  private void initStates() {
    states = new EnemyState[3];
    states[0] = new EnemyState(PATROL);
    states[1] = new EnemyState(TRACK);
    states[2] = new EnemyState(ATTACK);
    
    
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
    
    int index = 0;
    
    // attributes common to all states
    health = array[index++];
    
    for (int i = 0; i < states.length; i++) {
      // attributes common to all routines
      states[i].forwardVisionLength = array[index++];
      states[i].proximityDetectionRadius = array[index++];
      states[i].heatSenseThreshold = array[index++];
      
      // attributes unique within each routine
      for (int j = 0; j < states[i].routines.length; j++) {
        states[i].routines[j].forwardSpeed = random(0, maxValue);
        if (i == PATROL) {
          states[i].routines[j].rotationSpeed = random(0, maxValue);
        } else {
          states[i].routines[j].rotationSpeed = array[index++];
        }
        states[i].routines[j].shootCooldown = array[index++];
      }
    }
  }

  private void movePatrol() {
    direction.rotate(states[currentState].routines[currentRoutine].rotationSpeed);
    x = constrain(x + direction.x * states[currentState].routines[currentRoutine].forwardSpeed, radius, width - radius);
    y = constrain(y + direction.y * states[currentState].routines[currentRoutine].forwardSpeed, radius, height - radius);
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
    if (currentState == ATTACK) {
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
    if (targetParticle == null && currentState == PATROL) {
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
        if (currentState == TRACK) {
          setState(PATROL);
        }
      } else if (targetParticle.heatLevel > heatSenseThreshold && currentState == TRACK) {
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
    this.currentState = state;
    disengageTimer = 0;
  }

  private void disengage() {
    if (currentState != PATROL) {
      disengageTimer += timer.deltaTime;
      if (disengageTimer > disengageDelay) {
        currentState = PATROL;
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
    currentState = PATROL;
    currentRoutine = 0;
    disengageTimer = 0;
    currentState = 0;
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
    if (currentState == ATTACK) {
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
