
float inc = 0.1;
int scale = 10;
int rows;
int cols;

void setup() {
  size(600, 600);
  pixelDensity(1);
  rows = height/scale;
  cols = width/scale;
}

void draw() {
  float yoff = 0;
  //loadPixels();
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      int index = (x + y * width) * 4;
      float r = noise(xoff, yoff) * 255;
      
      xoff += inc;
      
      fill(r);
      rect(scale*x, scale*y, scale, scale);
    }
    yoff += inc;
  }
  //updatePixels();
  //noLoop();
  println(frameRate);
}
