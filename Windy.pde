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
boolean audioCheck = true;

float inc = 0.1;
int scale = 20;
int rows;
int cols;

int particleCount = 100;

PVector frc;

PVector[] flowfield;

Particle[] particles = new Particle[particleCount];
color particleColor= color(230, 200, 130);
color darkModeColor = color(255);

Background myBackground;
Textlabel backgroundViewLabel;
Button selectDateTimeButton;
Textfield StartTimeTF, StartYearTF, StartDayTF, StartMonthTF, EndTimeTF, EndYearTF, EndMonthTF, EndDayTF;
Textlabel  BeginTL, EndTL, colorPickerLabel, updateLabel;
Numberbox redNumberBox, greenNumberBox, blueNumberBox;
Toggle cameraToggle, audioToggle, microphoneToggle;

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
boolean dateVisible = false;
PImage calendarImage;

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

int startupCheck = 0;

void setup() {
  size(800, 600);
  cp5 = new ControlP5(this);

  setupBackground();
  createUI();

  rows = floor(height/scale) + 1;
  cols = floor(width/scale) + 1;

  flowfield = new PVector[cols*rows];

  for ( int i=0; i<particleCount; i++) {
    particles[i] = new Particle(i, particles);
  }

  fetchData();

  // adding a Wind Speed visualization as a ControlP5 slider
  cp5.addSlider("WindSpeedSlider")
    .setSize(100, 15)
    .setRange(0, 10)
    .setPosition(width/2 -50, 50)
    .setColorValueLabel(0);
}

void fetchData() {
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
}

void draw() {
  //Background for sky
  background(169, 231, 241);

  //Background for sand and plants
  myBackground.draw(PVector.fromAngle(radians(windDirectionArray[primaryIndex])));


  // --- Start draw method for track color --- //
  video.loadPixels();

  // set trackColor to slider values
  trackColor = color(r, g, b);

  // draw ellipse to show selected color
  pushStyle();
  noStroke();
  fill(trackColor);
  ellipse(width*0.34, height*0.901, 16, 16);
  popStyle();

  threshold = 90; // accuracy of pixel to the target color
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
  // --- End draw method for track color --- //

  float yoff = 0;
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
      xoff += inc;
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

    // when mouse is pressed disperse particles at mouseX,mouseY
    if (mousePressed == true) {
      particles[i].clicked(mouseX, mouseY);
    }
    // when any key is pressed disperse particles at tracked color
    if (keyPressed == true) {
      particles[i].pressedSpace(avgX, avgY);
    }
  }

  if (secondaryindex % 100 == 0) {
    if (primaryIndex<windDirectionArray.length-1) {
      primaryIndex = primaryIndex + 1;
    } else {
      primaryIndex = 0;
    }
  }
  secondaryindex = secondaryindex + 1;

  drawCompass(angle, instVel);
  showDate(timeStamps[primaryIndex]);
  drawInfoBox();
  showSourceData();
}

void cameraToggle() {
  if (cameraCheck == false) {
    video.stop(); // enable camera
  } else {
    video.start(); // disable camera
  }
  cameraCheck = !cameraCheck;
}

void microphoneToggle() {
  if (microphoneCheck == false) {
    in.stop();
    //sample.play();
  } else {
    in = new AudioIn(this, 0);
    in.start();
    amp.input(in);
  }
  microphoneCheck = !microphoneCheck;
}

