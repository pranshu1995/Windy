
float inc = 0.1;
int scale = 20;
int rows;
int cols;

PVector frc;

PVector[] flowfield;

Particle[] particles = new Particle[500];

float zoff = 0;

int primaryIndex = 0; // Main array loop variable
int secondaryindex = 1; // Persistency loop variable

String[] timeStamps;
float[] windDirectionArray;
Table windDirecrion;

// Date, time parameters for data retrieval
// Entering inappropriate time will lead to crash
// After reaching end time, code will loop from beginning
String fromDate = "2021-09-20";  // Format: YYYY-MM-DD
String toDate = "2021-09-21";  // Format: YYYY-MM-DD

String startHour = "13";  // Value: 00-23
String endHour = "13";  // Value: 00-23

void setup() {
  size(600, 600);
  //background(255);
  rows = floor(height/scale) + 1;
  cols = floor(width/scale) + 1;
  
  flowfield = new PVector[cols*rows];
  
  for( int i=0; i<500; i++){
    particles[i] = new Particle();
  }
  
  // Load Wind Speed data from EIF portal in CSV format
  windDirecrion = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=" + fromDate + "T" + startHour + "%3A00%3A00&rToDate=" + toDate + "T" + endHour + "%3A00%3A00&rFamily=weather&rSensor=WD", "csv");

  // Extract data from CSV
  windDirectionArray = new float[windDirecrion.getRowCount()];
  timeStamps = new String[windDirecrion.getRowCount()];
  
  for (int i = 0; i < windDirecrion.getRowCount(); i++){
    timeStamps[i] = windDirecrion.getString(i,0);
    windDirectionArray[i] = windDirecrion.getFloat(i,1);
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
      
      //float angle = noise(xoff, yoff, zoff) * TWO_PI;
      float angle = windDirectionArray[primaryIndex];
      
      PVector vel = PVector.fromAngle(radians(angle));
      vel.setMag(0.1);
      
      flowfield[index] = vel;
      
      xoff += inc;
      
      stroke(0);
      push();
      stroke(0,50);
      strokeWeight(1);
      translate(x * scale, y * scale);
      rotate(vel.heading());
      line(0, 0, scale, 0);
      
      pop();
      
    }
    yoff += inc;
    zoff += 0.001;
    
  }
  
  for( int i=0; i<500; i++){
      //println("lengtho", flowfield.length);
      particles[i].follow(flowfield);
      particles[i].update();
      particles[i].show();
      particles[i].edges();
  }
  //updatePixels();
  //noLoop();
  //println(frameRate);
  
    if(secondaryindex % 100 == 0){
    if(primaryIndex<windDirectionArray.length-1){
       primaryIndex = primaryIndex + 1;
    }
    else{
       primaryIndex = 0;
    }
  }
  secondaryindex = secondaryindex + 1;
  
  
  
}
