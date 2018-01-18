int sizeB = 3;
ArrayList<Bacteria> family = new ArrayList<Bacteria>();
//ArrayList<Bacteria> alienFamily = new ArrayList<Bacteria>();
float usualLife = 50.0; // usual life expectancy
int reprTime = 7; // reproduction time
int populationLimit = 1000;
  

void setup() {
  size(640,640);
  background(0);

  // Create N red bacteria
  
  PVector firstVector = new PVector(width/3,height/2);
  for (int i = 0; i < 0; i++) {
    PVector randomVector = PVector.random2D();
    Bacteria first = new Bacteria(PVector.add(firstVector,randomVector), 1, random(1));
    family.add(first);
  }
  // Create M blue bacteria
  //PVector secondVector = new PVector(2*width/3,height/2);
  //PVector secondVector = new PVector(width/2,height);
  for (int i = 0; i < 30; i++) {
    PVector randomVector = PVector.random2D();
    PVector secondVector = new PVector(width/8 + i*width/37,height);
    Bacteria second = new Bacteria(PVector.add(secondVector,randomVector), 0, 0.4);
    family.add(second);
  }

  //noStroke();
  rectMode(CENTER);
  strokeWeight(sizeB);
}

void draw() {
  //background(0);
  for (int i = 0; i < family.size(); i++) {
    family.get(i).update();
    family.get(i).reproduce();
    family.get(i).display();
    if (family.get(i).dead) {
      family.remove(i);
    }
  }
  // Limit the population, 
  if (family.size() > populationLimit) {
    int lengFam = family.size();
    // Cutting the oldest individuals
    /*
    for (int i = 0; i < lengFam; i++)
      if (family.size() > populationLimit) {
        if (family.get(i).lifeTime < usualLife*0.1) {
          family.remove(int(random(populationLimit)));
        }
      } else {
        return;
      }
      */
    // Cutting the first ones:
    for (int i = 0; i < lengFam - populationLimit; i++) {
      family.remove(0);
    }
  }
  
  textSize(35);
  fill(155);
  text("0",30,7*height/8);
  text("1",30,5*height/8);
  text("2",30,3*height/8);
  text("3",30,1*height/8);
  println(family.size());
  
  saveFrame("video3-antibiotics/bacteria-####.tiff");
}

class Bacteria {
  PVector position;
  float liveliness;
  float lifeTime = 0;
  boolean dead = false;
  int coloRed;
  int timeBeforeRepr = 0; // time before next reproduction
  
  Bacteria(PVector pos, int colo, float liveli) {
    position = pos;
    liveliness = liveli;
    coloRed = colo;
  }
  
  //Bacteria(float x1, float y1) {
  //  position.set(x1,y1,0);
  //}
  
  void reproduce() {
    if (lifeTime < usualLife) {
      Bacteria b;
      int thisTime = int(random(reprTime/3,2*reprTime/3));
      if (timeBeforeRepr % reprTime == thisTime) {
        PVector newVector = new PVector(width/2,height/2);
        //newVector.set(position.x + random(-sizeB,sizeB), position.y + random(-sizeB,sizeB));        
        newVector.set(position.x + random(-sizeB,sizeB), position.y - random(sizeB));
        // b = new Bacteria(newVector, coloRed, liveliness);   // inherit Colour and Liveliness. 
        b = new Bacteria(newVector, coloRed, liveliness*(1.0 + random(-0.1,0.1)));   // inherit Colour and Liveliness. 
        family.add(b);
        // If not coloRed, then create twice as many offspring
        //if (coloRed != 1) {
        //  family.add(b);
        //}
      }
    } else {
      dead = true;
    }
  }
  
  void update() {
    if (!dead) {
      lifeTime++;
      timeBeforeRepr++;
      moveFromOthers();
      //overpopulation();
      //devourAliens();
      antibiotics();
    }
  }
  
  void moveFromOthers() {
    // Move away from different bacteria
    for (Bacteria b1 : family) {
      if (b1 != this) {
        PVector dist = PVector.sub(b1.position,position);
        if (dist.mag() < sizeB) {
          dist.mult((dist.mag() - sizeB)/dist.mag()/2);
          position.add(dist);
        }
      }
    }
      
    // Move away from the walls
    if (position.x > width) {
      position.x = width;
    }
    if (position.x < 0) {
      position.x = 0;
    }
    if (position.y > height) {
      position.y = height;
    }
    if (position.y < 0) {
    //  position.y = 0;
    }
  }
  
  void devourAliens() {
    for (Bacteria b1 : family) {
      if (b1.coloRed != coloRed) {
        PVector dist = PVector.sub(b1.position,position);
        if (dist.mag() < sizeB) {
          //liveliness = (liveliness + b1.liveliness) / 2;
          //b1.liveliness = liveliness;
          if (coloRed == 1) {
            // Kill Kill Kill
            b1.dead = true;
            lifeTime = 0;
            position.add(dist.mult(liveliness*0.2));
          }          
        }
      }
    }
  }
  
  void overpopulation() {
    int density = 0;
    for (Bacteria b1 : family) {
      PVector dist = PVector.sub(b1.position,position);
      if (dist.mag() < sizeB) {
        density++;
      }
    }
    lifeTime += density*0.5;
  }
  
  void antibiotics() {
    if (position.y < 3*height/4) {
      if (liveliness < 0.5) {
        dead = true;
      }
    } 
    if (position.y < height*0.5) {
      if (liveliness < 1.2) {
        dead = true;
      }
    } 
    if (position.y < height*0.25) {
      if (liveliness < 1.8) {
        dead = true;
      }
    }
  }
  
  void display() {
    //stroke(coloRed*255*(1.0-lifeTime/usualLife),50,(1-coloRed)*255*(1.0-lifeTime/usualLife));
    stroke(255*liveliness*(1.0-lifeTime/usualLife),255*(liveliness-1.0)*(1.0-lifeTime/usualLife),255*(1.0-liveliness)*(1.0-lifeTime/usualLife));
    //(1.0-coloRed)
    if (!dead) {
      //rect(position.x,position.y,sizeB,sizeB);
      //line(position.x,position.y,position.x+(usualLife - lifeTime)*0.1,position.y+(usualLife - lifeTime)*0.1);
      point(position.x,position.y);
    }
  }
}