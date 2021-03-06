public class Enemy implements Cloneable {
  public final int PATROL = 0, TRACK = 1, ATTACK = 2;
  private float x, y;
  private PVector direction;
  private float radius;
  private float cannonLength;
  private int health;
  private float disengageDelay;
  private float attackVisionDistance;
  private float attackVisionAngle;
  private float heatVisionLength;
  private float heatSenseThreshold;

  State[] states;
  public float[] attributeWeights;
  private int currentRoutine;
  private int currentState;
  private float disengageTimer;
  private float routineTimer;
  private float shootTimer;
  private int currentHealth;
  private boolean hasShot;
  private HeatTrailParticle targetParticle;
  int totalNumQuotaAttributes;
  private boolean disabled;

  // genetic algorithm related
  float fitness;
  float relativeFitness;
  float attackTimer;
  float trackTimer;
  float lifetime;
  int damageDealt;
  
  public Enemy() {
    // You can change this
    x = width - random(radius, width / 6);
    y = height / 2 + random(-height / 3, height / 3); 
    direction = new PVector(-1, 0);
    radius = random(8, 16);
    cannonLength = radius * 0.75;
    disengageDelay = 1;
    totalNumQuotaAttributes = 23;

    // Don't change this
    currentState = PATROL;
    currentRoutine = 0;
    disengageTimer = 0;
    currentState = 0;
    initStates();
    hasShot = false;
    disabled = false;

    // genetic algorithm
    fitness = 0;
    attackTimer = 0;
    trackTimer = 0;
    lifetime = 0; 
    damageDealt = 0;
  }
  
  public void update() {
    if (disabled)
      return;
    lifetime += timer.deltaTime;
    updateRoutines();
    disengage();
    search();
    shoot();
    
    switch (currentState) {
    case PATROL: 
      movePatrol();
      break;
    case TRACK: 
      trackTimer += timer.deltaTime;
      trackHeat();
      break;
    case ATTACK: 
      attackTimer += timer.deltaTime;
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

    //float quota = (int)(totalNumQuotaAttributes * 0.3);
    float quota = 12;
    float remainder = quota;

    // generate array of numbers
    println("New Enemy");
    attributeWeights = new float[totalNumQuotaAttributes];
    int currentIndex = 0;
    while (remainder > 0) {
      float assigningValue = random(0, constrain(remainder, 0, 1 - attributeWeights[currentIndex]));
      attributeWeights[currentIndex] += assigningValue;
      remainder -= assigningValue;
      if (remainder <= EPSILON)
        remainder = 0;
      currentIndex++;
      if (currentIndex > attributeWeights.length - 1) {
        currentIndex = 0;
      }
      println(assigningValue);
    }
    
    // randomize array order
    for (int i = 0; i < attributeWeights.length; i++) {
      int newIndex = (int)random(0, attributeWeights.length);
      float temp = attributeWeights[i];
      attributeWeights[i] = attributeWeights[newIndex];
      attributeWeights[newIndex] = temp;
    }

    int index = 0;

    // attributes common to all states
    health = (int) mapAttribute(attributeWeights[index++], 3, 3, 3, 12, 12, 30);
    attackVisionDistance = (int) mapAttribute(attributeWeights[index++], 0, 20, 30, 100, 120, 200) + radius;
    attackVisionAngle = mapAttribute(attributeWeights[index++], 0, PI/12, PI/10, PI/8, PI/6, PI/4);
    heatSenseThreshold = (int) mapAttribute(attributeWeights[index++], 0, 50, 50, 150, 150, 200);
    heatVisionLength = (int) mapAttribute(attributeWeights[index++], 0, 10, 20, 60, 60, 120) + radius;
    currentHealth = health;

    for (int i = 0; i < states.length; i++) {
      // attributes common to all routines
      states[i].forwardVisionLength = (int) mapAttribute(attributeWeights[index++], 0, 10, 20, 60, 60, 120) + radius;
      states[i].proximityDetectionRadius = (int) mapAttribute(attributeWeights[index++], 0, 5, 10, 40, 50, 80) + radius;

      // attributes unique within each routine
      for (int j = 0; j < states[i].routines.length; j++) {
        states[i].routines[j].duration = 1;
        states[i].routines[j].forwardSpeed = mapAttribute(random(0, 1), 0, 0.5, 1, 5, 6, 10);
        if (i == PATROL) {
          states[i].routines[j].rotationSpeed = mapAttribute(random(0, 1), 0, 0.05, 0.05, 0.25, 0.3, 0.5) * pow(-1, (int)random(1, 3));
        } else {
          states[i].routines[j].rotationSpeed = mapAttribute(attributeWeights[index++], 0, 0.05, 0.05, 0.25, 0.3, 0.5);
        }
        states[i].routines[j].shootCooldown = mapAttribute(attributeWeights[index++], 4, 2, 2, 0.5, 0.25, 0.1);
        states[i].routines[j].bulletSpeed = mapAttribute(random(0, 1), 0, 1, 6, 10, 10, 15);
        states[i].routines[j].bulletDamage = (int) mapAttribute(attributeWeights[index++], 1, 2, 3, 8, 12, 15);
      }
    }
  }

  private float mapAttribute(float value, float min1, float min2, float mid1, float mid2, float max1, float max2) {
    float result = 0;
    if (value < 0.2) {
      result = map(value, 0, 0.2, min1, min2);
    } else if (value < 0.8) {
      result = map(value, 0.2, 0.8, mid1, mid2);
    } else {
      result = map(value, 0.8, 1, max1, max2);
    }
    return result;
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

    direction.rotate(states[currentState].routines[currentRoutine].rotationSpeed * heading);
    x = constrain(x + direction.x * states[currentState].routines[currentRoutine].forwardSpeed, radius, width - radius);
    y = constrain(y + direction.y * states[currentState].routines[currentRoutine].forwardSpeed, radius, height - radius);
    bounceOffWalls();
  }

  private void followPlayer() {
    PVector targetDirection = new PVector(player.x - x, player.y - y);
    float heading = modAngle(targetDirection.heading() - direction.heading());
    heading = -Math.signum(heading - PI);

    direction.rotate(states[currentState].routines[currentRoutine].rotationSpeed * heading);
    if (dist(player.x, player.y, x, y) > player.radius + states[currentState].forwardVisionLength) {
      x = constrain(x + direction.x * states[currentState].routines[currentRoutine].forwardSpeed, radius, width - radius);
      y = constrain(y + direction.y * states[currentState].routines[currentRoutine].forwardSpeed, radius, height - radius);
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
      if (range > PI - attackVisionAngle 
        && dist(player.x, player.y, x, y) < attackVisionDistance) {
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
      float s = states[currentState].routines[currentRoutine].bulletSpeed;
      int d = states[currentState].routines[currentRoutine].bulletDamage;
      enemyBullets.add(new EnemyBullet(x, y, direction.copy(), radius + cannonLength, s, d, this));
      hasShot = true;
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

    // Don't change this
    currentState = PATROL;
    currentRoutine = 0;
    disengageTimer = 0;
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
    // Attack vision
    if (currentState == ATTACK) {
      fill(255, 100, 0, 50);
      noStroke();
      arc(x, y, attackVisionDistance, attackVisionDistance, 
        direction.heading() - attackVisionAngle, direction.heading() + attackVisionAngle, PIE);
    }

    // Proximity vision
    fill(0, 100, 255, 25);
    noStroke();
    ellipse(x, y, states[currentState].proximityDetectionRadius * 2, states[currentState].proximityDetectionRadius * 2);

    // Forward vision
    stroke(200, 0, 255);
    strokeWeight(2);
    line(x, y, x + direction.x * states[currentState].forwardVisionLength, y + direction.y * states[currentState].forwardVisionLength);

    // Cannon
    fill(30);
    stroke(0);
    strokeWeight(2);
    float cannonWidth = radius/2;
    PVector mouseDir = direction.copy().mult(radius + cannonLength);
    PVector parallelDir = direction.copy().rotate(PI/2).mult(cannonWidth/2);
    quad(
      x + parallelDir.x, y + parallelDir.y, 
      x + parallelDir.x + mouseDir.x, y + parallelDir.y + mouseDir.y, 
      x - parallelDir.x + mouseDir.x, y - parallelDir.y + mouseDir.y, 
      x - parallelDir.x, y - parallelDir.y
      );

    // Enemy
    fill(255, 0, 0);
    stroke(0);
    strokeWeight(2);
    ellipse(x, y, radius * 2, radius * 2);

    // Health text
    textSize(20);
    textAlign(CENTER, CENTER);
    fill(0);
    text(currentHealth, x, y + radius*2);
    
    // Debug text
    float d = 20;
    textSize(d);
    textAlign(CENTER, CENTER);
    fill(0);
    for (int i = 0; i < attributeWeights.length; i++) {
      text(attributeWeights[i], x, y + d*(i+2)); 
    }

    if (hasShot) {
      hasShot = false;
      shootDisplay();
    }
  }

  private void shootDisplay() {
    fill(255, 255, 0);
    noStroke();
    for (int i = 0; i < 3; i++) {
      float size = radius/2;
      float speed = 2 + states[currentState].routines[currentRoutine].forwardSpeed;
      float lifetime = 0.1;
      float spread = random(-PI/8, PI/8);
      PVector spreadDir = direction.copy().rotate(spread);
      effectParticles.add(new EffectParticle(x + direction.x * (radius + cannonLength), y + direction.y * (radius + cannonLength), size, spreadDir, speed, lifetime));
    }
  }

  private float modAngle(float a) {
    if (a < 0)
      return a + TWO_PI;
    return a;
  }
  
  public Object clone() throws CloneNotSupportedException {
    Enemy clone = (Enemy) super.clone();
    clone.targetParticle = null;
    for (int i = 0; i < states.length; i++) {
      clone.states[i] = (State) states[i].clone();
    }
    return clone;
  }
  
  public int getIndexOfHighestAttribute() {
    float max = attributeWeights[0];
    int index = 0;
    for(int i = 0; i < attributeWeights.length; i++) {
     if(attributeWeights[i] > max) {
      max = attributeWeights[i]; 
      index = i;
     }
    }
    return index;
  }
  
  public int getIndexOfLowestAttribute() {
    float min = attributeWeights[0];
    int index = 0;
    for(int i = 0; i < attributeWeights.length; i++) {
     if(attributeWeights[i] < min) {
      min = attributeWeights[i]; 
      index = i;
     }
    }
    return index;
  }

  private class State implements Cloneable {
    int typeOfState;
    float forwardVisionLength;
    float proximityDetectionRadius;
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
        initRoutines(1);
        break;
      case ATTACK: 
        initRoutines(1);
        break;
      }
    }

    private void initRoutines(int numRoutines) {
      routines = new Routine[numRoutines];
      for (int i = 0; i < numRoutines; i++) {
        routines[i] = new Routine();
      }
    }
    
    public Object clone() throws CloneNotSupportedException {
      State clone = (State)super.clone();
      for (int i = 0; i < routines.length; i++) {
        clone.routines[i] = (Routine) routines[i].clone();
      }
      return clone;
    }

    private class Routine implements Cloneable {
      // routine specific
      float duration;

      // movement specific
      float forwardSpeed;
      float rotationSpeed;

      // attack specific
      float shootCooldown;
      float bulletSpeed;
      int bulletDamage;
      
      public Object clone() throws CloneNotSupportedException {
        return (Routine)super.clone();
      }
    }
  }
}
