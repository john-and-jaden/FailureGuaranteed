public class Enemy {
  private float x, y;
  private PVector direction;
  private float rotationSpeed;
  private float radius;
  Routine[] routines;
  int currentRoutine;
  float routineTimer;

  public Enemy() {
    currentRoutine = 0;
    initRoutines();
    rotationSpeed = random(0, 1);
    radius = 10;
    direction = new PVector(random(-1, 0), random(-1, 1));
    x = width - random(0, 50);
    y = height / 2 + random(-50, 50);
  }

  public void update() {
    rotationSpeed = routines[currentRoutine].rotationSpeed;
    direction.set(routines[currentRoutine].dirX, routines[currentRoutine].dirY);
    updateRoutinesAndTimer();
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
  
  public void updateRoutinesAndTimer() {
    routineTimer += t.deltaTime;
    if (routineTimer > routines[currentRoutine].duration) {
      routineTimer = 0;
      if (currentRoutine == routines.length - 1) {
        currentRoutine = 0;
      } else {
        currentRoutine++;
      }
    }
  }

  public void display() {
    fill(255, 0, 0);
    ellipse(x, y, radius, radius);
  }

  private void initRoutines() {
    routines = new Routine[3];
    for (int i = 0; i < routines.length; i++) {
      routines[i] = new Routine();
      routines[i].dirX = random(-1, 0);
      routines[i].dirY = random(-1, 1);
      routines[i].rotationSpeed = random(-10, 10);
      routines[i].duration = 3;
    }
  }

  private class Routine {
    int duration;
    float dirX;
    float dirY;
    float rotationSpeed;
  }
}
