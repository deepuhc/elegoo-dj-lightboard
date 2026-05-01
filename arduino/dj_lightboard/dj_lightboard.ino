/*
 * DJ Lightboard - IR Remote Controlled LED Matrix Animations
 * with MATLAB Dashboard Support
 *
 * Hardware:
 *   - ELEGOO Mega 2560
 *   - MAX7219 8x8 LED Dot Matrix (DIN=12, CS=11, CLK=10)
 *   - IR Receiver AX-1838HS (Pin 2)
 *   - Passive Buzzer (Pin 8)
 *   - RGB LED (Red=6, Green=5, Blue=3)
 *
 * Serial Protocol (9600 baud):
 *   Commands IN:  A<n>\n  S<n>\n  C<r>,<g>,<b>\n  P\n
 *   Status  OUT:  S<anim>,<r>:<g>:<b>,<speed>\n
 */

#include <IRremote.h>
#include <LedControl.h>
#include "animations.h"
#include "melodies.h"

// --- Pin Definitions ---
#define IR_PIN      2
#define BUZZER_PIN  8
#define RGB_RED     6
#define RGB_GREEN   5
#define RGB_BLUE    3
#define MAX_DIN     12
#define MAX_CS      11
#define MAX_CLK     10

// --- IR Remote Codes (ELEGOO remote) ---
#define IR_POWER    0xFFA25D
#define IR_VOLUP    0xFF629D
#define IR_VOLDN    0xFFA857
#define IR_0        0xFF6897
#define IR_1        0xFF30CF
#define IR_2        0xFF18E7
#define IR_3        0xFF7A85
#define IR_4        0xFF10EF
#define IR_5        0xFF38C7
#define IR_6        0xFF5AA5
#define IR_7        0xFF42BD
#define IR_8        0xFF4AB5
#define IR_9        0xFF52AD

// --- Objects ---
LedControl lc = LedControl(MAX_DIN, MAX_CLK, MAX_CS, 1);
IRrecv irrecv(IR_PIN);
decode_results irResults;

// --- State ---
bool powerOn = true;
int currentAnim = 0;       // 0 = none, 1-9 = specific, 10 = shuffle
int currentFrame = 0;
int animSpeed = 5;          // 1 (slow) to 9 (fast)
int rgbR = 0, rgbG = 0, rgbB = 0;
unsigned long lastFrameTime = 0;
unsigned long lastShuffleSwitch = 0;
int shuffleAnim = 1;

// Speed maps to frame delay in ms: speed 1=500ms, 5=200ms, 9=50ms
int getFrameDelay() {
  return map(animSpeed, 1, 9, 500, 50);
}

// --- RGB Color Presets per Animation ---
struct RGB { byte r, g, b; };
const RGB ANIM_COLORS[] = {
  {  0,   0,   0},  // 0: none
  {255, 200,   0},  // 1: smiley  -> yellow
  {255,   0,   0},  // 2: heart   -> red
  {  0,  50, 255},  // 3: rain    -> blue
  {  0, 255,   0},  // 4: HI!     -> green
  {255, 255, 255},  // 5: star    -> white
  {180,   0, 255},  // 6: snake   -> purple
  {255, 100,   0},  // 7: fireworks -> orange
  {  0, 255, 255},  // 8: spinner -> cyan
  {255,   0, 200},  // 9: arrows  -> magenta
};

void setup() {
  Serial.begin(9600);

  // RGB LED
  pinMode(RGB_RED, OUTPUT);
  pinMode(RGB_GREEN, OUTPUT);
  pinMode(RGB_BLUE, OUTPUT);
  setRGB(0, 0, 0);

  // Buzzer
  pinMode(BUZZER_PIN, OUTPUT);

  // MAX7219 LED Matrix
  lc.shutdown(0, false);
  lc.setIntensity(0, 8);
  lc.clearDisplay(0);

  // IR Receiver
  irrecv.enableIRIn();

  // Startup chime
  playMelody(MELODY_POWER_ON, MELODY_POWER_ON_LEN);
  sendStatus();
}

