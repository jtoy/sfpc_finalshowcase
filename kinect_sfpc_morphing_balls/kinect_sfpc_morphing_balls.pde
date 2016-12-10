import org.openkinect.freenect.*;
import org.openkinect.processing.*;

Kinect kinect;
Neuron[] neurons = new Neuron[30];
float[] depthLookUp = new float[2048];

float rawDepthToCMeters(int adepthValue) {
  if (adepthValue < 2047) {
    return (float)((1.0 / ((double)(adepthValue) * -0.0030711016 + 3.3309495161)) *100);
  }
  return 0.0f;
}

void setup() {
  //size(640,480);
  fullScreen();
  kinect = new Kinect(this);
  kinect.initDepth();
  for (int i = 0; i < neurons.length; i++) {
    neurons[i] = new Neuron();
  }
  colorMode(HSB, 100);
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToCMeters(i);
  }  
}


void draw() {
  noCursor();
  fill(0);
  translate(width/2, height/2);
  
  

  float depthValue = getRealDepth();
  println("dv:"+depthValue);
  float mapped_var = map(depthValue,43,151, 1,250);
  for (int i = 0; i < neurons.length; i++) {
    
    neurons[i].setVal((int)mapped_var);
    neurons[i].show();
  }
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

class Neuron{
  float x;
  float y;
  float r;
  float c;
  int step;
  Neuron(){
    x = random(-width/2, width/2);
    y = random(-height/2, height/2);
    r = random(1,55);
    c = random(0,255);
    step = (int)random(1,5);
  }
   public void setVal(int val) {
       this.c = val*1.1;
       this.r = val*1.2;
       //x +=step + ((int)random(0,4)-4 );
       //y+=step + ((int)random(0,4)-4 );
       x +=step ;
       y+=step;
       if (x > width/2){
         this.x = 0- (width/2);
       }
       if(y>height/2){
          this.y=0 - (height/2); 
       }
    }
  void show(){
    color cc = color(c%360, c%100, c%100); 
    fill(cc);
    noStroke();
    ellipse(x, y, r,r);
  }  
}
