/*
 * melodies.h - Sound effects for each animation
 * Each melody is an array of {note, duration_ms} pairs.
 * Use 0 for note to indicate a rest/pause.
 */

#ifndef MELODIES_H
#define MELODIES_H

#include "pitches.h"

struct NoteEntry {
  int note;
  int duration;
};

// --- Melody 1: Happy Jingle (Smiley) ---
const NoteEntry MELODY_HAPPY[] = {
  {NOTE_C5, 100}, {NOTE_E5, 100}, {NOTE_G5, 100}, {NOTE_C6, 200}
};
const int MELODY_HAPPY_LEN = 4;

// --- Melody 2: Heartbeat (Heart) ---
const NoteEntry MELODY_HEARTBEAT[] = {
  {NOTE_C4, 80}, {NOTE_C4, 80}, {0, 300}
};
const int MELODY_HEARTBEAT_LEN = 3;

// --- Melody 3: Rain Patter ---
const NoteEntry MELODY_RAIN[] = {
  {NOTE_E6, 30}, {0, 70}, {NOTE_D6, 30}, {0, 120},
  {NOTE_E6, 30}, {0, 50}, {NOTE_B5, 30}, {0, 100}
};
const int MELODY_RAIN_LEN = 8;

// --- Melody 4: Greeting Tone (HI!) ---
const NoteEntry MELODY_GREETING[] = {
  {NOTE_G5, 150}, {NOTE_B5, 150}, {NOTE_D6, 300}
};
const int MELODY_GREETING_LEN = 3;

// --- Melody 5: Sparkle Sound (Star) ---
const NoteEntry MELODY_SPARKLE[] = {
  {NOTE_E7, 50}, {NOTE_G7, 50}, {NOTE_E7, 50}, {0, 50}, {NOTE_B6, 100}
};
const int MELODY_SPARKLE_LEN = 5;

// --- Melody 6: Game Beep (Snake) ---
const NoteEntry MELODY_GAME[] = {
  {NOTE_A5, 50}, {0, 30}, {NOTE_A5, 50}
};
const int MELODY_GAME_LEN = 3;

// --- Melody 7: Boom Sound (Fireworks) ---
const NoteEntry MELODY_BOOM[] = {
  {NOTE_C3, 50}, {NOTE_E3, 50}, {NOTE_G3, 50},
  {NOTE_C4, 50}, {NOTE_E4, 50}, {NOTE_G4, 50}, {NOTE_C5, 200}
};
const int MELODY_BOOM_LEN = 7;

// --- Melody 8: Whir Sound (Spinner) ---
const NoteEntry MELODY_WHIR[] = {
  {NOTE_C5, 40}, {NOTE_D5, 40}, {NOTE_E5, 40}, {NOTE_F5, 40},
  {NOTE_G5, 40}, {NOTE_A5, 40}, {NOTE_B5, 40}, {NOTE_C6, 40}
};
const int MELODY_WHIR_LEN = 8;

// --- Melody 9: Click Sounds (Arrows) ---
const NoteEntry MELODY_CLICK[] = {
  {NOTE_A6, 30}, {0, 50}
};
const int MELODY_CLICK_LEN = 2;

// --- Power chime ---
const NoteEntry MELODY_POWER_ON[] = {
  {NOTE_C5, 100}, {NOTE_E5, 100}, {NOTE_G5, 200}
};
const int MELODY_POWER_ON_LEN = 3;

const NoteEntry MELODY_POWER_OFF[] = {
  {NOTE_G5, 100}, {NOTE_E5, 100}, {NOTE_C5, 200}
};
const int MELODY_POWER_OFF_LEN = 3;

#endif
