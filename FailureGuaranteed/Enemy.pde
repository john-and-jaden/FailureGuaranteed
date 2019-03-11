public class Enemy {
  public final int PATROL = 0, TRACK = 1, ATTACK = 2;
  private float x, y;
  private PVector direction;
  private float radius;
  private int health;
  private float disengageDelay;

  State[] states;
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
    states = new State[3];
    states[0] = new State(PATROL);
    states[1] = new State(TRACK);
    states[2] = new State(ATTACK);


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

  private float scaleForwardSpeed(int value) {
    if (value < 10) {
      return 0;
    } else {
      return value/4;
    }
  }
  
  private void getStandardCurve(int value) {
    // from 0 to 10, quadratic up
    // from 10 to 40, linear
    // from 40 to 50, quadratic down
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
    if (dist(player.x, player.y, x, y) > player.radius + states[currentState].forwardVisionLength) {
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
      if (range > PI - states[currentState].attackVisionAngle 
        && dist(player.x, player.y, x, y) < states[currentState].attackVisionDistance) {
        setState(ATTACK);
      }
    }

    // Forward Vision
    for (int i = 0; i < states[currentState].forwardVisionLength; i++) {
      float detectX = x + direction.x * i;
      float detectY = y + direction.y * i;
      if (dist(player.x, player.y, detectX, detectY) < player.radius) {
        setState(ATTACK);
      }
    }

    // Proximity Vision
    if (dist(player.x, player.y, x, y) < states[currentState].proximityDetectionRadius + player.radius) {
      setState(ATTACK);
    }

    // Heat Vision
    if (targetParticle == null && currentState == PATROL) {
      for (HeatTrailParticle p : heatTrail.particles) {
        if (targetParticle != null) {
          continue;
        }
        if (dist(p.x, p.y, x, y) < radius && p.heatLevel > states[currentState].heatSenseThreshold) {
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
      } else if (targetParticle.heatLevel > states[currentState].heatSenseThreshold && currentState == TRACK) {
        if (dist(targetParticle.x, targetParticle.y, x, y) < radius) {
          setState(TRACK);
          targetParticle = targetParticle.next;
        }
        for (HeatTrailParticle p : heatTrail.particles) {
          for (int i = 0; i < states[currentState].heatVisionLength; i++) {
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
    currentRoutine = 0;
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

    if (shootTimer > states[currentState].routines[currentRoutine].shootCooldown) {
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
      arc(x, y, states[currentState].attackVisionDistance, states[currentState].attackVisionDistance, 
        direction.heading() - states[currentState].attackVisionAngle, direction.heading() + states[currentState].attackVisionAngle, PIE);
    }

    fill(0, 100, 255, 25);
    noStroke();
    ellipse(x, y, states[currentState].proximityDetectionRadius * 2, states[currentState].proximityDetectionRadius * 2);

    stroke(200, 0, 255);
    strokeWeight(2);
    line(x, y, x + direction.x * states[currentState].forwardVisionLength, y + direction.y * states[currentState].forwardVisionLength);

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

  private class State {
    int typeOfState;
    float attackVisionDistance;
    float attackVisionAngle;
    float forwardVisionLength;
    float proximityDetectionRadius;
    float heatVisionLength;
    float heatSenseThreshold;
    Routine[] routines;

    State(int typeOfState) {
      this.typeOfState = typeOfState;
      init();
    }

    private void init() {
      switch(typeOfState) {
      case PATROL: 
        initRoutines(3); 
        break;
      case TRACK: 
      case ATTACK: 
        initRoutines(1);
      }
    }

    private void initRoutines(int numRoutines) {
      routines = new Routine[numRoutines];
      for (int i = 0; i < numRoutines; i++) {
        routines[i] = new Routine();
      }
    }

    private class Routine {
      // routine specific
      int duration;

      // movement specific
      float forwardSpeed;
      float rotationSpeed;

      // attack specific
      float shootCooldown;
    }
  }
}
