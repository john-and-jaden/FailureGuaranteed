public class HeatTrailParticle extends DestroyableObject {
  public float x, y;
  public float radius;
  public float maxHeatLevel;
  public float heatDecay;
  public int numDisplayParticles;
  public HeatTrailParticle next;
  
  public float heatLevel;
  
  public HeatTrailParticle(float x, float y) {
    // You can modify this
    radius = 20;
    maxHeatLevel = 200;
    heatDecay = 1;
    numDisplayParticles = 4;
    
    // Don't modify this
    this.x = x;
    this.y = y;
    heatLevel = maxHeatLevel;
    display();
  }
  
  public void update() {
    if (isFlagged())
      return;
      
    heatLevel -= heatDecay;
    
    if (heatLevel <= 0)
      flag();
    
    display();
  }
  
  private void display() {
    for (int i = 0; i < numDisplayParticles; i++) {
      float yellow = map(heatLevel, maxHeatLevel, 0, 50, 200);
      float t = map(i, 0, numDisplayParticles, 20, 255);
      stroke(255, yellow, 0, t);
      float s = map(i, 0, numDisplayParticles, radius, 3);
      s *= norm(heatLevel, 0, maxHeatLevel);
      strokeWeight(s);
      point(x, y);
    }
  }
}
