public class Player {
  private float x, y;
  private float radius;
  private float speed;
  private int health;
  private float shootCooldown;
  private float trailSpawnCooldown;
  
  private float shootTimer;
  private float trailSpawnTimer;
  private int currentHealth;
  private float right, left, up, down;

  public Player() {
    // You can modify this
    x = width/2;
    y = height/2;
    radius = 20;
    speed = 5;
    health = 25;
    shootCooldown = 0.2;
    trailSpawnCooldown = 0;
    
    // Don't modify this
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
  
  public void takeDamage(int damage) {
    currentHealth -= damage;
    
    if (currentHealth <= 0) {
      // lose a life, go to next wave 
    }
  }
  
  public void shoot() {
    if (shootTimer > shootCooldown) {
      playerBullets.add(new PlayerBullet(x, y, getMouseDirection(), radius));
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
    fill(0, 255, 200);
    stroke(0);
    strokeWeight(2);
    ellipse(x, y, radius*2, radius*2);
    textSize(20);
    textAlign(CENTER, CENTER);
    fill(0);
    text(currentHealth, x, y);
  }
  
  private PVector getMouseDirection() {
    return new PVector(mouseX - x, mouseY - y).normalize();
  }
}
