/*
 * animations.h - 8x8 LED Matrix bitmap frames for DJ Lightboard
 * Each animation is an array of frames, where each frame is 8 bytes (one per row).
 * Bit = 1 means LED on, MSB = leftmost column.
 */

#ifndef ANIMATIONS_H
#define ANIMATIONS_H

// --- Animation 1: Smiley Face (2 frames: open mouth / closed mouth) ---
const byte SMILEY[][8] = {
  { // Frame 0: open mouth smile
    B00111100,
    B01000010,
    B10100101,
    B10000001,
    B10100101,
    B10011001,
    B01000010,
    B00111100
  },
  { // Frame 1: closed mouth / wink
    B00111100,
    B01000010,
    B10100101,
    B10000001,
    B10111101,
    B10000001,
    B01000010,
    B00111100
  }
};
const int SMILEY_FRAMES = 2;

// --- Animation 2: Heart Beat (3 frames: small / medium / large) ---
const byte HEART[][8] = {
  { // Frame 0: small heart
    B00000000,
    B00000000,
    B00100100,
    B01011010,
    B01000010,
    B00100100,
    B00011000,
    B00000000
  },
  { // Frame 1: medium heart
    B00000000,
    B01100110,
    B11111111,
    B11111111,
    B11111111,
    B01111110,
    B00111100,
    B00011000
  },
  { // Frame 2: large heart (filled)
    B01100110,
    B11111111,
    B11111111,
    B11111111,
    B11111111,
    B01111110,
    B00111100,
    B00011000
  }
};
const int HEART_FRAMES = 3;

// --- Animation 3: Rain Drops (4 frames) ---
const byte RAIN[][8] = {
  {
    B10010000,
    B00000100,
    B01000001,
    B00010000,
    B10000010,
    B00100000,
    B00001000,
    B01000100
  },
  {
    B00001000,
    B01000100,
    B10010000,
    B00000100,
    B01000001,
    B00010000,
    B10000010,
    B00100000
  },
  {
    B10000010,
    B00100000,
    B00001000,
    B01000100,
    B10010000,
    B00000100,
    B01000001,
    B00010000
  },
  {
    B01000001,
    B00010000,
    B10000010,
    B00100000,
    B00001000,
    B01000100,
    B10010000,
    B00000100
  }
};
const int RAIN_FRAMES = 4;

// --- Animation 4: Scrolling "HI!" (5 frames for scroll effect) ---
const byte HI_SCROLL[][8] = {
  { // H
    B10000010,
    B10000010,
    B10000010,
    B11111110,
    B10000010,
    B10000010,
    B10000010,
    B00000000
  },
  { // I
    B00111000,
    B00010000,
    B00010000,
    B00010000,
    B00010000,
    B00010000,
    B00111000,
    B00000000
  },
  { // !
    B00010000,
    B00010000,
    B00010000,
    B00010000,
    B00010000,
    B00000000,
    B00010000,
    B00000000
  },
  { // smiley
    B00111100,
    B01000010,
    B10100101,
    B10000001,
    B10100101,
    B10011001,
    B01000010,
    B00111100
  },
  { // blank
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B00000000
  }
};
const int HI_SCROLL_FRAMES = 5;

// --- Animation 5: Star Twinkle (3 frames) ---
const byte STAR[][8] = {
  { // Frame 0: small star
    B00000000,
    B00010000,
    B00010000,
    B01010100,
    B00111000,
    B01010100,
    B00010000,
    B00010000
  },
  { // Frame 1: medium star
    B00010000,
    B00010000,
    B00010000,
    B11111110,
    B00111000,
    B01000100,
    B10000010,
    B00000000
  },
  { // Frame 2: bright star burst
    B10010010,
    B01010100,
    B00111000,
    B11111110,
    B00111000,
    B01010100,
    B10010010,
    B00000000
  }
};
const int STAR_FRAMES = 3;

// --- Animation 6: Snake Pattern (8 frames) ---
const byte SNAKE[][8] = {
  {
    B11111111,
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B00000000
  },
  {
    B00000001,
    B11111111,
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B00000000
  },
  {
    B00000000,
    B00000001,
    B11111111,
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B00000000
  },
  {
    B00000000,
    B00000000,
    B00000001,
    B11111111,
    B00000000,
    B00000000,
    B00000000,
    B00000000
  },
  {
    B00000000,
    B00000000,
    B00000000,
    B10000000,
    B11111111,
    B00000000,
    B00000000,
    B00000000
  },
  {
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B10000000,
    B11111111,
    B00000000,
    B00000000
  },
  {
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B10000000,
    B11111111,
    B00000000
  },
  {
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B00000000,
    B10000000,
    B11111111
  }
};
const int SNAKE_FRAMES = 8;

// --- Animation 7: Fireworks Burst (4 frames) ---
const byte FIREWORKS[][8] = {
  { // Frame 0: center dot
    B00000000,
    B00000000,
    B00000000,
    B00011000,
    B00011000,
    B00000000,
    B00000000,
    B00000000
  },
  { // Frame 1: small burst
    B00000000,
    B00000000,
    B00011000,
    B00100100,
    B00100100,
    B00011000,
    B00000000,
    B00000000
  },
  { // Frame 2: medium burst
    B00000000,
    B00100100,
    B01000010,
    B10000001,
    B10000001,
    B01000010,
    B00100100,
    B00000000
  },
  { // Frame 3: full burst
    B10000001,
    B01000010,
    B00100100,
    B00000000,
    B00000000,
    B00100100,
    B01000010,
    B10000001
  }
};
const int FIREWORKS_FRAMES = 4;

// --- Animation 8: Spinning Wheel (4 frames) ---
const byte SPINNER[][8] = {
  { // Frame 0: horizontal
    B00000000,
    B00000000,
    B00000000,
    B11111111,
    B11111111,
    B00000000,
    B00000000,
    B00000000
  },
  { // Frame 1: diagonal
    B10000000,
    B01000000,
    B00100000,
    B00010000,
    B00001000,
    B00000100,
    B00000010,
    B00000001
  },
  { // Frame 2: vertical
    B00011000,
    B00011000,
    B00011000,
    B00011000,
    B00011000,
    B00011000,
    B00011000,
    B00011000
  },
  { // Frame 3: other diagonal
    B00000001,
    B00000010,
    B00000100,
    B00001000,
    B00010000,
    B00100000,
    B01000000,
    B10000000
  }
};
const int SPINNER_FRAMES = 4;

// --- Animation 9: Arrow Cycling (4 frames: up, right, down, left) ---
const byte ARROWS[][8] = {
  { // Up arrow
    B00011000,
    B00111100,
    B01111110,
    B11011011,
    B00011000,
    B00011000,
    B00011000,
    B00011000
  },
  { // Right arrow
    B00010000,
    B00011000,
    B00011100,
    B11111110,
    B11111110,
    B00011100,
    B00011000,
    B00010000
  },
  { // Down arrow
    B00011000,
    B00011000,
    B00011000,
    B00011000,
    B11011011,
    B01111110,
    B00111100,
    B00011000
  },
  { // Left arrow
    B00001000,
    B00011000,
    B00111000,
    B01111111,
    B01111111,
    B00111000,
    B00011000,
    B00001000
  }
};
const int ARROWS_FRAMES = 4;

#endif
