PFont mono;
color compassColor = color(1, 116, 217);
color compassBGColor = color(1, 45, 90);

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
  cp5.getController("WindSpeedSlider").setColorCaptionLabel(0);
  cp5.getController("WindSpeedSlider").setCaptionLabel("Wind Speed");
  cp5.getController("WindSpeedSlider").setValue(mag);
    
  return 0;

}

void showDate(String timeStamp){
  fill(0);
  text(timeStamp, width - 120, 27);
  
}
