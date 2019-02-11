Player p;
EnemyController ec;

void setup() {
  fullScreen();
  p = new Player();
  ec = new EnemyController();
}

void draw() {
  background(255);
  ec.update();
}