void audioToggle() {
  if (audioCheck == false) {
    if (sample.isPlaying()) {
      sample.stop();
    }
  } else {
    sample.stop();
    sample.play();
  }
  audioCheck = !audioCheck;
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
  if (theEvent.isAssignableFrom(Textfield.class)) {
    if (theEvent.getName() == "StartTime") {
      startHour = theEvent.getStringValue();
      fetchData();
    }
    if (theEvent.getName() == "StartYear") {
      fromDate = theEvent.getStringValue() + "-" + fromDate.split("-", 3)[1] + "-" + fromDate.split("-", 3)[2];
      fetchData();
    }
    if (theEvent.getName() == "StartMonth") {
      fromDate =  fromDate.split("-", 3)[0] + "-" + theEvent.getStringValue() + "-" + fromDate.split("-", 3)[2];
      fetchData();
    }
    if (theEvent.getName() == "StartDay") {
      fromDate =  fromDate.split("-", 3)[0] + "-" + fromDate.split("-", 3)[1] + "-" + theEvent.getStringValue();
      fetchData();
    }// begin date

    if (theEvent.getName() == "EndTime") {
      endHour = theEvent.getStringValue();
      fetchData();
    }
    if (theEvent.getName() == "EndYear") {
      toDate = theEvent.getStringValue() + "-" + toDate.split("-", 3)[1] + "-" + toDate.split("-", 3)[2];
      fetchData();
    }
    if (theEvent.getName() == "EndMonth") {
      toDate =  toDate.split("-", 3)[0] + "-" + theEvent.getStringValue() + "-" + toDate.split("-", 3)[2];
      fetchData();
    }
    if (theEvent.getName() == "EndDay") {
      toDate =  toDate.split("-", 3)[0] + "-" + toDate.split("-", 3)[1] + "-" + theEvent.getStringValue();
      fetchData();
    }
  } else if (theEvent.isAssignableFrom(Button.class)) {
    if (theEvent.getName() == "changeBackground") {
      myBackground.sideView = !myBackground.sideView;
      if (myBackground.sideView) {
        PImage buttonImage = loadImage(myBackground.backgroundImagesName.get(0));//loadImage("water.jpg");
        buttonImage.resize(40, 40);
        theEvent.controller().setImage(buttonImage);
        //cp5.getController("BackgroundView").setLabel("Side View");
        BeginTL.setColor(compassBGColor);
        updateLabel.setColor(compassBGColor);
        EndTL.setColor(compassBGColor);
        EndTimeTF.setColorLabel(compassBGColor);
        EndYearTF.setColorLabel(compassBGColor);
        EndMonthTF.setColorLabel(compassBGColor);
        EndDayTF.setColorLabel(compassBGColor);
        backgroundViewLabel.setColor(compassBGColor);
        colorPickerLabel.setColor(compassBGColor);
        redNumberBox.setColorLabel(compassBGColor);
        greenNumberBox.setColorLabel(compassBGColor);
        blueNumberBox.setColorLabel(compassBGColor);
      } else {
        PImage buttonImage = loadImage(myBackground.backgroundImagesName.get(1));//loadImage("water.jpg");
        buttonImage.resize(40, 40);
        theEvent.controller().setImage(buttonImage);
        BeginTL.setColor(darkModeColor);
        updateLabel.setColor(darkModeColor);
        EndTL.setColor(darkModeColor);
        EndTimeTF.setColorLabel(darkModeColor);
        EndYearTF.setColorLabel(darkModeColor);
        EndMonthTF.setColorLabel(darkModeColor);
        EndDayTF.setColorLabel(darkModeColor);
        backgroundViewLabel.setColor(darkModeColor);
        colorPickerLabel.setColor(darkModeColor);
        redNumberBox.setColorLabel(darkModeColor);
        greenNumberBox.setColorLabel(darkModeColor);
        blueNumberBox.setColorLabel(darkModeColor);
      }
      backgroundViewLabel.setText(!myBackground.sideView?"Front View": "Top View");
      calendarImage =  (myBackground.sideView?  loadImage("blueCal.png") : loadImage("whiteCal.png"));
      calendarImage.resize(30, 30);
      selectDateTimeButton.setImage(null);
      selectDateTimeButton.setImage(calendarImage);
    } else if (theEvent.getName() == "selectDateTime") {
      toggleDateFields();
    } else if (theEvent.getName() == "infoBoxToggle") {
      toggleInfoBox();
    } else if (theEvent.getName() == "switchCamera") {
      if (cameraCheck == false) {
        PImage cameraIcon = loadImage("camera-off.png");
        cameraIcon.resize(30, 30);
        theEvent.controller().setImage(cameraIcon);
      } else {
        PImage cameraIcon = loadImage("camera-on.png");
        cameraIcon.resize(30, 30);
        theEvent.controller().setImage(cameraIcon);
      }
      cameraToggle();
    } else if (theEvent.getName() == "switchMicrophone") {
      if (microphoneCheck == false) {
        PImage microphoneIcon = loadImage("microphone-off.png");
        microphoneIcon.resize(30, 30);
        theEvent.controller().setImage(microphoneIcon);
      } else {
        PImage microphoneIcon = loadImage("microphone-on.png");
        microphoneIcon.resize(30, 30);
        theEvent.controller().setImage(microphoneIcon);
      }
      microphoneToggle();
    } else if (theEvent.getName() == "switchSound") {
      if (audioCheck == false) {
        PImage soundIcon = loadImage("sound-off.png");
        soundIcon.resize(30, 30);
        theEvent.controller().setImage(soundIcon);
      } else {
        PImage soundIcon = loadImage("sound-on.png");
        soundIcon.resize(30, 30);
        theEvent.controller().setImage(soundIcon);
      }
      audioToggle();
    } else if (theEvent.getName() == "locationIcon") {
      if (startupCheck > 0) {
        link("https://goo.gl/maps/eKqbSjEP19dWP1dh9");
      }
      startupCheck++;
    }
  }
}

