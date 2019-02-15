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
    direction = new PVector(-1, 0);
    x = width - random(0, 50);
    y = height / 2 + random(-50, 50);
  }

  public void update() {
    updateCurrentRoutineAndTimer();
    if (x <= radius || x >= width - radius) {
      direction.x = - direction.x;
    }
    if (y <= radius || y >= height - radius) {
      direction.y = - direction.y;
    }
    direction.rotate(0.1 * routines[currentRoutine].rotationSpeed);
    x = constrain(x + direction.x * routines[currentRoutine].forwardSpeed, radius, width - radius);
    y = constrain(y + direction.y * routines[currentRoutine].forwardSpeed, radius, height - radius);
  }
  
  public void updateCurrentRoutineAndTimer() {
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
    ellipse(x, y, radius * 2, radius * 2);
  }
  
  private void initRoutines() {
    routines = new Routine[3];
    for (int i = 0; i < routines.length; i++) {
      routines[i] = new Routine();
      routines[i].forwardSpeed = random(0, 20);
      routines[i].rotationSpeed = random(0, 2);
      routines[i].duration = (int)random(1, 4);
    }
  }

  private class Routine {
    int duration;
    float forwardSpeed;
    float rotationSpeed;
  }
}
