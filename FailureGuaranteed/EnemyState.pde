public class EnemyState {
  float forwardSpeed;
  float rotationSpeed;
  float forwardVisionLength;
  float proximityDetectionRadius;
  float heatSenseThreshold;
  float shootCooldown;
  
  Routine[] routines;
  
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
