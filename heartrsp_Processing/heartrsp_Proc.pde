
/*
Group 4: Pouyan Firouzabadi, Bekah Allen, Filippo Cinotti, Joey Voorhees
 Lab 1 - Heart Rate Monitor + Breathing Monitor
 Description: A wearable Heart Rate Monitor with reactive breathing strip to monitor breathing function.
 This also has an app to go along with it to change between 3 modes:
 Fitness Mode
 Meditation Mode
 Stress Monitoring Mode
 
 References: 
 https://processing.org/reference/text_.html
 https://www.w3schools.com/colors/colors_shades.asp
 https://processing.org/examples/button.html
 https://www.colorhexa.com/cc0000
 https://processing.org/reference/delay_.html
 ControlP5 Documation
 Grafica Documentation
 https://github.com/WorldFamousElectronics/PulseSensor_Heart-Rate-Variabilty/blob/master/PulseSensorAmped_HRV_PoincarePlot_1_1_0/PulseSensorAmped_HRV_PoincarePlot_1_1_0.pde
 */

import processing.sound.*;
SoundFile file;
import grafica.*;
import controlP5.*;
import processing.serial.*;
int xVal;
Serial mySerial;

ControlP5 gui;
Button b, s, m;


String myString = null;
int nl=10 ;
float myVal;
int Buzz = 0;

boolean main = true;
boolean fitness = false;
boolean stress = false;
boolean meditation = false;

float[] HRV1;
float[] HRV0;
int numPoints = 4;
float HR = 0;
int timer, t = 30;
GPlot plot;         // graphs
GPointsArray heartRates;
int myBack = color(0, 0, 0);
float heartrate =0, hData=0, HRV = 0;


void setup() {
  // Load a soundfile from the /data folder of the sketch and play it back
  file = new SoundFile(this, "Yanni.mp3");
  //ControlP5 gui;
  size(1000, 600);
  background(myBack);
  //frameRate(01);
  //println(Serial.list());
  //mySerial = new Serial(this, Serial.list()[2], 115200); // Change to the port your arduino is connected (i.e. "COM1"...."COM2"..."COM3".... ect)
  //mySerial.bufferUntil('\n'); //clean the buffer
  HRV0 = new float[1000];
  HRV1 = new float[1000];
  
  HRV0[0] = 1000;
  HRV1[0] = 800;
  
  HRV0[1] = 900;
  HRV1[1] = 1000;
 
  HRV0[2] = 965;
  HRV1[2] = 900;
 
  HRV0[3] = 890;
  HRV1[3] = 965;
  
  HRV0[4] = 1000;
  HRV1[4] = 890;
  
  PFont p = createFont("Verdana", 24); 
  gui = new ControlP5(this);

  String opening = "Please select a mode to start.";
  textSize(20);
  fill(128, 128, 128);
  text(opening, 50, 50);

  //sets the text and button for fitness mode

  s = gui.addButton("Stress")
    .setPosition(250, 450)
    .setColorBackground(color(255, 0, 0))
    .setSize(200, 100)
    .setFont(p)
    //.setValue(0)
    //.activateBy(ControlP5.RELEASE)
    .show()
    ;

  //  //sets the text choice and button for stress mode

  m = gui.addButton("Meditation")
    .setPosition(550, 450)
    .setSize(200, 100)
    .setFont(p)
    //.setValue(0)
    //.activateBy(ControlP5.RELEASE)
    .show()
    ;

  // //sets the text and button for meditation mode
  b = gui.addButton("Back")
    .setPosition(800, 20)
    .setSize(100, 50)
    .setFont(p)
    //.setValue(0)
    //.activateBy(ControlP5.RELEASE)
    .hide()
    ;

  // graph 1 points and position.
  heartRates = new GPointsArray();
  plot = new GPlot(this);
  plot.setPos(530, 100);
  //title and labels
  plot.setTitleText("PPG Monitor");
  plot.getXAxis().setAxisLabelText("Time");
  plot.getYAxis().setAxisLabelText("PPG Value");
  plot.setXLim(0, 300);
  plot.setYLim(20, 120);
  //include the found points
  plot.setPoints(heartRates);
  // Draw it!
  plot.activateZooming();
  plot.activatePanning();
  ///////////////////////////
  //rectMode(CENTER);
  delay(100);
}

void draw() {

  if (main) {
    background(myBack);
    drawDataWindows();
    writeAxisLabels();
    makePoints();
    plot.defaultDraw();
    String opening = "Please select a mode to start.";
    textSize(32);
    fill(250, 250, 250);
    text(opening, 50, 50);

    plot.addPoint(new GPoint(xVal, hData));
    plot.setPoint(xVal, new GPoint(xVal, hData));

    xVal++;

    if ( xVal >= 300) {
      plot.moveHorizontalAxesLim(1.0);
    }
  }

  if (stress) {
    background(100, 80, 100); 
    drawDataWindows();
    writeAxisLabels();
    makePoints();
    plot.defaultDraw();
    String opening = "Stress Mode";
    textSize(32);
    fill(250, 250, 250);
    text(opening, 50, 50);

    textSize(28);
    fill(0, 250, 20);
    text("Heart Rate: " + heartrate, 600, 450);

    if (heartrate >= 80) {
      fill(255, 0, 0);
      text("ALERT!!! ", 300, 500);
    }
    plot.addPoint(new GPoint(xVal, hData));
    plot.setPoint(xVal, new GPoint(xVal, hData));

    xVal++;

    if ( xVal >= 300) {
      plot.moveHorizontalAxesLim(1.0);
    }
  }
  if (meditation) {
    timer = millis()%1000;
    background(25, 25, map(timer,0,1000,100,200)); 
    
    
    drawDataWindows();
    writeAxisLabels();
    makePoints();
    plot.defaultDraw();
    String opening = "Meditation Mode";
    textSize(32);
    fill(250, 250, 250);
    text(opening, 50, 50);
    
    textSize(28);
    fill(0, 250, 20);
    text("Heart Rate: " + heartrate, 600, 450);


    plot.addPoint(new GPoint(xVal, hData));
    plot.setPoint(xVal, new GPoint(xVal, hData));
    xVal++;

    if ( xVal >= 300) {
      plot.moveHorizontalAxesLim(1.0);
    }
  }
}


