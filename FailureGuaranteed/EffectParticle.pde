public class EffectParticle extends DestroyableObject {
  float x, y;
  float size;
  PVector direction;
  float speed;
  float lifetime;
  
  PShape shape;
  float destroyTimer;
  
  public EffectParticle(float x, float y, float size, PVector direction, float speed, float lifetime) {
    this.x = x + direction.x * size;
    this.y = y + direction.y * size;
    this.size = size;
    this.direction = direction.copy();
    this.speed = speed;
    this.lifetime = lifetime;
    shape = createShape();
    shape.beginShape();
    //Draw shape here (thinking random triangle)
    for (int i = 0; i < 3; i++) {
      PVector rotation = new PVector(size, 0);
      rotation.rotate(i*2*PI/3 + random(0, 2*PI/3));
      shape.vertex(rotation.x, rotation.y);
    }
    shape.endShape(CLOSE);
    destroyTimer = 0;
    display();
  }
  
  public void update() {
    destroyTimer += timer.deltaTime;
    if (destroyTimer >= lifetime)
      flag();
      
    x += direction.x * speed;
    y += direction.y * speed;
    
    display();
  }
  
  private void display() {
    shape(shape, x, y);
  }
}
