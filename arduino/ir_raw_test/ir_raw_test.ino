/*
 * IR Raw Pin Test - Check if Pin 2 receives ANY signal
 * This bypasses the IR library entirely
 */

#define IR_PIN 2

int lastState = HIGH;

void setup() {
  Serial.begin(9600);
  pinMode(IR_PIN, INPUT);
  Serial.println("IR Raw Test - Press remote buttons");
  Serial.println("If you see 'SIGNAL!' messages, the receiver is working.");
  Serial.println("Current pin state: ");
  Serial.println(digitalRead(IR_PIN) == HIGH ? "HIGH (normal idle)" : "LOW (unusual)");
  Serial.println("---");
}

void loop() {
  int state = digitalRead(IR_PIN);
  if (state != lastState) {
    if (state == LOW) {
      Serial.println("SIGNAL! Pin went LOW");
    }
    lastState = state;
  }
}
