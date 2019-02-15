public class HeatTrailParticle extends DestroyableObject {
  float x, y;
  float size;
  float heatLevel;
  float heatDecay;
  HeatTrailParticle next;
  
  public HeatTrailParticle(float x, float y, float size) {
    // You can modify this
    heatLevel = 100;
    heatDecay = 1;
    
    // Don't modify this
    this.x = x;
    this.y = y;
    this.size = size;
  }
  
  public void update() {
    heatLevel -= heatDecay;
    
    if (heatLevel <= 0)
      flag();
  }
  
  public void display() {
    stroke(255, 0, 0);
    strokeWeight(size);
    strokeCap(PROJECT);
    point(x, y);
  }
}
