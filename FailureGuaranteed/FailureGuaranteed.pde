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
  p.update();
}

void keyPressed() {
  if (keyCode == 'W' || keyCode == UP)
    p.moveDirection(0, 1);
  if (keyCode == 'S' || keyCode == DOWN)
    p.moveDirection(0, -1);
  if (keyCode == 'D' || keyCode == RIGHT)
    p.moveDirection(1, 0);
  if (keyCode == 'A' || keyCode == LEFT)
    p.moveDirection(-1, 0);
}

void keyReleased() {
  if (keyCode == 'W' || keyCode == UP)
    p.stopDirection(0, 1);
  if (keyCode == 'S' || keyCode == DOWN)
    p.stopDirection(0, -1);
  if (keyCode == 'D' || keyCode == RIGHT)
    p.stopDirection(1, 0);
  if (keyCode == 'A' || keyCode == LEFT)
    p.stopDirection(-1, 0);
}
