public class Particle {
  PVector pos;
  PVector vel;
  PVector acc;
  int id;
  
  Particle[] others;
  float radius;


  //int maxSpeed = 10;

  //Particle(PVector pos, PVector vel, PVector acc){
  Particle(int id, Particle[] otherParticles) {
    this.pos = new PVector(random(width), random(height));
    this.vel = new PVector(0, 0);
    //this.vel = PVector.random2D();
    this.acc = new PVector(0, 0);
    this.others= otherParticles;
    this.id= id;
    this.radius= 2;

  }

  void update(float maxSpeed, float microphone) {
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.vel.limit(maxSpeed + microphone);
    //this.vel.mult(0);
    this.acc.mult(0);

    //println(" Current speed - ", this.vel);
  }

  void moveParticle(PVector force) {
    this.acc.add(force);
  }

  void show() {
    stroke(0);
    strokeWeight(0);
    fill(particleColor);
    ellipse(this.pos.x, this.pos.y, this.radius * 2, this.radius * 2);
  }

  void follow(PVector[] field) {
    int x = floor(this.pos.x/scale);
    int y = floor(this.pos.y/scale);
    int index = x + y * cols;
    PVector force = field[index];
    this.moveParticle(force);
  }

  void edges() {
    if (this.pos.x > width) {
      this.pos.x = 0;
    }
    if (this.pos.x < 0) {
      this.pos.x = width;
    }
    if (this.pos.y > height) {
      this.pos.y = 0;
    }
    if (this.pos.y < 0) {
      this.pos.y = height;
    }
  }
  
  void collide() {
    for (int i = this.id + 1; i < particleCount; i++) {
      float dx = others[i].pos.x - this.pos.x;
      float dy = others[i].pos.y - this.pos.y;
      float distance = sqrt(dx*dx + dy*dy);
      float minDist = others[i].radius + this.radius;
      
      // Collision with another circle
      if (distance < minDist) {
        float angle = atan2(dy, dx);
        float targetX = this.pos.x + cos(angle) * minDist;
        float targetY = this.pos.y + sin(angle) * minDist;
        float ax = (targetX - others[i].pos.x) * spring;
        float ay = (targetY - others[i].pos.y) * spring;
        this.vel.x -= ax;
        this.vel.y -= ay;
        others[i].vel.x += ax;
        others[i].vel.y += ay;
      }
    }   
  }
  
  void checkBoundaryCollision() {
    if (this.pos.x > width-this.radius) {
      this.pos.x = width-this.radius;
      this.vel.x *= -1;
    } else if (this.pos.x < this.radius) {
      this.pos.x = this.radius;
      this.vel.x *= -1;
    } else if (this.pos.y > height-this.radius) {
      this.pos.y = height-this.radius;
      this.vel.y *= -1;
    }
    else if (this.pos.y < this.radius) {
      this.pos.y = this.radius;
      this.vel.y *= -1;
    }
  }

  void clicked(float px, float py) {
    // find distance between particle and mouse click
    float d = dist(px, py, this.pos.x, this.pos.y);

    // if the particle is within the interaction area, do something
    if (d < 50) {

      // hold particles at a velocity and acceleration of 0
       //this.vel = PVector.fromAngle(radians(0));
       //this.acc.set(0,0);

      //// disperse particles
      //float theta = atan((py-this.pos.y)/(px-this.pos.x));
      //if (px<this.pos.x) {
      //  theta += PI;
      //}
      //theta *= -1;
      //// set velocity to move away from mouse
      //this.vel.set(PVector.fromAngle(theta));
      
      // improved disperse function
      this.vel.x += map(d, 0, 50, 0.2, 0.1)*(this.pos.x - px);
      this.vel.y += map(d, 0, 50, 0.2, 0.1)*(this.pos.y - py);
      
    }
  }
}
