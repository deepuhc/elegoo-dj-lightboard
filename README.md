# DJ Lightboard

**IR Remote-controlled LED matrix animations with a MATLAB live dashboard.**

Press buttons on the IR remote to trigger pixel-art animations on an 8x8 LED matrix, each with matching sound effects and RGB mood lighting. Connect MATLAB for a full GUI dashboard with real-time visualization.

Built with the [ELEGOO Most Complete Starter Kit for Arduino Mega](https://www.elegoo.com/).

## Demo

| IR Remote Mode | MATLAB Dashboard |
|---|---|
| Press buttons, see animations! | Live control + visualization |

> *Photos/GIF coming soon after first build!*

## Features

- **9 animations**: Smiley, Heart, Rain, HI!, Star, Snake, Fireworks, Spinner, Arrows
- **Shuffle mode**: Auto-cycles through all animations (button 0)
- **Speed control**: VOL+/VOL- on the remote, or MATLAB slider
- **RGB mood lighting**: Each animation has a preset color, or set custom via MATLAB
- **MATLAB Dashboard**: Real-time 8x8 matrix visualization, animation picker, color control, activity log
- **Dual mode**: Works standalone with IR remote, or enhanced with MATLAB connected

## Components

All from the ELEGOO Mega Starter Kit -- no extra purchases needed.

| Component | Quantity |
|---|---|
| ELEGOO Mega 2560 | 1 |
| MAX7219 8x8 LED Dot Matrix | 1 |
| IR Remote + IR Receiver (AX-1838HS) | 1 |
| Passive Buzzer | 1 |
| RGB LED (Common Cathode) | 1 |
| 220 Ohm Resistors | 3 |
| Breadboard (830 tie-points) | 1 |
| Jumper Wires | ~15 |
| USB Cable (Type-B) | 1 |

## Wiring

```
Arduino Mega 2560
   ├── Pin 2  ──── IR Receiver (Signal)
   ├── Pin 3  ──── 220Ω ──── RGB LED Blue
   ├── Pin 5  ──── 220Ω ──── RGB LED Green
   ├── Pin 6  ──── 220Ω ──── RGB LED Red
   ├── Pin 8  ──── Passive Buzzer (+)
   ├── Pin 10 ──── MAX7219 CLK
   ├── Pin 11 ──── MAX7219 CS
   ├── Pin 12 ──── MAX7219 DIN
   ├── 5V     ──── IR Receiver VCC, MAX7219 VCC
   └── GND    ──── All component grounds
```

See [docs/pin_map.md](docs/pin_map.md) for detailed wiring instructions.

## Setup

### 1. Arduino IDE

1. Install [Arduino IDE](https://www.arduino.cc/en/software) (2.0+)
2. Connect the ELEGOO Mega 2560 via USB
3. In Arduino IDE: **Tools > Board > Arduino Mega or Mega 2560**
4. Select the correct port under **Tools > Port**
5. Install libraries (from the kit's `Libraries/` folder or Library Manager):
   - `IRremote`
   - `LedControl`
6. Open `arduino/dj_lightboard/dj_lightboard.ino`
7. Click **Upload**

### 2. MATLAB Dashboard (optional)

Requirements:
- MATLAB R2022a or later
- Instrument Control Toolbox (for `serialport`)

```matlab
cd matlab/
dj_dashboard()   % Auto-detects Arduino, opens GUI
```

## IR Remote Button Map

| Button | Animation | RGB Color |
|---|---|---|
| 1 | Smiley | Yellow |
| 2 | Heart | Red |
| 3 | Rain | Blue |
| 4 | HI! | Green |
| 5 | Star | White |
| 6 | Snake | Purple |
| 7 | Fireworks | Orange |
| 8 | Spinner | Cyan |
| 9 | Arrows | Magenta |
| 0 | Shuffle All | Rainbow |
| VOL+ | Speed Up | -- |
| VOL- | Slow Down | -- |
| POWER | On/Off | -- |

## Serial Protocol

The Arduino and MATLAB communicate over USB serial (9600 baud) using a simple text protocol. See [docs/serial_protocol.md](docs/serial_protocol.md) for the full spec.

## Project Structure

```
elegoo-dj-lightboard/
├── arduino/dj_lightboard/     # Arduino firmware
│   ├── dj_lightboard.ino      # Main sketch
│   ├── animations.h           # 8x8 bitmap frames
│   ├── melodies.h             # Sound effects
│   └── pitches.h              # Note frequencies
├── matlab/                    # MATLAB dashboard
│   ├── dj_dashboard.m         # Main GUI
│   └── setup_arduino.m        # Port detection helper
├── docs/                      # Documentation
│   ├── pin_map.md             # Wiring reference
│   └── serial_protocol.md    # Communication protocol
└── README.md
```

## Kit Reference

This project uses components and lessons from the ELEGOO Most Complete Starter Kit for Mega:
- Lesson 4: RGB LED
- Lesson 7: Passive Buzzer
- Lesson 14: IR Receiver Module
- Lesson 15: MAX7219 LED Dot Matrix Module

Video tutorials: [ELEGOO YouTube Playlist](https://www.youtube.com/playlist?list=PLkFeYZKRTZ8abqae2cQZ1-ztcuZuIt4G7)

## License

MIT
