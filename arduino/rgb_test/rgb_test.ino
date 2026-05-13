/*
 * RGB LED Test - Cycles through colors to verify wiring
 * Red = Pin 6, Green = Pin 5, Blue = Pin 3
 */

#define RED_PIN   6
#define GREEN_PIN 5
#define BLUE_PIN  3

void setColor(int r, int g, int b) {
  analogWrite(RED_PIN, r);
  analogWrite(GREEN_PIN, g);
  analogWrite(BLUE_PIN, b);
}

void setup() {
  pinMode(RED_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(BLUE_PIN, OUTPUT);
  Serial.begin(9600);
  Serial.println("RGB LED Test - Watch for color changes!");
}

void loop() {
  Serial.println("RED");
  setColor(255, 0, 0);
  delay(1000);

  Serial.println("GREEN");
  setColor(0, 255, 0);
  delay(1000);

  Serial.println("BLUE");
  setColor(0, 0, 255);
  delay(1000);

  Serial.println("YELLOW (red + green)");
  setColor(255, 255, 0);
  delay(1000);

  Serial.println("PURPLE (red + blue)");
  setColor(255, 0, 255);
  delay(1000);

  Serial.println("CYAN (green + blue)");
  setColor(0, 255, 255);
  delay(1000);

  Serial.println("WHITE (all on)");
  setColor(255, 255, 255);
  delay(1000);

  Serial.println("OFF");
  setColor(0, 0, 0);
  delay(500);
}