//Setting Button Image background
void setupBackground() {
  myBackground =  new Background( new PVector(0.0, 0.0));
}

void toggleDateFields() {
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
  cp5.getController("Update").setVisible(dateVisible);
}

//Create UI //
void createUI() {
  fill(255);
  font = createFont("arial", 12);

  amp = new Amplitude(this);
  in = new AudioIn(this, 0);

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
  // color picker label
  colorPickerLabel = cp5.addLabel("PICK COLOR TO TRACK")
    .setPosition(width*0.195, height*0.895)
    .setColor(0)
    ;

  // red
  redNumberBox = cp5.addNumberbox("r")
    .setPosition(width*0.2, height*0.92)
    .setSize(30, 20)
    .setColorLabel(0)
    .setValue(255)
    .setRange(0, 255)
    .setScrollSensitivity(2)
    ;

  // green
  greenNumberBox = cp5.addNumberbox("g")
    .setPosition(width*0.24, height*0.92)
    .setSize(30, 20)
    .setColorLabel(0)
    .setValue(0)
    .setRange(0, 255)
    .setScrollSensitivity(2)
    ;

  // blue
  blueNumberBox = cp5.addNumberbox("b")
    .setPosition(width*0.28, height*0.92)
    .setSize(30, 20)
    .setColorLabel(0)
    .setValue(0)
    .setRange(0, 255)
    .setScrollSensitivity(2)
    ;
  // --- End setup for controls --- //

  /// Interaction Icons
  PImage infoIcon = loadImage("info.png");
  infoIcon.resize(30, 30);
  cp5.addButton("infoBoxToggle")
    .setPosition(width - 90, height - 50)
    .setSize(30, 30)
    .setImage(infoIcon);

  PImage soundIcon = loadImage("sound-on.png");
  soundIcon.resize(30, 30);
  cp5.addButton("switchSound")
    .setPosition(width - 130, height - 50)
    .setSize(30, 30)
    .setImage(soundIcon);

  PImage cameraIcon = loadImage("camera-off.png");
  cameraIcon.resize(30, 30);
  cp5.addButton("switchCamera")
    .setPosition(width - 170, height - 50)
    .setSize(30, 30)
    .setImage(cameraIcon);

  PImage microphoneIcon = loadImage("microphone-off.png");
  microphoneIcon.resize(30, 30);
  cp5.addButton("switchMicrophone")
    .setPosition(width - 210, height - 50)
    .setSize(30, 30)
    .setImage(microphoneIcon);

  PImage locationIcon = loadImage("location.png");
  locationIcon.resize(35, 35);
  cp5.addButton("locationIcon")
    .setPosition(width - 415, height - 100)
    .setSize(35, 35)
    .setImage(locationIcon);

  //Start Date Time Picker//
  PImage buttonImage = loadImage(myBackground.backgroundImagesName.get(0));//loadImage("water.jpg");
  buttonImage.resize(40, 40);
  cp5.addButton("changeBackground")
    .setPosition(20, height - 60)
    .setSize(40, 40)
    .setImage(buttonImage)
    ;

  backgroundViewLabel = cp5.addLabel("BackgroundViewLabel")
    .setPosition(15, height - 70)
    .setColor(compassBGColor)
    .setText(!myBackground.sideView?"Front View": "Top View");

  calendarImage =  (myBackground.sideView?  loadImage("blueCal.png") : loadImage("whiteCal.png"));
  calendarImage.resize(30, 30);
  selectDateTimeButton = cp5.addButton("selectDateTime")
    .setPosition(width -50, 5)
    .setSize(30, 30)
    .setImage(calendarImage);

  StartTimeTF = cp5.addTextfield("StartTime")
    .setFont(font)
    .setPosition(width -50, 40)
    .setSize(30, 30)
    .setColor(color(255))
    .setColorBackground(compassBGColor)
    .setColorActive(color(255, 255, 255))
    .setText(startHour)
    .setAutoClear(false)
    .setLabel("")
    .setVisible(dateVisible)
    .setLabelVisible(false);

  StartYearTF = cp5.addTextfield("StartYear")
    .setFont(font)
    .setPosition(width -100, 40)
    .setSize(40, 30)
    .setText(fromDate.split("-", 3)[0])
    .setColor(color(255))
    .setColorBackground(compassBGColor)
    .setColorActive(color(255, 255, 255))
    .setAutoClear(false)
    .setVisible(dateVisible)
    .setLabel("")
    .setLabelVisible(false);

  StartMonthTF = cp5.addTextfield("StartMonth")
    .setFont(font)
    .setPosition(width -150, 40)
    .setSize(40, 30)
    .setText(fromDate.split("-", 3)[1])
    .setLabel("")
    .setLabelVisible(false)
    .setAutoClear(false)
    .setVisible(dateVisible)
    .setColor(color(255))
    .setColorBackground(compassBGColor)
    .setColorActive(color(255, 255, 255));

  StartDayTF = cp5.addTextfield("StartDay")
    .setFont(font)
    .setPosition(width -200, 40)
    .setSize(30, 30)
    .setText(fromDate.split("-", 3)[2])
    .setLabel("")
    .setLabelVisible(false)
    .setAutoClear(false)
    .setVisible(dateVisible)
    .setColor(color(255))
    .setColorBackground(compassBGColor)
    .setColorActive(color(255, 255, 255));

  BeginTL = cp5.addTextlabel("Begin")
    .setText("Start")
    .setFont(font)
    .setPosition(width - 250, 45)
    .setSize(50, 30)
    .setVisible(dateVisible)
    .setColor(color(compassBGColor));

  updateLabel = cp5.addTextlabel("Update")
    .setText("Press enter to update")
    .setFont(font)
    .setPosition(width - 140, 150)
    .setSize(50, 30)
    .setVisible(dateVisible)
    .setColor(color(compassBGColor));

  EndTimeTF = cp5.addTextfield("EndTime")
    .setFont(font)
    .setPosition(width -50, 100)
    .setSize(30, 30)
    .setColor(color(255))
    .setColorLabel(compassBGColor)
    .setColorBackground(compassBGColor)
    .setColorActive(color(255, 255, 255))
    .setText(endHour)
    .setAutoClear(false)
    .setVisible(dateVisible)
    .setLabel("Time")
    .setLabelVisible(true);

  EndYearTF = cp5.addTextfield("EndYear")
    .setFont(font)
    .setPosition(width -100, 100)
    .setSize(40, 30)
    .setText(toDate.split("-", 3)[0])
    .setColor(color(255))
    .setColorLabel(compassBGColor)
    .setColorBackground(compassBGColor)
    .setColorActive(color(255, 255, 255))
    .setAutoClear(false)
    .setVisible(dateVisible)
    .setLabel("Year")
    .setLabelVisible(true);

  EndMonthTF = cp5.addTextfield("EndMonth")
    .setFont(font)
    .setPosition(width -150, 100)
    .setSize(40, 30)
    .setText(toDate.split("-", 3)[1])
    .setLabel("Month")
    .setAutoClear(false)
    .setVisible(dateVisible)
    .setLabelVisible(true)
    .setColor(color(255))
    .setColorLabel(compassBGColor)
    .setColorBackground(compassBGColor)
    .setColorActive(color(255, 255, 255));

  EndDayTF = cp5.addTextfield("EndDay")
    .setFont(font)
    .setPosition(width -200, 100)
    .setSize(30, 30)
    .setText(toDate.split("-", 3)[2])
    .setLabel("Day")
    .setLabelVisible(true)
    .setVisible(dateVisible)
    .setAutoClear(false)
    .setColor(color(255))
    .setColorBackground(compassBGColor)
    .setColorLabel(compassBGColor)
    .setColorActive(color(255, 255, 255));

  EndTL = cp5.addTextlabel("End")
    .setText("End")
    .setFont(font)
    .setPosition(width - 250, 110)
    .setSize(50, 30)
    .setVisible(dateVisible)
    .setColor(color(compassBGColor));
}

void showSourceData() {
  pushMatrix();
  pushStyle();
  fill(myBackground.sideView?compassBGColor:darkModeColor);
  textAlign(CENTER);
  text(dataSource0, width/2, height*0.92);
  text(dataSource1, width/2, height*0.94);
  text(dataSource2, width/2, height*0.96);
  popStyle();
  popMatrix();
}

void mousePressed() {
}
