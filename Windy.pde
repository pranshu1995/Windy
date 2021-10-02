import controlP5.*;
import processing.video.*;
import processing.sound.*;
Amplitude amp;
SoundFile sample;
AudioIn in;

// if camera not working change cameraInput to one of the cameras listed in the console.
int cameraInput = 0;

boolean microphoneCheck = false;
boolean cameraCheck = false;
boolean audioCheck = false;

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
PFont font;
boolean dateVisible = true;

// Variables for collision
float spring = 1;
float gravity = 0.1;
float friction = -0.9;
// End of variables for collision

// --- Start global variables for color tracking  --- //
Capture video;
color trackColor;
float threshold = 25;
int r, g, b;
// --- End global variables for color tracking    --- //

// --- Start global variables for controls  --- //
ControlP5 cp5;
// --- End global variables for controls  --- //

String dataSource0 = ("Data source:");
String dataSource1 = ("Wind Speed and Wind Direction ");
String dataSource2 = ("measured at UTS Building 11.");

void setup() {
  size(800, 600);
  cp5 = new ControlP5(this);

  
  setupBackground();
  createUI();
  
  //background(255);
  rows = floor(height/scale) + 1;
  cols = floor(width/scale) + 1;
  
  flowfield = new PVector[cols*rows];

  for ( int i=0; i<particleCount; i++) {
    particles[i] = new Particle(i, particles);
  }
  fetchData();
  PImage calendarImage = loadImage("calendar.png");
  calendarImage.resize(30, 30);
  cp5.addButton("selectDateTime")
    .setValue(50)
    .setPosition(width -50, 5)
    .setSize(30, 30)
    .setImage(calendarImage);
    
  // adding a Wind Speed visualization as a ControlP5 slider
  cp5.addSlider("WindSpeedSlider")
       .setSize(100,15)
       .setRange(0,10)
       .setPosition(width/2 -50, 50)
       .setColorValueLabel(0);
}

void fetchData() {
  // Load Wind Speed data from EIF portal in CSV format
  //println("Fetching");
  windDirecrion = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=" + fromDate + "T" + startHour + "%3A00%3A00&rToDate=" + toDate + "T" + endHour + "%3A00%3A00&rFamily=weather&rSensor=IWD", "csv");
  windSpeed = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=" + fromDate + "T" + startHour + "%3A00%3A00&rToDate=" + toDate + "T" + endHour + "%3A00%3A00&rFamily=weather&rSensor=IWS", "csv");
  //println("Fetched");
  // Extract data from CSV
  windDirectionArray = new float[windDirecrion.getRowCount()];
  windSpeedArray = new float[windSpeed.getRowCount()];
  timeStamps = new String[windDirecrion.getRowCount()];

  for (int i = 0; i < windDirecrion.getRowCount(); i++) {
    timeStamps[i] = windDirecrion.getString(i, 0);
    windDirectionArray[i] = windDirecrion.getFloat(i, 1);
    windSpeedArray[i] = windSpeed.getFloat(i, 1);
  }

}

void draw() {
  background(169, 231, 241);
  //Background for sand and plants
  myBackground.draw(PVector.fromAngle(radians(windDirectionArray[primaryIndex])));
  // --- Start draw method for track color --- //
  video.loadPixels();
  //imageMode(CORNER);

  showSourceData();

  // set trackColor to slider values
  trackColor = color(r, g, b);

  // draw ellipse to show selected color
  pushStyle();
  noStroke();
  fill(trackColor);
  ellipse(width*0.34, height*0.901, 16, 16);
  popStyle();

  threshold = 90;
  float avgX = 0;
  float avgY = 0;
  int count = 0;
  
  float angle= 0;
  

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
      angle = windDirectionArray[primaryIndex];

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


  drawCompass(angle, instVel);
}
///////////////// end of draw function ////////


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
    video.start();
  } else {
    // enable camera
    video.stop();
  }
  cameraCheck = !cameraCheck;
  //println("camera is", cameraCheck);
}

void microphoneToggle() {
  if (microphoneCheck == true) {
    in.stop();
    //sample.play();
  } else {
    in = new AudioIn(this, 0);
    in.start();
    amp.input(in);
    //sample.pause();
  }
  microphoneCheck = !microphoneCheck;
  //println("newVal ", microphoneCheck);
}

