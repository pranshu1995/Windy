
 color firstDesertColor = color(255, 252, 161);
 color secondDesertColor = color(255, 242, 150);
 color thirdDesertColor = color(255, 232, 139);

 color topViewDesertColor = color(236, 141, 91);
 int numParticleSystems = 20;
 public class Background{
    PVector velocity;
    PImage desert_PIBY4;
    PFont Font;
    ArrayList<ParticleSystem> particleSystems; 
    ArrayList<String> backgroundImagesName;
    ArrayList<PImage> backgroundImages;
    int currentBackgroundImageIndex;
    boolean sideView;
    
     ParticleSystem ps, ps1, ps2, ps3, ps4, ps5;
     
     ParticleSystem ds1;
     ParticleSystem ds2;
     ParticleSystem ds3;
     ParticleSystem ds4;

     SmallPlant smallPlant2;
     SmallPlant smallPlant3;
     SmallPlant smallPlant4;
     SmallPlant smallPlant5;
     SmallPlant smallPlant6;
     SmallPlant smallPlant7;
     
      Background(PVector vel){
      Font = createFont("Helvetica-Bold", 30);
      this.velocity = vel;  
      sideView = true;

      particleSystems = new ArrayList<ParticleSystem>();
      
      PImage img = loadImage("texture.png");
      ps = new ParticleSystem(0, new PVector(3*width/4+75, height/2-38), img,firstDesertColor);
      ps1 = new ParticleSystem(0, new PVector(3*width/4+100, height/2-43), img,firstDesertColor);
      ps2 = new ParticleSystem(0, new PVector(3*width/4-40, height/2-18), img,firstDesertColor);
      ps3 = new ParticleSystem(0, new PVector(3*width/4-25, height/2-10), img,firstDesertColor);
      ps4 = new ParticleSystem(0, new PVector(3*width/4+40, height/2-40), img,firstDesertColor);
      ps5 = new ParticleSystem(0, new PVector(3*width/4-70, height/2+5), img,firstDesertColor);
      
      ds1 = new ParticleSystem(0, new PVector(width/2-100,height/2+15), img,secondDesertColor);
      ds2 = new ParticleSystem(0, new PVector(width/2-125,height/2+30), img,secondDesertColor);
      ds3 = new ParticleSystem(0, new PVector(width/2-80,height/2+5), img,secondDesertColor);
      ds4 = new ParticleSystem(0, new PVector(width/2-130,height/2+40), img,secondDesertColor);
      for(int i = 0; i< numParticleSystems; i++){
        particleSystems.add(new ParticleSystem(0, new PVector(random(0,width), random(0,height)), img,topViewDesertColor));
      }
      currentBackgroundImageIndex=0;
      backgroundImagesName = new ArrayList<String>();
      backgroundImagesName.add("sand-texture_PI4.jpg");
      backgroundImagesName.add("sideViewImage.png");
      backgroundImagesName.add("water.jpg");
      
      backgroundImages = new ArrayList<PImage>();
      backgroundImages.add(loadImage("sand-texture_PI4.jpg"));
      backgroundImagesName.add("sideViewImage.png");
      backgroundImages.add(loadImage("water.jpg"));
      backgroundImages.get(0).resize(1600,1600);
      backgroundImages.get(1).resize(1600,1600);
      
     // smallPlant2 = new SmallPlant(new PVector(width/20, 9*height/10),80,8,velocity);
      smallPlant3 = new SmallPlant(new PVector(width/10+30, 8*height/10),60,6,velocity);
      smallPlant4 = new SmallPlant(new PVector(width/8, 7*height/10),50,8,velocity);
      smallPlant5 = new SmallPlant(new PVector(width/6+50, 7*height/10),30,5,velocity);
      smallPlant6 = new SmallPlant(new PVector(3*width/4, 8*height/10),120,8,velocity);
      smallPlant7 = new SmallPlant(new PVector(2*width/4, 7*height/10),100,10,velocity);
    }
    
    void draw(PVector vel){
      if(!sideView){
        fill(51, 102, 255);
        //textFont(Font);
        float angle = PVector.angleBetween(vel,PVector.fromAngle(0));
        push();
        translate(width/2, height/2);
        if(currentBackgroundImageIndex == 0){
          rotate(vel.heading()+PI/4);
        } else {
          rotate(vel.heading());
        }
        image(backgroundImages.get(currentBackgroundImageIndex),-width,-height);
        pop();
        this.velocity = vel;
        this.velocity.setMag(2);
        float dx = map(velocity.x, -1, 1, -0.2, 0.2);
        float dy = map(velocity.y, -1, 1, -0.2, 0.2);
        if(currentBackgroundImageIndex == 0){
          PVector wind = new PVector(dx, dy);
          for(int i = 0; i< numParticleSystems; i++){
            ParticleSystem ps = particleSystems.get(i);
            ps.applyForce(wind);
            ps.run();
            ps.addParticle();
          }
        }
      } else {
      
      this.velocity = vel;
      noStroke();
      fill(255, 243, 77);
      ellipse(100,100,100,100);
      fill(255);
     
      drawDeserts();
      fill(255);
      //smallPlant2.draw(vel);
      smallPlant3.draw(vel);
      smallPlant4.draw(vel);
      smallPlant5.draw(vel);
      smallPlant6.draw(vel);
      smallPlant7.draw(vel);
      // Calculate a "wind" force based on mouse horizontal position
      //background(0);
      float dx = map(velocity.x, -1, 1, -0.2, 0.2);
      float dy = map(velocity.y, -1, 1, -0.2, 0.2);
      PVector wind = new PVector(dx, dy);
      //println("wind",wind);
      ps.applyForce(wind);
      ps.run();
      ps1.applyForce(wind);
      ps1.run();
      ps2.applyForce(wind);
      ps2.run();
      ps3.applyForce(wind);
      ps3.run();
      ps4.applyForce(wind);
      ps4.run();
      ps5.applyForce(wind);
      ps5.run();
      
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
        ps4.addParticle();
        ps5.addParticle();
        
        ds1.addParticle();
        ds2.addParticle();
        ds3.addParticle();
        ds4.addParticle();
      }
    }
  }
    
    
   void drawDeserts(){ 
     
     fill(thirdDesertColor);
     noStroke();
     rect(0,height - height/3, width, height/3);
     fill(255);
     
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
     fill(255);
 }
}
