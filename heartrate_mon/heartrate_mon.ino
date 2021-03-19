/******************************************************************************
Heart_Rate_Display.ino
Demo Program for AD8232 Heart Rate sensor.
Casey Kuhns @ SparkFun Electronics
6/27/2014
https://github.com/sparkfun/AD8232_Heart_Rate_Monitor
The AD8232 Heart Rate sensor is a low cost EKG/ECG sensor.  This example shows
how to create an ECG with real time display.  The display is using Processing.
This sketch is based heavily on the Graphing Tutorial provided in the Arduino
IDE. http://www.arduino.cc/en/Tutorial/Graph
Resources:
This program requires a Processing sketch to view the data in real time.
Development environment specifics:
  IDE: Arduino 1.0.5
  Hardware Platform: Arduino Pro 3.3V/8MHz
  AD8232 Heart Monitor Version: 1.0
This code is beerware. If you see me (or any other SparkFun employee) at the
local pub, and you've found our code helpful, please buy us a round!
Distributed as-is; no warranty is given.
****************************************************************************/
const float alpha = 0.143;
float average= 0;
double data_filtered[] = {0, 0, 0, 0, 0 ,0 ,0};
const int n = 6;
const int analog_pin = 0;

int HeartBeat = 0;
int mean=7;

//int restistance = 2.5
int pinRes = A1;
int stretch;
unsigned long timer;
unsigned long current;

int prevMax = 0, currMax = 0, prevMin = 1000, currMin = 1000;
unsigned long inh_start = 0, inh_end = 0, exh_start = 0, exh_end = 0;


void setup() {
  // initialize the serial communication:
  Serial.begin(115200);
  pinMode(pinRes, INPUT);
  pinMode(10, INPUT); // Setup for leads off detection LO +
  pinMode(11, INPUT); // Setup for leads off detection LO -
  timer = millis();
  //Serial.println(timer);
  
  
}

int prev = 0;
int next = 0;
bool inrange = false;
void loop() {
  
  if((digitalRead(10) == 1)||(digitalRead(11) == 1)){
//    Serial.println('!');
  }
  else{
    // send the value of analog input 0:
      int data = analogRead(A0);
      data =map(data,0,1000,0,100);
      //Serial.println(data);
      if(data>=90){
        if (inrange == false){
          HeartBeat++;
        }
        inrange = true;
      }
      else
        inrange = false;
      
  }
  //Wait for a bit to keep serial data from saturating
  delay(7);
  current = millis()-timer;
  delay(7);
//  Serial.println(current);
  if(current > 10000)
  {
    //Serial.println(HeartBeat); 
    timer = millis();
  }

  //-----------Respiratory---------

 stretch = analogRead(pinRes);
// Serial.println(stretch);
    // New value calculation
    for(int i=1; i<mean; i++)
    {
     average= average + alpha * data_filtered[n-i];
    }
    data_filtered[n] = (alpha * stretch) + average;
    average=0;
    // data_filtered values update
//    for(int i=0; i<mean; i++)
//    {
//      data_filtered[i] = data_filtered[i+1];
//    }


  
  
    // Print Data
//    stretch = data_filtered[n];
    Serial.println(data_filtered[n]);
  

// //Set current maximum... SHOWS INCREASING
// if(currMax <= stretch)
//    currMax = stretch;
// //OTHERWISE DECREASING
// else{
//    //close the timer... 
//    inh_end = millis();
//    prevMax = currMax;
//    exh_start = millis();
// }

 
// //set current minimum... SHOW DECREASING
// if(currMin >= stretch)
//    currMin = stretch;
// else{ //SHOW INCREASING
//    //set timer.....
//    inh_start = millis();
//    prevMin = currMin;
//    exh_end = millis();
 //}
 delay(20);

}
