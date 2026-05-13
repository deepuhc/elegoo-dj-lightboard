/*
 * Buzzer Test - Plays a short melody to verify wiring
 * Passive Buzzer on Pin 8
 */

#define BUZZER_PIN 8

// Note frequencies
#define NOTE_C4  262
#define NOTE_D4  294
#define NOTE_E4  330
#define NOTE_F4  349
#define NOTE_G4  392
#define NOTE_A4  440
#define NOTE_B4  494
#define NOTE_C5  523

void setup() {
  Serial.begin(9600);
  Serial.println("Buzzer Test - Playing melody!");
}

void loop() {
  // Play a happy jingle
  int melody[] = {NOTE_C4, NOTE_E4, NOTE_G4, NOTE_C5, NOTE_G4, NOTE_E4, NOTE_C4};
  int durations[] = {200, 200, 200, 400, 200, 200, 400};

  for (int i = 0; i < 7; i++) {
    Serial.print("Playing note: ");
    Serial.println(melody[i]);
    tone(BUZZER_PIN, melody[i], durations[i]);
    delay(durations[i] + 50);
  }

  noTone(BUZZER_PIN);
  Serial.println("--- pause ---");
  delay(2000);
}
