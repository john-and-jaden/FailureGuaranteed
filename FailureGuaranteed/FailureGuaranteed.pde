void setup() {
  fullScreen();
}

void draw() {
  background(155);
  fill(random(255), random(255), random(255));
  ellipse(random(width), random(height), 50, 50);
}
