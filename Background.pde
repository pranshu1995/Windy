
 color firstDesertColor = color(255, 252, 161);
 color secondDesertColor = color(255, 242, 150);
 color thirdDesertColor = color(255, 232, 139);
 public class Background{
    PVector velocity;
     ParticleSystem ps;
     ParticleSystem ps1;
     ParticleSystem ps2;
     ParticleSystem ps3;
     
     ParticleSystem ds1;
     ParticleSystem ds2;
     ParticleSystem ds3;
     ParticleSystem ds4;
     SmallPlant smallPlant;
     SmallPlant smallPlant2;
     SmallPlant smallPlant3;
     SmallPlant smallPlant4;
     
      Background(PVector vel){
      this.velocity = vel;  
      PImage img = loadImage("texture.png");
      ps = new ParticleSystem(0, new PVector(3*width/4, height/2+20), img,firstDesertColor);
      ps1 = new ParticleSystem(0, new PVector(3*width/4+20, height/2), img,firstDesertColor);
      ps2 = new ParticleSystem(0, new PVector(3*width/4+70, height/2-20), img,firstDesertColor);
      ps3 = new ParticleSystem(0, new PVector(3*width/4+30, height/2-10), img,firstDesertColor);
      
      ds1 = new ParticleSystem(0, new PVector(width/2-80,height/2+90), img,secondDesertColor);
      ds2 = new ParticleSystem(0, new PVector(width/2-50,height/2+40), img,secondDesertColor);
      ds3 = new ParticleSystem(0, new PVector(width/2-50,height/2+20), img,secondDesertColor);
      ds4 = new ParticleSystem(0, new PVector(width/2-40,height/2+60), img,secondDesertColor);
      
      smallPlant = new SmallPlant(new PVector(0, 0),100,8,velocity);
      smallPlant2 = new SmallPlant(new PVector(width/20, 9*height/10),80,8,velocity);
      smallPlant3 = new SmallPlant(new PVector(width/30, 8*height/10),60,8,velocity);
      smallPlant4 = new SmallPlant(new PVector(width/8, 7*height/10),50,8,velocity);
    }
    
    void draw(PVector vel){
      this.velocity = vel;
      noStroke();
      fill(255, 243, 77);
      ellipse(100,100,100,100);
      fill(255);
     
      drawDeserts();
      fill(255);
      smallPlant.draw(vel);
      smallPlant2.draw(vel);
      smallPlant3.draw(vel);
      smallPlant4.draw(vel);
      // Calculate a "wind" force based on mouse horizontal position
      //background(0);
    float dx = map(velocity.x, -1, 1, -0.2, 0.2);
    float dy = map(velocity.y, -1, 1, -0.2, 0.2);
    PVector wind = new PVector(dx, dy);
    println("wind",wind);
    ps.applyForce(wind);
    ps.run();
    ps1.applyForce(wind);
    ps1.run();
    ps2.applyForce(wind);
    ps2.run();
    ps3.applyForce(wind);
    ps3.run();
    
    ds1.applyForce(wind);
    ds1.run();
    ds2.applyForce(wind);
    ds2.run();
    ds3.applyForce(wind);
    ds3.run();
    ds4.applyForce(wind);
    ds4.run();
    for (int i = 0; i < 1; i++) {
      ps.addParticle();
      ps1.addParticle();
      ps2.addParticle();
      ps3.addParticle();
      
      ds1.addParticle();
      ds2.addParticle();
      ds3.addParticle();
      ds4.addParticle();
      }
    }
    
    
   void drawDeserts(){ 
     
     fill(thirdDesertColor);
     noStroke();
     rect(0,height - height/3, width, height/3);
     
     fill(secondDesertColor);
     noStroke();
     beginShape();
     curveVertex(0,3*height/2);
     curveVertex(0,height);
     curveVertex(width/2,height/2);
     curveVertex(width,3*height/4);
     curveVertex(width,height);
     curveVertex(width,3*height/2);
     endShape();
     fill(255);
     
     fill(firstDesertColor);
     noStroke();
     beginShape();
     curveVertex(0,3*height/2);
     curveVertex(0,height);
     curveVertex(3*width/4,height/2);
     curveVertex(width,height/2);
     curveVertex(width,height);
     curveVertex(width,3*height/2);
     endShape();  
 }
}
