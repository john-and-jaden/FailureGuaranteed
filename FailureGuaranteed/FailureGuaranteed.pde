Player player;
ArrayList<PlayerBullet> playerBullets;
ArrayList<EnemyBullet> enemyBullets;
HeatTrail heatTrail;
EnemyController enemyController;
Timer timer;

void setup() {
  fullScreen();
  timer = new Timer();
  player = new Player();
  playerBullets = new ArrayList<PlayerBullet>();
  enemyBullets = new ArrayList<EnemyBullet>();
  heatTrail = new HeatTrail();
  enemyController = new EnemyController();
}

void draw() { 
  background(255);
  timer.update();
  enemyController.update();
  player.update();

  ArrayList<PlayerBullet> flaggedPlayerBullets = new ArrayList<PlayerBullet>();
  for (PlayerBullet bullet : playerBullets) {
    bullet.update();
    if (bullet.isFlagged()) {
      flaggedPlayerBullets.add(bullet);
    }
  }

  ArrayList<EnemyBullet> flaggedEnemyBullets = new ArrayList<EnemyBullet>();
  for (EnemyBullet bullet : enemyBullets) {
    bullet.update();
    if (bullet.isFlagged()) {
      flaggedEnemyBullets.add(bullet);
    }
  }
  enemyBullets.removeAll(flaggedEnemyBullets);
}

void keyPressed() {
  if (keyCode == 'W' || keyCode == UP)
    player.moveDirection(0, 1);
  if (keyCode == 'S' || keyCode == DOWN)
    player.moveDirection(0, -1);
  if (keyCode == 'D' || keyCode == RIGHT)
    player.moveDirection(1, 0);
  if (keyCode == 'A' || keyCode == LEFT)
    player.moveDirection(-1, 0);
}

void keyReleased() {
  if (keyCode == 'W' || keyCode == UP)
    player.stopDirection(0, 1);
  if (keyCode == 'S' || keyCode == DOWN)
    player.stopDirection(0, -1);
  if (keyCode == 'D' || keyCode == RIGHT)
    player.stopDirection(1, 0);
  if (keyCode == 'A' || keyCode == LEFT)
    player.stopDirection(-1, 0);
}

void mouseClicked() {
  player.shoot();
}
