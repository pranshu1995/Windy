// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {

  ArrayList<Particle2> particles;    // An arraylist for all the particles
  PVector origin;                   // An origin point for where particles are birthed
  PImage img;
  color tintColor;

  ParticleSystem(int num, PVector v, PImage img_, color tintColor_) {
    particles = new ArrayList<Particle2>();              // Initialize the arraylist
    origin = v.copy();                                   // Store the origin point
    img = img_;
    tintColor = tintColor_;
    for (int i = 0; i < num; i++) {
      particles.add(new Particle2(origin, img,tintColor));         // Add "num" amount of particles to the arraylist
    }
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle2 p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }

  // Method to add a force vector to all particles currently in the system
  void applyForce(PVector dir) {
    // Enhanced loop!!!
    for (Particle2 p : particles) {
      p.applyForce(dir);
    }
  }  

  void addParticle() {
    particles.add(new Particle2(origin, img,tintColor));
  }
}
