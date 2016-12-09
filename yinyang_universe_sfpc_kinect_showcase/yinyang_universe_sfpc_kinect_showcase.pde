import org.openkinect.freenect.*;
import org.openkinect.processing.*;
String useNow = "x";
Kinect kinect;
color main_color = color(0, 0, 0);
float[] depthLookUp = new float[2048];

float rawDepthToCMeters(int adepthValue) {
  if (adepthValue < 2047) {
    return (float)((1.0 / ((double)(adepthValue) * -0.0030711016 + 3.3309495161)) *100);
  }
  return 0.0f;
}
float onoff = 1;
int counter = 1;
float scaler = 1;

float mapped_wtf;
float mapped_wtf_prev;

void setup() {
  //size(640, 640);
  fullScreen();
  kinect = new Kinect(this);
  kinect.initDepth();
  fill(255);
  noStroke();
}

void draw() {
  background(onoff);
  translate(width/2, height/2);
  scale(scaler);
  float var = getRealDepth();
  float mapped_var = map(var, 43, 151, 0, 255);
  //frameRate(map(var,43,151,20,60));

  mapped_wtf = map(var, 43, 151, 1, -0.5);
  mapped_wtf = lerp(mapped_wtf, mapped_wtf_prev, 0.8);
  float qmax = map(var, 43, 151, 90, 15);
  println(mapped_wtf);
  for (int q = 1; q < 15; q++) {
    float s = q*12;
    for (int i = 0; i < 360; i+=3  ) {
      float xz;
      float y = cos(radians(i))*s;
      float z = tan(radians(i))*s;
      if(useNow.equals("x")){
        //x
        xz = sin(radians(i*mapped_wtf))*s;
      }else{
        //z
        xz = tan(radians(i))*s;
      }


      float m = 0.5+sin(radians(sin(radians(frameCount))*s+i+frameCount*2));
      if (m > 0) {
        //TODO make timer
        ellipse(xz, y, m*q, m*q);
      }
    }  
  }
  counter += 1;
  onoff = sin(counter);

  pushStyle();
  fill(255, 255, 0);
  rect(0, map(mapped_wtf, 1, -0.5, -320, 320), 500, 5);
  popStyle();

  scaler = map(mapped_wtf, 1, -0.5, 1, 5);

  mapped_wtf_prev = mapped_wtf;
}

void toggle(){
  if(useNow.equals("x")){
    useNow = "z";
  }else {
    useNow = "x";
  } 
}

float getRealDepth() {
  int closestValue = 8000;
  int[] depthValues = kinect.getRawDepth();
  // for each row in the depth image
  float depth = 1.0;
  for (int y = 0; y < 480; y++) {
    // look at each pixel in the row
    for (int x = 0; x < 640; x++) {
      // pull out the corresponding value from the depth array
      int i = x + y * 640;
      int currentDepthValue = depthValues[i];

      // if that pixel is the closest one we've seen so far
      if (currentDepthValue > 0 && currentDepthValue < closestValue) {
        // save its value
        closestValue = currentDepthValue;
        depth = rawDepthToCMeters(currentDepthValue);
      }
    }
  }
  return depth;
}
