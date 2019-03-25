public class Player {
  private float x, y;
  private int totalLives;
  private float radius;
  private float cannonLength;
  private float speed;
  private int health;
  private float shootCooldown;
  private float trailSpawnCooldown;
  
  private int remainingLives;
  private float shootTimer;
  private float trailSpawnTimer;
  private int currentHealth;
  private float right, left, up, down;
  private boolean hasShot;

  public Player() {
    // You can modify this
    x = width/2;
    y = height/2;
    totalLives = 3;
    radius = 20;
    cannonLength = 15;
    speed = 5;
    health = 30;
    shootCooldown = 0.2;
    trailSpawnCooldown = 0;
    
    // Don't modify this
    remainingLives = totalLives;
    hasShot = false;
    currentHealth = health;
    shootTimer = 0;
    trailSpawnTimer = 0;
  }

  public void update() {
    shootTimer += timer.deltaTime;
    trailSpawnTimer += timer.deltaTime;
    float newX = constrain(x + (right - left), radius, width-radius);
    float newY = constrain(y + (down - up), radius, height-radius);
    boolean hasMoved = newX != x || newY != y;
    if (hasMoved && trailSpawnTimer >= trailSpawnCooldown) {
      heatTrail.spawnParticle(x, y);
      trailSpawnTimer = 0;
    }
    x = newX;
    y = newY;
    display();
  }
  
  public void respawn() {
    x = width/2;
    y = height/2;
    hasShot = false;
    currentHealth = health;
    shootTimer = 0;
    trailSpawnTimer = 0;
  }
  
  public void takeDamage(int damage) {
    currentHealth -= damage;
    
    if (currentHealth <= 0) {
      remainingLives--;
      
      if (remainingLives <= 0) {
        changeScene(DEATH_SCENE); 
      }
    }
  }
  
  public void shoot() {
    if (shootTimer > shootCooldown) {
      playerBullets.add(new PlayerBullet(x, y, getMouseDirection(), radius + cannonLength));
      hasShot = true;
      shootTimer = 0;
    }
  }

  // called from keyPressed() to set the state of the movement keys
  public void moveDirection(float x, float y) {
    if (x == 1)
      right = speed;
    else if (x == -1)
      left = speed;
    else if (y == 1)
      up = speed;
    else if (y == -1)
      down = speed;
  }
  
  // called from keyPressed() to set the state of the movement keys
  public void stopDirection(float x, float y) {
    if (x == 1)
      right = 0;
    else if (x == -1)
      left = 0;
    else if (y == 1)
      up = 0;
    else if (y == -1)
      down = 0;
  }

  private void display() {
    // Bullet effects
    if (hasShot) {
      hasShot = false;
      shootDisplay();
    }
    
    // Cannon
    fill(30);
    stroke(0);
    strokeWeight(2);
    float cannonWidth = 10;
    PVector mouseDir = getMouseDirection().mult(radius + cannonLength);
    PVector parallelDir = getMouseDirection().rotate(PI/2).mult(cannonWidth/2);
    quad(
      x + parallelDir.x, y + parallelDir.y,
      x + parallelDir.x + mouseDir.x, y + parallelDir.y + mouseDir.y,
      x - parallelDir.x + mouseDir.x, y - parallelDir.y + mouseDir.y,
      x - parallelDir.x, y - parallelDir.y
    );

    // Player
    fill(0, 255, 200);
    stroke(0);
    strokeWeight(2);
    ellipse(x, y, radius*2, radius*2);
    
    // Health text
    textSize(20);
    textAlign(CENTER, CENTER);
    fill(0);
    text(currentHealth, x, y + radius*2);
  }
  
  private void shootDisplay() {
    fill(255, 255, 0);
    noStroke();
    for (int i = 0; i < 3; i++) {
      float size = 8;
      float speed = 2 + this.speed;
      float lifetime = 0.1;
      float spread = random(-PI/8, PI/8);
      PVector mouseDir = getMouseDirection();
      PVector spreadDir = getMouseDirection().rotate(spread);
      effectParticles.add(new EffectParticle(x + mouseDir.x * (radius + cannonLength), y + mouseDir.y * (radius + cannonLength), size, spreadDir, speed, lifetime));
    }
  }
  
  private PVector getMouseDirection() {
    return new PVector(mouseX - x, mouseY - y).normalize();
  }
}
