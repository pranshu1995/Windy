import processing.sound.*;
Amplitude amp;
SoundFile sample;
AudioIn in;

Boolean microphoneCheck = false;

float inc = 0.1;
int scale = 20;
int rows;
int cols;

int particleCount = 500;

PVector frc;

PVector[] flowfield;

Particle[] particles = new Particle[particleCount];
color particleColor= color(230, 200, 130);

Background myBackground;

float zoff = 0;

int primaryIndex = 0; // Main array loop variable
int secondaryindex = 1; // Persistency loop variable

String[] timeStamps;
float[] windDirectionArray;
float[] windSpeedArray;
Table windDirecrion, windSpeed;

// Date, time parameters for data retrieval
// Entering inappropriate time will lead to crash
// After reaching end time, code will loop from beginning
String fromDate = "2021-09-20";  // Format: YYYY-MM-DD
String toDate = "2021-09-21";  // Format: YYYY-MM-DD

String startHour = "13";  // Value: 00-23
String endHour = "13";  // Value: 00-23

// Variables for collision
float spring = 1;
float gravity = 0.1;
float friction = -0.9;
// End of variables for collision

void setup() {
  size(800, 600);
  //fullScreen(P2D);
  
  //Background(sand dune) 
  myBackground =  new Background( new PVector(0.0,0.0));
  
  //background(255);
  rows = floor(height/scale) + 1;
  cols = floor(width/scale) + 1;

  flowfield = new PVector[cols*rows];

  for ( int i=0; i<particleCount; i++) {
    particles[i] = new Particle(i, particles);
  }

  // Load Wind Speed data from EIF portal in CSV format
  windDirecrion = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=" + fromDate + "T" + startHour + "%3A00%3A00&rToDate=" + toDate + "T" + endHour + "%3A00%3A00&rFamily=weather&rSensor=IWD", "csv");
  windSpeed = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=" + fromDate + "T" + startHour + "%3A00%3A00&rToDate=" + toDate + "T" + endHour + "%3A00%3A00&rFamily=weather&rSensor=IWS", "csv");

  // Extract data from CSV
  windDirectionArray = new float[windDirecrion.getRowCount()];
  windSpeedArray = new float[windSpeed.getRowCount()];
  timeStamps = new String[windDirecrion.getRowCount()];

  for (int i = 0; i < windDirecrion.getRowCount(); i++) {
    timeStamps[i] = windDirecrion.getString(i, 0);
    windDirectionArray[i] = windDirecrion.getFloat(i, 1);
    windSpeedArray[i] = windSpeed.getFloat(i, 1);
  }
  
  amp = new Amplitude(this);
  in = new AudioIn(this, 0);
  ////in.start();
  //amp.input(in);
  
    // Load and play a soundfile and loop it.
  sample = new SoundFile(this, "desert_wind.mp3");
  sample.loop();
}

void draw() {
  background(169, 231, 241);
  //Background for sand and plants
  myBackground.draw(PVector.fromAngle(radians(windDirectionArray[primaryIndex])));

  float yoff = 0;
  //loadPixels();
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      int index = x + y * cols;

      // determine angle for flow field from data
      float angle = windDirectionArray[primaryIndex];

      // introduce minor deviations in the angle using noise
      float magnitude = 50.0;
      float deviate = angle + (noise(xoff, yoff, zoff) * magnitude);

      // set velocity to angle
      PVector vel = PVector.fromAngle(radians(deviate));

      vel.setMag(1);

      flowfield[index] = vel;
      
      // Background(sand dune) 
      //myBackground.draw(vel);
      xoff += inc;

      stroke(0);
      push();
      stroke(0, 50);
      strokeWeight(1);
      translate(x * scale, y * scale);
      rotate(vel.heading());

   //   line(0, 0, scale, 0); display line
      
      pop();
    }
    yoff += inc;
    zoff += 0.001;
  }
  float instVel = map(windSpeedArray[primaryIndex], 0, 30, 0, 8);
  
  float volume = map(instVel, 0, 8, 0, 1);
  sample.amp(volume);
   
    
  for (int i=0; i<particleCount; i++) {
    particles[i].follow(flowfield);
    particles[i].collide();
    float microphoneInput = map(amp.analyze(), 0, 1, 0, 50);
    particles[i].update(instVel, microphoneInput);
    particles[i].show();
    particles[i].edges();

    // if mouse is pressed call clicked function
    if (mousePressed == true) {
      particles[i].clicked(mouseX,mouseY);
    }
  }

  
  
  //updatePixels();
  //noLoop();
  //println(frameRate);

  if (secondaryindex % 100 == 0) {
    if (primaryIndex<windDirectionArray.length-1) {
      primaryIndex = primaryIndex + 1;
    } else {
      primaryIndex = 0;
    }
  }
  secondaryindex = secondaryindex + 1;

  //show area for mouse interaction
  //mouseArea();
}

void mouseArea() {
  pushStyle();
  stroke(255, 0, 0);
  strokeWeight(2);
  point(mouseX, mouseY);
  rectMode(CENTER);
  fill(255, 0, 0, 50);
  ellipse(mouseX, mouseY, 100, 100);
  popStyle();
}

void mousePressed() {
  microphoneToggle();

}

void microphoneToggle(){
  if(microphoneCheck == true){
    in.stop();
    sample.play();
  }
  else{
    in = new AudioIn(this, 0);
    in.start();
    amp.input(in);
    sample.pause();
  }  
  microphoneCheck = !microphoneCheck;
  println("newVal ", microphoneCheck);
}
