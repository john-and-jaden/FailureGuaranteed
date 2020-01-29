public class Enemy2 {
  private float x, y;
  private PVector direction;
  private float radius;
  private float cannonLength;
  
  private EnumMap<EnemyAttributes, Attribute> attributes;
  
  private class Attribute {
    public static final int MAX_RANKS = 5;
    public int rank = 0;
    public float weight = 0.5f;
  }
  
  public Enemy2() {
    // You can change this
    x = width - random(radius, width / 6);
    y = height / 2 + random(-height / 3, height / 3); 
    direction = new PVector(-1, 0);
    radius = random(8, 16);
    cannonLength = radius * 0.75;
  }
  
  private void init()
  {
    attributes = new EnumMap<EnemyAttributes, Attribute>(EnemyAttributes.class);
    attributes.put(EnemyAttributes.Health, new Attribute());
  }
  
  public void update()
  {
    display();
  }
  
  private void display()
  {
    
  }
}
