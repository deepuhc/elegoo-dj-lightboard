/*
 * Proximity Alert - Ultrasonic Distance-Reactive Light & Sound
 *
 * Wave your hand in front of the sensor:
 *   Far (>30cm)   = Green LED, no beep
 *   Medium (15-30) = Yellow LED, slow beep
 *   Close (5-15)  = Red LED, fast beep
 *   Very close (<5) = Red LED, continuous tone
 *
 * Hardware:
 *   HC-SR04: Trig=Pin 9, Echo=Pin 4
 *   RGB LED: Red=Pin 6, Green=Pin 5, Blue=Pin 3
 *   Buzzer:  Pin 8
 */

#define TRIG_PIN  9
#define ECHO_PIN  4
#define RED_PIN   6
#define GREEN_PIN 5
#define BLUE_PIN  3
#define BUZZER_PIN 8

void setColor(int r, int g, int b) {
  analogWrite(RED_PIN, r);
  analogWrite(GREEN_PIN, g);
  analogWrite(BLUE_PIN, b);
}

long getDistance() {
  // Send 10us pulse to trigger
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  // Measure echo pulse duration
  long duration = pulseIn(ECHO_PIN, HIGH, 30000); // timeout 30ms

  // Convert to cm (speed of sound = 343m/s)
  long distance = duration * 0.0343 / 2;

  return distance;
}

void setup() {
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  pinMode(RED_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(BLUE_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  Serial.begin(9600);
  Serial.println("Proximity Alert - Wave your hand in front of the sensor!");
  Serial.println("---");
}

void loop() {
  long distance = getDistance();

  // Print distance for debugging
  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.println(" cm");

  if (distance == 0) {
    // No reading (out of range or error)
    setColor(0, 0, 0);
    noTone(BUZZER_PIN);
  }
  else if (distance < 5) {
    // Very close - RED + continuous tone
    setColor(255, 0, 0);
    tone(BUZZER_PIN, 1000);
  }
  else if (distance < 15) {
    // Close - RED + fast beep
    setColor(255, 0, 0);
    tone(BUZZER_PIN, 800, 50);
    delay(100);
    noTone(BUZZER_PIN);
  }
  else if (distance < 30) {
    // Medium - YELLOW (red+green) + slow beep
    setColor(255, 180, 0);
    tone(BUZZER_PIN, 400, 50);
    delay(300);
    noTone(BUZZER_PIN);
  }
  else {
    // Far - GREEN + no sound
    setColor(0, 255, 0);
    noTone(BUZZER_PIN);
  }

  delay(100);
}
