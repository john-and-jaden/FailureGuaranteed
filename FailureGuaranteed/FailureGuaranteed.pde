Player p;
ArrayList<PlayerBullet> playerBullets;
HeatTrail heatTrail;
EnemyController ec;
Timer time;

void setup() {
  fullScreen();
  time = new Timer();
  p = new Player();
  playerBullets = new ArrayList<PlayerBullet>();
  heatTrail = new HeatTrail();
  ec = new EnemyController();
}

void draw() {
  background(255);
  
  time.update();
  ec.update();
  p.update();
  
  ArrayList<PlayerBullet> flaggedPlayerBullets = new ArrayList<PlayerBullet>();
  for (PlayerBullet bullet : playerBullets) {
    bullet.update();
    if (bullet.isFlagged())
      flaggedPlayerBullets.add(bullet);
  }
  playerBullets.removeAll(flaggedPlayerBullets);
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

void mouseClicked() {
  p.shoot();
}
