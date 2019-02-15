public class Player {
  private float x, y;
  private float radius;
  private float speed;
  private int health;
  private float shootCooldown;
  
  private float shootTimer;
  private int currentHealth;
  private float right, left, up, down;

  public Player() {
    // You can modify this
    x = width/2;
    y = height/2;
    radius = 20;
    speed = 5;
    health = 25;
    shootCooldown = 0.5;
    
    // Don't modify this
    currentHealth = health;
    shootTimer = 0;
  }

  public void update() {
    shootTimer += t.deltaTime;
    x = constrain(x + (right - left), radius, width-radius);
    y = constrain(y + (down - up), radius, height-radius);
            
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
    fill(255, 0, 0);
    ellipse(x, y, radius*2, radius*2);
  }
  
  private PVector getMouseDirection() {
    return new PVector(mouseX - x, mouseY - y).normalize();
  }
}
