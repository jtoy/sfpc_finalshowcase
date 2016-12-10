int var = 0;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;

Kinect kinect;
Attractor myAttractor;
float[] depthLookUp = new float[2048];

float rawDepthToCMeters(int adepthValue) {
  if (adepthValue < 2047) {
    return (float)((1.0 / ((double)(adepthValue) * -0.0030711016 + 3.3309495161)) *100);
  }
  return 0.0f;
}

class Attractor {
  // position
  float x=0, y=0; 
  int val = 0;

  // radius of impact
  float radius = 200;


  Attractor(float theX, float theY) {
    x = theX;
    y = theY;
  }


  void attract(int aVal,Neuron theNode) {
    // calculate distance
    float dx = x - theNode.x;
    float dy = y - theNode.y;
    float d = mag(dx, dy);

    if (d > 0 && d < radius) {
      // calculate force
      float s = d/radius;
      float f = 1 / pow(s, 0.5) - 1;
      f = f / radius*2;
      
      // apply force to node velocity
      theNode.vel.x += dx * f;
      theNode.vel.y += dy * f;
    }
  }

}
class Neuron {
  float r;
  PVector pos;
  PVector vel;
  int x;
  int y;
  int val;
  color center_color = color(255,0,0);
  color outer_color = color(0,0,255);

  Neuron() {
    r = random(1, 55);
    pos = new PVector(random(width), random(height));
    vel = new PVector(random(-3, 3), random(-3, 3));
  }

  public void setVal(int aval) {
    val = aval;
    float velmult = 1;
    
    if ((pos.x > width) || (pos.x < 0)) {
      vel.x = vel.x * -1 * velmult;
    }
    if ((pos.y > height) || (pos.y < 0)) {
      vel.y *= -1 * velmult;
    }
    if ((pos.y ==0 ) && (pos.x == 0)) {
      vel.y *= velmult;
      vel.x = vel.x * velmult;
    }

    
  }
  void show() {
    float x = pos.x;
    float y = pos.y;
    
    //lines to center
    pushStyle();
    strokeWeight(1);
    stroke(255);
    line(width * 0.5, height * 0.5, x, y);
    popStyle();
    
    
    
    int degree = frameCount%360;
    pushMatrix();
    translate(x, y);
    fill(255);
    rotate(radians(degree));
    strokeWeight(10);
    color new_center = color(val,0,255-val);
    center_color = lerpColor(center_color,new_center,.9);
    stroke(center_color);
    line(20, 20, 40, 40);  //floating line
    
    popMatrix();
    
    
    
    
    color new_outer = color(val,0,255-val);
    outer_color = lerpColor(outer_color,new_outer,.9);
    pushMatrix();
    translate(x, y);
    fill(255);
    rotate(radians(degree-180));
    strokeWeight(10);
    stroke(new_outer);
    line(20, 20, 40, 40);  //floating line
    
    popMatrix();
    
    

 
    

    pushStyle();
    strokeWeight(1);
    fill(val,112,255-val);
    ellipse(x,y,20,20);
    popStyle();
    


    pos.add(vel);
  }
}
Neuron[] neurons = new Neuron[100];
void setup() {


  //size(900, 900);
  fullScreen();
  kinect = new Kinect(this);
  kinect.initDepth();
  frameRate(30);
  myAttractor = new Attractor(width/2, height/2);

  for (int i = 0; i < neurons.length; i++) {
    neurons[i] = new Neuron();
  }
  background(31, 40, 45);
}

void draw() {
  //background(0);
  noCursor();
  fill(0, 5);
   noStroke();
   rect(0, 0, width, height);

 float var = getRealDepth();
 float mapped_var = map(var,43,151,0,255);
 //frameRate(mapped_var);

  println("var:"+ var);

 println("mapped:"+ mapped_var);
  for (int i = 0; i < neurons.length; i++) {
    myAttractor.attract(200,neurons[i]);
    neurons[i].setVal((int)mapped_var);
    neurons[i].show();
  }  
  //fill(var);
  //for (int i = 0; i < 50; i++) {
  //  fill(var);
  // ellipse(width/2,height/2,i,i);
  //}
}


float getRealDepth(){
  int closestValue = 8000;
  int[] depthValues = kinect.getRawDepth();
   // for each row in the depth image
   float depth = 1.0;
   for(int y = 0; y < 480; y++){
     // look at each pixel in the row
     for(int x = 0; x < 640; x++){
       // pull out the corresponding value from the depth array
       int i = x + y * 640;
       int currentDepthValue = depthValues[i];
     
       // if that pixel is the closest one we've seen so far
       if(currentDepthValue > 0 && currentDepthValue < closestValue){
         // save its value
         closestValue = currentDepthValue;
         depth = rawDepthToCMeters(currentDepthValue);
       }
     }
   }
  return depth;
}
