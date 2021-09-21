
float inc = 0.1;
int scale = 10;
int rows;
int cols;

float zoff = 0;

void setup() {
  size(600, 600);
  pixelDensity(1);
  rows = height/scale;
  cols = width/scale;
}

void draw() {
  background(255);
  //randomSeed(50);
  float yoff = 0;
  //loadPixels();
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      int index = (x + y * width) * 4;
      float angle = noise(xoff, yoff, zoff) * TWO_PI;
      PVector vel = PVector.fromAngle(angle);
      
      xoff += inc;
      
      stroke(0);
      
      push();
      
      translate(x * scale, y * scale);
      rotate(vel.heading());
      line(0, 0, scale, 0);
      
      pop();
      
      //fill(r);
      //rect(scale*x, scale*y, scale, scale);
    }
    yoff += inc;
    zoff += 0.001;
    
  }
  //updatePixels();
  //noLoop();
  println(frameRate);
}
