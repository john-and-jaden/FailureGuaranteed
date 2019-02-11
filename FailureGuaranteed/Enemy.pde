public class Enemy {
  private float x, y;
  private PVector direction;
  private float rotationSpeed;
  private float radius;
  Routine[] routines;

  public Enemy() {
    initRoutines();
    rotationSpeed = random(0, 1);
    radius = 10;
    direction = new PVector(random(-1, 0), random(-1, 1));
    x = width - random(0, 50);
    y = height / 2 + random(-50, 50);
  }

  public void update() {
    if (x < 0 || x > width) {
      direction.x = - direction.x;
    }
    if (y < 0 || y > height) {
      direction.y = - direction.y;
    }
    x += direction.x;
    y += direction.y;
    direction.rotate(0.1 * rotationSpeed);
  }

  public void display() {
    fill(255, 0, 0);
    ellipse(x, y, radius, radius);
  }

  private void initRoutines() {
    routines = new Routine[3];
    for (int i = 0; i < routines.length; i++) {
      routines[i].dirX = random(-1, 0);
      routines[i].dirY = random(-1, 1);
      routines[i].rotationSpeed = random(-1, 1);
    }
  }

  private class Routine {
    float dirX;
    float dirY;
    float rotationSpeed;
  }
}
