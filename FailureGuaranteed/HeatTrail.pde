public class HeatTrail {
  ArrayList<HeatTrailParticle> particles;
  HeatTrailParticle last;
  
  public HeatTrail() {
    // Don't modify this
    particles = new ArrayList<HeatTrailParticle>();
  }
  
  public void update() {
    ArrayList<HeatTrailParticle> flaggedParticles = new ArrayList<HeatTrailParticle>();
    for (HeatTrailParticle particle : particles) {
      particle.update(); 
      if (particle.isFlagged()) 
        flaggedParticles.add(particle);
    }
    particles.removeAll(flaggedParticles);
  }
  
  public void spawnParticle(float x, float y) {
    HeatTrailParticle particle = new HeatTrailParticle(x, y, 10); // SIZE ADDED BY JP TO CORRECT AN ERROR
    particles.add(particle);
    if (last != null)
      last.next = particle;
    last = particle;
  }
}
