public class HeatTrailParticle {
  float x, y;
  float heatLevel;
  float heatDecay;
  
  public HeatTrailParticle(float x, float y) {
    // You can modify this
    heatLevel = 100;
    heatDecay = 1;
    
    // Don't modify this
    this.x = x;
    this.y = y;
  }
  
  public void update() {
    heatLevel -= heatDecay;
  }
}
