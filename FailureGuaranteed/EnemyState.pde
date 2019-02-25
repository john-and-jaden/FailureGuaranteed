public class EnemyState {
  int typeOfState;

  float forwardSpeed;
  float rotationSpeed;
  float forwardVisionLength;
  float proximityDetectionRadius;
  float heatSenseThreshold;
  float shootCooldown;
  Routine[] routines;
  
  int totalNumberAttributes = 18;

  EnemyState(int typeOfState) {
    this.typeOfState = typeOfState;
    init();
  }
  
  private void init() {
    switch(typeOfState) {
     case PATROL: initRoutines(3); break;
     case TRACK: 
     case ATTACK: initRoutines(1);
    }
  }
  
  private void initRoutines(int numRoutines) {
    routines = new Routine[numRoutines];
    for(int i = 0; i < numRoutines; i++) {
      routines[i] = new Routine();
    }
  }






  // assign the non-quota values
  /*
  routine.duration = (int)random(1, 5);
  routine.forwardSpeed = random(0, 10);
  routine.rotationSpeed = random(0, 5);
  */

private class Routine {
  // routine specific
  int duration;

  // movement specific
  float forwardSpeed;
  float rotationSpeed;

  // detection & vision specific
  float forwardVisionLength;
  float proximityDetectionRadius;
  float heatSenseThreshold;

  // attack specific
  float shootCooldown;

  // health
  int health;
}
}
