PFont mono;
color compassColor = color(1, 116, 217);
color compassBGColor = color(1, 45, 90);

boolean infoBoxVisible = true;

String toolTipText = "Interaction Guide: \n\n • CLICK on screen to disperse particles \n • Use MICROPHONE to add to wind speed with voice \n • Set tracking color by inputing RGB values and Use CAMERA to follow the tracking color \n • Press SPACE to disperse particles along with color tracking";

void setting_up(){
  // Code to be put in setup():
  // add a Wind Speed visualization as a ControlP5 slider
  cp5.addSlider("WindSpeedSlider")
       .setSize(100,15)
       .setRange(0,10)
       .setPosition(width/2 -50, 50)
       .setColorValueLabel(0);
       
  // Code to put in draw():
  // Code to draw compass- to be put at the end of draw() function
  // as drawCompass(angle, instVel);
  drawCompass(10, 10);
  showDate(timeStamps[primaryIndex]);

}

int drawCompass(float angle, float mag){
  angle= radians(angle);
  textAlign(CENTER);
  
  strokeWeight(1);
  stroke(compassColor);
  pushMatrix();
  translate(width/2, 30);
  rotate(angle);
  fill(compassBGColor);
  ellipse(0, 0, 30, 30);
  fill(compassColor);
  line(- 15, 0, 15, 0);
  triangle(14, 0, -8, 8, -8, -8);
  popMatrix();

  //reposition the Label for controller 'slider'
  cp5.getController("WindSpeedSlider").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("WindSpeedSlider").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("WindSpeedSlider").setColorCaptionLabel(myBackground.sideView? compassBGColor: darkModeColor);
  cp5.getController("WindSpeedSlider").setCaptionLabel("Wind Speed");
  cp5.getController("WindSpeedSlider").setValue(mag);
  cp5.getController("WindSpeedSlider").setColorValue(myBackground.sideView? compassBGColor: darkModeColor);

    
  return 0;

}

void showDate(String timeStamp){
  fill(myBackground.sideView? compassBGColor: darkModeColor);
  text(timeStamp, width - 120, 27);
  
}

void toggleInfoBox(){
 infoBoxVisible = !infoBoxVisible;
}

void drawInfoBox(){
  if(infoBoxVisible){
    fill(200,200);
    stroke(20,200);
    rect(width - 200, height - 240, 190, 180, 25);
    
    fill(1, 45, 90);
    textAlign(LEFT);
    text(toolTipText, width - 190, height - 230, 170, 160);
  }
}
