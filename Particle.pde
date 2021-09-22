public class Particle{
  PVector pos;
  PVector vel;
  PVector acc;
  
  //int maxSpeed = 10;
  
  //Particle(PVector pos, PVector vel, PVector acc){
    Particle(){
     this.pos = new PVector(random(width),random(height));
     this.vel = new PVector(0,0);
     //this.vel = PVector.random2D();
     this.acc = new PVector(0,0);
  }
  
  void update(float maxSpeed){
     this.vel.add(this.acc);
     this.pos.add(this.vel);
     this.vel.limit(maxSpeed);
     //this.vel.mult(0);
     this.acc.mult(0);
     
     //println(" Current speed - ", this.vel); 
  }
  
  void moveParticle(PVector force){
      this.acc.add(force);
  }
  
  void show(){
    stroke(0);
    strokeWeight(4);
    point(this.pos.x, this.pos.y);
  }
  
  void follow(PVector[] field){
    int x = floor(this.pos.x/scale);
    int y = floor(this.pos.y/scale);
    int index = x + y * cols;
    PVector force = field[index];
    this.moveParticle(force);
  }
  
  void edges(){
    if(this.pos.x > width){
      this.pos.x = 0;
    }
    if(this.pos.x < 0){
      this.pos.x = width;
    }
    if(this.pos.y > height){
      this.pos.y = 0;
    }
    if(this.pos.y < 0){
      this.pos.y = height;
    }
  }
}
