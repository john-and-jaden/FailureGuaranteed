Player p;
EnemyController ec;

void setup() {
  fullScreen();
  p = new Player();
  p.init();
  ec = new EnemyController();
  ec.init();
}

void draw() {
  background(255);
}
