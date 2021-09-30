public class SmallPlant{
  PVector loc;
  float plantHeight;
  int stemCount;
  PVector velocity;
  
  
  SmallPlant(PVector loc_, float plantHeight_,int stemCount_, PVector velocity_){
    loc = loc_;
    plantHeight = plantHeight_;
    stemCount = stemCount_;
    velocity = velocity_;
  }
  
  void draw(PVector velocity_){
    velocity = velocity_;
    for(int i = 0; i < stemCount; i++){
      float stemAngle = map(i,0,stemCount-1,PI/4,3*PI/4);
      PVector endPoint = PVector.fromAngle(stemAngle);
      endPoint.setMag(plantHeight);
      //println("Before:",endPoint);
      pushMatrix();
      translate(loc.x, loc.y);
      rotate(PVector.angleBetween(velocity,PVector.fromAngle(0)));
      //println("\nAfter3:", endPoint, velocity_, PVector.angleBetween(velocity,PVector.fromAngle(0)));
      noFill();
      stroke(0, 128, 24);
      strokeWeight(2);  // Thicker
      curve(endPoint.x-10, 0, 0,0,endPoint.x, endPoint.y,endPoint.x-25, 0);
      popMatrix();
      
    }
  }
}