void loop() {
  handleIR();
  handleSerial();

  if (powerOn && currentAnim > 0) {
    unsigned long now = millis();

    if (currentAnim == 10) {
      // Shuffle mode: switch animation every 3 seconds
      if (now - lastShuffleSwitch > 3000) {
        shuffleAnim = random(1, 10);
        setAnimColor(shuffleAnim);
        currentFrame = 0;
        lastShuffleSwitch = now;
      }
      updateAnimation(shuffleAnim, now);
    } else {
      updateAnimation(currentAnim, now);
    }
  }
}

// --- Display a single frame on the 8x8 matrix ---
void displayFrame(const byte* frame) {
  for (int row = 0; row < 8; row++) {
    lc.setRow(0, row, frame[row]);
  }
}

// --- Update animation frame based on timing ---
void updateAnimation(int anim, unsigned long now) {
  if (now - lastFrameTime < (unsigned long)getFrameDelay()) return;
  lastFrameTime = now;

  int totalFrames;
  const byte* frames;

  switch (anim) {
    case 1: frames = &SMILEY[0][0];     totalFrames = SMILEY_FRAMES;     break;
    case 2: frames = &HEART[0][0];       totalFrames = HEART_FRAMES;      break;
    case 3: frames = &RAIN[0][0];        totalFrames = RAIN_FRAMES;       break;
    case 4: frames = &HI_SCROLL[0][0];   totalFrames = HI_SCROLL_FRAMES;  break;
    case 5: frames = &STAR[0][0];        totalFrames = STAR_FRAMES;       break;
    case 6: frames = &SNAKE[0][0];       totalFrames = SNAKE_FRAMES;      break;
    case 7: frames = &FIREWORKS[0][0];   totalFrames = FIREWORKS_FRAMES;  break;
    case 8: frames = &SPINNER[0][0];     totalFrames = SPINNER_FRAMES;    break;
    case 9: frames = &ARROWS[0][0];      totalFrames = ARROWS_FRAMES;     break;
    default: return;
  }

  displayFrame(frames + (currentFrame * 8));
  currentFrame = (currentFrame + 1) % totalFrames;
}

// --- Play a melody (non-blocking would be better but keeping it simple) ---
void playMelody(const NoteEntry* melody, int len) {
  for (int i = 0; i < len; i++) {
    if (melody[i].note == 0) {
      noTone(BUZZER_PIN);
    } else {
      tone(BUZZER_PIN, melody[i].note);
    }
    delay(melody[i].duration);
  }
  noTone(BUZZER_PIN);
}

// --- Play the sound effect for an animation ---
void playAnimSound(int anim) {
  switch (anim) {
    case 1: playMelody(MELODY_HAPPY,    MELODY_HAPPY_LEN);    break;
    case 2: playMelody(MELODY_HEARTBEAT, MELODY_HEARTBEAT_LEN); break;
    case 3: playMelody(MELODY_RAIN,     MELODY_RAIN_LEN);     break;
    case 4: playMelody(MELODY_GREETING, MELODY_GREETING_LEN); break;
    case 5: playMelody(MELODY_SPARKLE,  MELODY_SPARKLE_LEN);  break;
    case 6: playMelody(MELODY_GAME,     MELODY_GAME_LEN);     break;
    case 7: playMelody(MELODY_BOOM,     MELODY_BOOM_LEN);     break;
    case 8: playMelody(MELODY_WHIR,     MELODY_WHIR_LEN);     break;
    case 9: playMelody(MELODY_CLICK,    MELODY_CLICK_LEN);    break;
  }
}

// --- Set RGB LED color ---
void setRGB(int r, int g, int b) {
  rgbR = r; rgbG = g; rgbB = b;
  analogWrite(RGB_RED, r);
  analogWrite(RGB_GREEN, g);
  analogWrite(RGB_BLUE, b);
}

// --- Set RGB to animation preset color ---
void setAnimColor(int anim) {
  if (anim >= 1 && anim <= 9) {
    setRGB(ANIM_COLORS[anim].r, ANIM_COLORS[anim].g, ANIM_COLORS[anim].b);
  }
}

