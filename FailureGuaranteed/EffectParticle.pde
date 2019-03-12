public class EffectParticle extends DestroyableObject {
  float x, y;
  PVector direction;
  float speed;
  float lifetime;
  
  PShape shape;
  float destroyTimer;
  
  public EffectParticle(float x, float y, PVector direction, float speed, float lifetime) {
    this.x = x;
    this.y = y;
    this.direction = direction.copy();
    this.speed = speed;
    this.lifetime = lifetime;
    shape = createShape();
    //Draw shape here (thinking random triangle)
    destroyTimer = 0;
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
    shape(shape);
  }
}