void audioToggle() {
  if (audioCheck == false) {
    if (sample.isPlaying()) {
      sample.pause();
    }
  } else {
    sample.play();
  }
  audioCheck = !audioCheck;
  //println("mic check", microphoneCheck);
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

//Date Time Picker//
void controlEvent(ControlEvent theEvent) {     
     if(theEvent.isAssignableFrom(Textfield.class)){
       if(theEvent.getName() == "StartTime"){
         startHour = theEvent.getStringValue();
         cp5.get(Textfield.class,"StartTime").setValue(startHour);
         //cp5.get(Textfield.class,"StartTime").submit();
         fetchData();
       }
       if(theEvent.getName() == "StartYear"){
         (fromDate.split("-",3)[0]) = theEvent.getStringValue();
         fetchData();
       }
       if(theEvent.getName() == "StartMonth"){
         (fromDate.split("-",3)[1]) = theEvent.getStringValue();
         fetchData();
       }
       if(theEvent.getName() == "StartDay"){
         (fromDate.split("-",3)[2]) = theEvent.getStringValue();
         fetchData();
       }// begin date
       
        if(theEvent.getName() == "EndTime"){
         endHour = theEvent.getStringValue();
         fetchData();
       }
       if(theEvent.getName() == "EndYear"){
         (toDate.split("-",3)[0]) = theEvent.getStringValue();
         fetchData();
       }
       if(theEvent.getName() == "EndMonth"){
         (toDate.split("-",3)[1]) = theEvent.getStringValue();
         fetchData();
       }
       if(theEvent.getName() == "EndDay"){
         (toDate.split("-",3)[2]) = theEvent.getStringValue();
         fetchData();
       }
     }else if(theEvent.isAssignableFrom(Button.class)){
       if(theEvent.getName() == "changeBackground"){
         myBackground.sideView = !myBackground.sideView;
         if(myBackground.sideView) {
           PImage buttonImage = loadImage(myBackground.backgroundImagesName.get(0));//loadImage("water.jpg");
           buttonImage.resize(40,40);
           theEvent.controller().setImage(buttonImage);
         } else {
           PImage buttonImage = loadImage(myBackground.backgroundImagesName.get(1));//loadImage("water.jpg");
           buttonImage.resize(40,40);
           theEvent.controller().setImage(buttonImage);
         }
       }else if(theEvent.getName() == "selectDateTime"){
         toggleDateFields();
       }
     }
}

//Setting Button Image background
void setupBackground() {
  myBackground =  new Background( new PVector(0.0, 0.0));
  cp5 = new ControlP5(this);
  font = createFont("arial", 20);
  PImage buttonImage = loadImage(myBackground.backgroundImagesName.get(0));//loadImage("water.jpg");
  buttonImage.resize(40, 40);
  cp5.addButton("changeBackground")
      .setValue(128)
      .setPosition(20,height - 50)
      .setSize(40,40)
      .setImage(buttonImage);
}
void toggleDateFields(){
  dateVisible = !dateVisible;
  cp5.getController("StartTime").setVisible(dateVisible);
  cp5.getController("StartYear").setVisible(dateVisible);
  cp5.getController("StartMonth").setVisible(dateVisible);
  cp5.getController("StartDay").setVisible(dateVisible);
  cp5.getController("Begin").setVisible(dateVisible);
  cp5.getController("EndTime").setVisible(dateVisible);
  cp5.getController("EndYear").setVisible(dateVisible);
  cp5.getController("EndMonth").setVisible(dateVisible);
  cp5.getController("EndDay").setVisible(dateVisible);
  cp5.getController("End").setVisible(dateVisible);
}

//Create UI //
void createUI(){
  fill(255);
  font = createFont("arial",12);

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
    .setPosition(width*0.7, height*0.92)
    .setSize(50, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .setLabel("Toggle camera")
    .setColorLabel(0)
    ;

  // audio control
  cp5.addToggle("audioToggle")
    .setPosition(width*0.9, height*0.92)
    .setSize(50, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .setLabel("Toggle audio")
    .setColorLabel(0)
    ;

  // microphone control
  cp5.addToggle("microphoneToggle")
    .setPosition(width*0.8, height*0.92)
    .setSize(50, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .setLabel("Toggle microphone")
    .setColorLabel(0)
    ;

  // color picker label
  cp5.addLabel("PICK COLOR TO TRACK")
    .setPosition(width*0.195, height*0.895)
    .setColor(0)
    ;

  // red
  cp5.addNumberbox("r")
    .setPosition(width*0.2, height*0.92)
    .setSize(30, 20)
    .setColorLabel(0)
    .setValue(255)
    .setRange(0, 255)
    .setScrollSensitivity(2)
    ;

  // g
  cp5.addNumberbox("g")
    .setPosition(width*0.24, height*0.92)
    .setSize(30, 20)
    .setColorLabel(0)
    .setValue(0)
    .setRange(0, 255)
    .setScrollSensitivity(2)
    ;

  // b
  cp5.addNumberbox("b")
    .setPosition(width*0.28, height*0.92)
    .setSize(30, 20)
    .setColorLabel(0)
    .setValue(0)
    .setRange(0, 255)
    .setScrollSensitivity(2)
    ;

  // --- End setup for controls --- //
  
  //Start Date Time Picker//
  cp5.addTextfield("StartTime")
    .setFont(font)
    .setPosition(width -50, 40)
    .setSize(30, 30)
    .setColor(color(255))
    .setText(startHour)
    .setAutoClear(false)
    .setLabel("")
    .setVisible(dateVisible)
    .setLabelVisible(false);

  cp5.addTextfield("StartYear")
    .setFont(font)
    .setPosition(width -100, 40)
    .setSize(40, 30)
    .setText(fromDate.split("-", 3)[0])
    .setColor(color(255))
    .setAutoClear(false)
    .setVisible(dateVisible)
    .setLabel("")
    .setLabelVisible(false);

  cp5.addTextfield("StartMonth")
    .setFont(font)
    .setPosition(width -150, 40)
    .setSize(40, 30)
    .setText(fromDate.split("-", 3)[1])
    .setLabel("")
    .setLabelVisible(false)
    .setAutoClear(false)
    .setVisible(dateVisible)
    .setColor(color(255));

  cp5.addTextfield("StartDay")
    .setFont(font)
    .setPosition(width -200, 40)
    .setSize(30, 30)
    .setText(fromDate.split("-", 3)[2])
    .setLabel("")
    .setLabelVisible(false)
    .setAutoClear(false)
    .setVisible(dateVisible)
    .setColor(color(255));

  cp5.addTextlabel("Begin")
    .setText("Start")
    .setFont(font)
    .setPosition(width - 250, 45)
    .setSize(50, 30)
    .setVisible(dateVisible)
    .setColor(color(255));

  cp5.addTextfield("EndTime")
    .setFont(font)
    .setPosition(width -50, 100)
    .setSize(30, 30)
    .setColor(color(255))
    .setText(endHour)
    .setAutoClear(false)
    .setVisible(dateVisible)
    .setLabel("Time")
    .setLabelVisible(true);

  cp5.addTextfield("EndYear")
    .setFont(font)
    .setPosition(width -100, 100)
    .setSize(40, 30)
    .setText(toDate.split("-", 3)[0])
    .setColor(color(255))
    .setAutoClear(false)
    .setVisible(dateVisible)
    .setLabel("Year")
    .setLabelVisible(true);

  cp5.addTextfield("EndMonth")
    .setFont(font)
    .setPosition(width -150, 100)
    .setSize(40, 30)
    .setText(toDate.split("-", 3)[1])
    .setLabel("Month")
    .setAutoClear(false)
    .setVisible(dateVisible)
    .setLabelVisible(true)
    .setColor(color(255));

  cp5.addTextfield("EndDay")
    .setFont(font)
    .setPosition(width -200, 100)
    .setSize(30, 30)
    .setText(toDate.split("-", 3)[2])
    .setLabel("Day")
    .setLabelVisible(true)
    .setVisible(dateVisible)
    .setAutoClear(false)
    .setColor(color(255));

  cp5.addTextlabel("End")
    .setText("End")
    .setFont(font)
    .setPosition(width - 250,110)
    .setSize(50,30)
    .setVisible(dateVisible)
    .setColor(color(255));      
}

void showSourceData() {
  pushMatrix();
  pushStyle();
  fill(0);
  textAlign(CENTER);
  text(dataSource0,width/2,height*0.94);
  text(dataSource1,width/2,height*0.96);
  text(dataSource2,width/2,height*0.98);
  popStyle();
  popMatrix();
}
