
float inc = 0.1;
int scale = 10;
int rows;
int cols;

PVector frc;

PVector[] flowfield;

Particle[] particles = new Particle[100];

float zoff = 0;

void setup() {
  size(600, 600);
  background(255);
  rows = floor(height/scale) + 1;
  cols = floor(width/scale) + 1;
  
  flowfield = new PVector[cols*rows];
  
  for( int i=0; i<100; i++){
    particles[i] = new Particle();
  }
}

void draw() {
  background(255);
  float yoff = 0;
  //loadPixels();
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      int index = x + y * cols;
      
      float angle = noise(xoff, yoff, zoff) * TWO_PI;
      PVector vel = PVector.fromAngle(angle);
      vel.setMag(0.75);
      
      flowfield[index] = vel;
      
      xoff += inc;
      
      stroke(0);
      push();
      stroke(0,50);
      strokeWeight(1);
      translate(x * scale, y * scale);
      rotate(vel.heading());
      //line(0, 0, scale, 0);
      
      pop();
      
    }
    yoff += inc;
    zoff += 0.001;
    
    
    
    
  }
  
  for( int i=0; i<100; i++){
      //println("lengtho", flowfield.length);
      particles[i].follow(flowfield);
      particles[i].update();
      particles[i].show();
      particles[i].edges();
  }
  //updatePixels();
  //noLoop();
  println(frameRate);
}