// --- Select an animation ---
void selectAnimation(int anim) {
  currentAnim = anim;
  currentFrame = 0;
  lastFrameTime = 0;

  if (anim == 10) {
    // Shuffle mode
    shuffleAnim = random(1, 10);
    setAnimColor(shuffleAnim);
    lastShuffleSwitch = millis();
  } else if (anim >= 1 && anim <= 9) {
    setAnimColor(anim);
    playAnimSound(anim);
  } else {
    lc.clearDisplay(0);
    setRGB(0, 0, 0);
  }

  sendStatus();
}

// --- Handle IR Remote Input ---
void handleIR() {
  if (!irrecv.decode(&irResults)) return;

  unsigned long code = irResults.value;
  irrecv.resume();

  if (code == 0xFFFFFFFF) return; // ignore repeat

  if (!powerOn && code != IR_POWER) return; // only power button works when off

  switch (code) {
    case IR_POWER:
      powerOn = !powerOn;
      if (powerOn) {
        playMelody(MELODY_POWER_ON, MELODY_POWER_ON_LEN);
      } else {
        playMelody(MELODY_POWER_OFF, MELODY_POWER_OFF_LEN);
        lc.clearDisplay(0);
        setRGB(0, 0, 0);
        currentAnim = 0;
      }
      sendStatus();
      break;
    case IR_1: selectAnimation(1); break;
    case IR_2: selectAnimation(2); break;
    case IR_3: selectAnimation(3); break;
    case IR_4: selectAnimation(4); break;
    case IR_5: selectAnimation(5); break;
    case IR_6: selectAnimation(6); break;
    case IR_7: selectAnimation(7); break;
    case IR_8: selectAnimation(8); break;
    case IR_9: selectAnimation(9); break;
    case IR_0: selectAnimation(10); break; // shuffle
    case IR_VOLUP:
      if (animSpeed < 9) animSpeed++;
      sendStatus();
      break;
    case IR_VOLDN:
      if (animSpeed > 1) animSpeed--;
      sendStatus();
      break;
  }
}

// --- Handle Serial Commands from MATLAB ---
void handleSerial() {
  if (!Serial.available()) return;

  String cmd = Serial.readStringUntil('\n');
  cmd.trim();

  if (cmd.length() == 0) return;

  char cmdType = cmd.charAt(0);

  switch (cmdType) {
    case 'A': case 'a': {
      int anim = cmd.substring(1).toInt();
      if (anim >= 0 && anim <= 10) {
        if (!powerOn) { powerOn = true; }
        selectAnimation(anim);
      }
      break;
    }
    case 'S': case 's': {
      int spd = cmd.substring(1).toInt();
      if (spd >= 1 && spd <= 9) {
        animSpeed = spd;
        sendStatus();
      }
      break;
    }
    case 'C': case 'c': {
      // Parse C<r>,<g>,<b>
      int idx1 = cmd.indexOf(',');
      int idx2 = cmd.indexOf(',', idx1 + 1);
      if (idx1 > 0 && idx2 > 0) {
        int r = cmd.substring(1, idx1).toInt();
        int g = cmd.substring(idx1 + 1, idx2).toInt();
        int b = cmd.substring(idx2 + 1).toInt();
        r = constrain(r, 0, 255);
        g = constrain(g, 0, 255);
        b = constrain(b, 0, 255);
        setRGB(r, g, b);
        sendStatus();
      }
      break;
    }
    case 'P': case 'p': {
      powerOn = !powerOn;
      if (powerOn) {
        playMelody(MELODY_POWER_ON, MELODY_POWER_ON_LEN);
      } else {
        playMelody(MELODY_POWER_OFF, MELODY_POWER_OFF_LEN);
        lc.clearDisplay(0);
        setRGB(0, 0, 0);
        currentAnim = 0;
      }
      sendStatus();
      break;
    }
    case '?': {
      // Query current state
      sendStatus();
      break;
    }
  }
}

// --- Send status to MATLAB ---
// Format: S<anim>,<r>:<g>:<b>,<speed>,<power>\n
void sendStatus() {
  Serial.print("S");
  Serial.print(currentAnim);
  Serial.print(",");
  Serial.print(rgbR); Serial.print(":"); Serial.print(rgbG); Serial.print(":"); Serial.print(rgbB);
  Serial.print(",");
  Serial.print(animSpeed);
  Serial.print(",");
  Serial.println(powerOn ? 1 : 0);
}
