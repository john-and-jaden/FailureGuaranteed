public final int GAME_SCENE = 0, TRANSITION_SCENE = 1, DEATH_SCENE = 2;

Player player;
ArrayList<PlayerBullet> playerBullets;
ArrayList<EnemyBullet> enemyBullets;
ArrayList<EffectParticle> effectParticles;
HeatTrail heatTrail;
EnemyController enemyController;
Timer timer;
int scene;
int wave;
float gameTimer;

void setup() {
  size(1600, 800);
  timer = new Timer();
  heatTrail = new HeatTrail();
  player = new Player();
  playerBullets = new ArrayList<PlayerBullet>();
  enemyBullets = new ArrayList<EnemyBullet>();
  effectParticles = new ArrayList<EffectParticle>();
  enemyController = new EnemyController();
  scene = GAME_SCENE;
  wave = 0;
  gameTimer = 0;
}

void draw() {
  timer.update();
  
  switch (scene) {
  case GAME_SCENE:
    game();
    break;
  case TRANSITION_SCENE:
    transition();
    break;
  case DEATH_SCENE:
    death();
    break;
  }
}

public void changeScene(int newScene) {
  scene = newScene;
  
  if (scene == GAME_SCENE) {
    // we gotta clear bullets and effect particles
    playerBullets.clear();
    enemyBullets.clear();
    effectParticles.clear();
    
    // gameTimer set to 0
    gameTimer = 0;
    
    // reset player position and stats
    player.respawn();
    
    // reset the player's heat trail
    heatTrail = new HeatTrail();
    
    // increase the wave count
    wave++;
  }
}

private void game() {
  background(255);
  gameTimer += timer.deltaTime;
  
  ArrayList<EffectParticle> flaggedEffectParticles = new ArrayList<EffectParticle>();
  for (EffectParticle particle : effectParticles) {
    particle.update();
    if (particle.isFlagged()) {
      flaggedEffectParticles.add(particle); 
    }
  }
  effectParticles.removeAll(flaggedEffectParticles);
  
  enemyController.update();
  heatTrail.update();
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

private void transition() {
  background(0);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("Wave " + wave + " Completed!", width/2, height/3);
  textSize(32);
  text("The wave lasted " + gameTimer + " seconds", width/2, height/2);
}

private void death() {
  background(0);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("You have died!", width/2, height/3);
  textSize(32);
  text("You survived " + gameTimer + " seconds", width/2, height/2);
  text("You have " + player.remainingLives + " lives remaining", width/2, 2*height/3);
}

void keyPressed() {
  if (scene == GAME_SCENE) {
    if (keyCode == 'W' || keyCode == UP)
      player.moveDirection(0, 1);
    if (keyCode == 'S' || keyCode == DOWN)
      player.moveDirection(0, -1);
    if (keyCode == 'D' || keyCode == RIGHT)
      player.moveDirection(1, 0);
    if (keyCode == 'A' || keyCode == LEFT)
      player.moveDirection(-1, 0);
  }
}

void keyReleased() {
  if (scene == GAME_SCENE) {
    if (keyCode == 'W' || keyCode == UP)
      player.stopDirection(0, 1);
    if (keyCode == 'S' || keyCode == DOWN)
      player.stopDirection(0, -1);
    if (keyCode == 'D' || keyCode == RIGHT)
      player.stopDirection(1, 0);
    if (keyCode == 'A' || keyCode == LEFT)
      player.stopDirection(-1, 0);
  }
}

void mousePressed() {
  if (scene == GAME_SCENE) {
    player.shoot();
  } else if (scene == TRANSITION_SCENE || scene == DEATH_SCENE) {
    changeScene(GAME_SCENE);
  }
}