public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
}


//stressmode functionality
public void Stress(int value) {
  main = false;
  fitness = false;
  stress = true;
  meditation = false;

  s.hide();
  m.hide();
  b.setVisible(true);

}

//Meditation Mode functionality
public void Meditation(int value) {
  main = false;
  fitness = false;
  stress = false;
  meditation = true;
  file.play();


  s.hide();
  m.hide();
  b.setVisible(true);

}

public void Back(int value) {
  main = true; 
  fitness = false;
  stress = false;
  meditation = false;
  if (file.isPlaying()) {
    file.stop();
  }

  s.show();
  m.show();
  b.hide();
}


float[] splice = {0, 0};
void serialEvent( Serial mySerial) {
  try {
    if (mySerial.available() > 0)
    {
      myString = mySerial.readStringUntil('\n');
      if (myString != null)
      {
        println(myString);
        myString = trim(myString);
        float[] s = float(split(myString, ','));
        for (int i =0; i < s.length; i++)
          splice[i] = s[i];

        heartrate = splice[0];
        HRV = splice[1];
        hData = splice[2];

        heartRates.add(hData, 10*noise(0.1*hData));


        hData = hData %100;
        print(heartrate);
        print(',');
        print(HRV);
        print(",");
        println(hData);

      }
    }
  }
  catch(RuntimeException e) {
    e.printStackTrace();
  }
}




/////DRAW GRAPH FOR HRV RATE...

void drawDataWindows() {
  noStroke();
  fill(color(255, 253, 248));
  rect(50, 100, 440, 300);     // draw Poincare Plot window
  //rect(300,(height/2)+15,150,550);     // draw the Pulse Sensor data window
}

void writeAxisLabels() {
  noStroke();

  fill(color(0, 0, 0));   
  textSize(12);
  text("HRV Poincare Plot", 220, 120);  // title
  fill(180);                                // draw the Plot coordinate values in grey
  //text("0mS", 500, 430);                 // origin, scaled in mS
  for (int i=0; i<=1500; i+=500) {         // print x axis values
    text(i, 25, map(i, 0, 1500, 405, 105));
  }
  for (int i=0; i<=1500; i+=500) {         // print  Y axis values
    text(i, map(i, 0, 1500, 45, 475), 410);
  }
  stroke(250, 30, 250);                       // draw gridlines in purple
  for (int i=0; i<=1500; i+=100) {            // draw grid lines on axes
    line(50, map(i, 0, 1500, 400, 100), 60, map(i, 0, 1500, 400, 100)); //y axis
    line(map(i, 0, 1500, 50, 490), 400, map(i, 0, 1500, 50, 490), 390); // x axis
  }
  noStroke();
  fill(255, 253, 10);                                    // print axes legend in yellow, for fun
  text("n", map(750, 0, 1500, 50, 490), 410);    // n is the most recent IBI value
  text("n-1", 25, map(750, 0, 1500, 405, 105));               // n-1 is the one we got before n
  textSize(20);
}

/////PLOTTING THE VALUES FOR THE GRAPH.

void makePoints() {

  if (HRV != 0 && HRV != HRV0[0]) {
    numPoints++;              //update number of points

    for (int i= numPoints; i>0; i--) {   // shift the data in n and n-1 arrays
      HRV1[i] = HRV1[i-1];
      HRV0[i] = HRV0[i-1];     // shift the data point through the array
    }
    HRV1[0] = HRV0[1];       // toss the old n into the n-1 spot
    HRV0[0] = HRV;                // update n with the current IBI value
  }
  if (numPoints > 998) {
    for (int i= numPoints; i>800; i--) {
      HRV1[i] = 0;
      HRV0[i] = 0;
    }
    numPoints = 801;
  }
  fill(0, 0, 255);                         //  draw a history of the data points as blue dots
  for (int i=1; i<numPoints; i++) {
    HRV0[i] = constrain(HRV0[i], 0, 1500);  // keep the values from escaping the Plot window!
    HRV1[i] = constrain(HRV1[i], 0, 1500);
    float  x = map(HRV0[i], 0, 1500, 50, 490);  // scale the data to fit the screen
    float  y = map(HRV1[i], 0, 1500, 400, 100);  // invert Y so it looks normal
    ellipse(x, y, 3, 3);                            // print datapoints as dots 2 pixel diameter
  }
  fill(250, 0, 0);                               // draw the most recent data point as a red dot
  float  x = map(HRV0[0], 0, 1500, 50, 490);  // scale the data to fit the screen
  float  y = map(HRV1[0], 0, 1500, 400, 100);  // invert Y so it looks normal
  ellipse(x, y, 5, 5);                            // print datapoint as a dot 5 pixel diameter
  fill(0, 253, 248);   
  textSize(20);
  text("n: "+HRV+"mS", 80, 120);
  //textSize(20);
}
