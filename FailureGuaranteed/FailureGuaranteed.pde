Player p;
ArrayList<PlayerBullet> playerBullets;
ArrayList<HeatTrailParticle> heatTrail;
EnemyController ec;
Timer t;

void setup() {
  fullScreen();
  t = new Timer();
  p = new Player();
  playerBullets = new ArrayList<PlayerBullet>();
  ec = new EnemyController();
}

void draw() {
  background(255);
  t.update();
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
