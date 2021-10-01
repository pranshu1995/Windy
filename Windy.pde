import controlP5.*;
import processing.video.*;
import processing.sound.*;
Amplitude amp;
SoundFile sample;
AudioIn in;

// if camera not working change cameraInput to one of the cameras listed in the console.
int cameraInput = 2;

boolean microphoneCheck = false;
boolean cameraCheck = false;

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

// --- Start global variables for color tracking  --- //
Capture video;
color trackColor;
float threshold = 25;
// --- End global variables for color tracking    --- //

// --- Start global variables for controls  --- //
ControlP5 cp5;
// --- End global variables for controls  --- //


void setup() {
  size(800, 600);

  //Background(sand dune)
  myBackground =  new Background( new PVector(0.0, 0.0));

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

  // --- Start setup for color tracking  --- //
  String[] cameras = Capture.list();
  println("Choose a camera from the list below:");
  printArray(cameras);
  try {
    video = new Capture(this, width, height, cameras[cameraInput]);
    //video.start();
  }
  catch (ArrayIndexOutOfBoundsException e) {
    e.printStackTrace();
    println("Choose a different camera from the list below:");
    printArray(cameras);
  }
  trackColor = color(255, 0, 0);    // red
  // --- End setup for color tracking   --- //

  // --- Start setup for controls --- //
  cp5 = new ControlP5(this);

  // camera control
  cp5.addToggle("cameraToggle")
    .setPosition(600, 550)
    .setSize(50, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .setLabel("Toggle camera")
    .setColorLabel(0)
    ;

  // microphone control
  cp5.addToggle("microphoneToggle")
    .setPosition(680, 550)
    .setSize(50, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .setLabel("Toggle microphone")
    .setColorLabel(0)
    ;

  // --- End setup for controls --- //
}

void draw() {
  background(169, 231, 241);
  //Background for sand and plants
  myBackground.draw(PVector.fromAngle(radians(windDirectionArray[primaryIndex])));

  // --- Start draw method for track color --- //
  video.loadPixels();
  imageMode(CORNER);
  //image(video, 0, height/4, width/4, height/4); // show video capture

  threshold = 90;
  float avgX = 0;
  float avgY = 0;
  int count = 0;

  // loop through all pixels within video capture
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      int loc = x + y * video.width;

      // determine current color
      color currentColor = video.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);

      // calculate distance between pixels
      float d = distSq(r1, g1, b1, r2, g2, b2);

      if (d < threshold*threshold) {
        //stroke(255);
        //strokeWeight(1);
        //point(x, y);
        avgX += x;
        avgY += y;
        count ++;
      }
    }
  }
  if (count > 0) {
    avgX = avgX / count;
    avgY = avgY / count;
    // Draw a circle at the tracked pixel same color
    pushStyle();
    fill(trackColor);
    noStroke();
    ellipse(avgX, avgY, 10, 10);
    popStyle();
  }
  //println(avgX, avgY);
  // --- End draw method for track color --- //

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
      particles[i].clicked(mouseX, mouseY);
    }

    if (keyPressed == true) {
      particles[i].pressedSpace(avgX, avgY);
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
  //microphoneToggle();
}

void cameraToggle() {
  if (cameraCheck == true) {
    // disable camera
    video.stop();
  } else {
    // enable camera
    video.start();
  }
  cameraCheck = !cameraCheck;
  //println("camera is", cameraCheck);
}

void microphoneToggle() {
  if (microphoneCheck == true) {
    in.stop();
    sample.play();
  } else {
    in = new AudioIn(this, 0);
    in.start();
    amp.input(in);
    sample.pause();
  }
  microphoneCheck = !microphoneCheck;
  //println("newVal ", microphoneCheck);
}

// --- Start color tracking helper functions   --- //
// whenever there is a new video frame, read video
void captureEvent(Capture video) {
  video.read();
}

// calculate distance between colors
float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}
// --- End color tracking helper functions   --- //
