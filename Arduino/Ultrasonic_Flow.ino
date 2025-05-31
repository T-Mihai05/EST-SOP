/*
Liquid flow rate sensor + HC-SR04 distance sensor

This sketch measures:
- Liquid flow rate and cumulative volume
- Distance using an ultrasonic sensor (HC-SR04)

Flow sensor: Signal connected to pin 2 (interrupt)
Ultrasonic sensor: Trig pin 7, Echo pin 6
*/

const byte statusLed = 13;
const byte sensorInterrupt = 0; // Interrupt 0 maps to digital pin 2
const byte sensorPin = 2; // Flow sensor data pin
const int trigPin = 7;// HC-SR04 pins and variables
const int echoPin = 6;
long duration;


float calibrationFactor = 98; // Calibration factor: 98 pulses per second per (L/min)
volatile byte pulseCount;
float flowRate;
unsigned int flowMilliLitres;
unsigned long totalMilliLitres;
unsigned long oldTime;

void setup() {
  Serial.begin(9600);

  // Print column headers
  Serial.println("Time(s)\tFlow(L/min)\tFlow(mL/s)\tTotal(mL)\t NrPulses\t Distance(cm)");

  // HC-SR04 ultrasonic setup
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  // Flow sensor setup
  pinMode(statusLed, OUTPUT);
  digitalWrite(statusLed, HIGH); // active-low LED
  pinMode(sensorPin, INPUT);
  digitalWrite(sensorPin, HIGH); // enable internal pull-up

  pulseCount = 0;
  flowRate = 0.0;
  flowMilliLitres = 0;
  totalMilliLitres = 0;
  oldTime = 0;

  attachInterrupt(sensorInterrupt, pulseCounter, FALLING);
}

void loop() {
  if ((millis() - oldTime) > 1000) { // Process once per second
    detachInterrupt(sensorInterrupt);

    flowRate = ((1000.0 / (millis() - oldTime)) * pulseCount) / calibrationFactor;
    oldTime = millis();

    flowMilliLitres = (flowRate / 60) * 1000;// Flow rate in mL/s
    totalMilliLitres += flowMilliLitres;

    float distance  = readUltrasonicDistance();
    // Print flow data
    Serial.print(millis() / 1000);
    Serial.print("\t");
    Serial.print(flowRate);
    Serial.print("\t");
    Serial.print(flowMilliLitres);
    Serial.print("\t");
    Serial.print(totalMilliLitres);
    Serial.print("\t");
    Serial.print(pulseCount)
    Serial.print("\t");
    readUltrasonicDistance();
    Serial.println(distance);

    pulseCount = 0;
    attachInterrupt(sensorInterrupt, pulseCounter, FALLING);
  }
}

// Interrupt Service Routine: count each pulse from flow sensor
void pulseCounter() {
  pulseCount++;
}

// Read distance from HC-SR04 and store in global 'distance'
void readUltrasonicDistance() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH);
  return duration * 0.034 / 2; // Convert to cm (speed of sound ~343 m/s)
}
