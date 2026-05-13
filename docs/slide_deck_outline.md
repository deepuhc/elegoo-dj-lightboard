# Slide Deck: MATLAB + Arduino Hardware Integration

## Slide 1: Title
**"From Software to Hardware: MATLAB-Powered Proximity Alert"**
- Your name
- Date
- Tagline: "How a software engineer built a real-time sensor system using MATLAB and Arduino"

## Slide 2: The Challenge
- Software engineers rarely touch hardware
- Goal: Build something interactive, visual, and fun
- Constraint: Use MATLAB as the control/visualization layer

## Slide 3: Hardware Components
- Photo/diagram of the setup
- Arduino Mega 2560 (microcontroller)
- HC-SR04 Ultrasonic Sensor (distance measurement)
- RGB LED (visual feedback)
- Passive Buzzer (audio feedback)
- Total cost: ~$50 (ELEGOO kit)

## Slide 4: Architecture Overview
Two approaches demonstrated:

```
Approach A: Arduino as Brain          Approach B: MATLAB as Brain
┌─────────┐   serial    ┌──────┐    ┌─────────┐  USB/HW   ┌──────┐
│ Arduino │ ──────────► │MATLAB│    │ Arduino │ ◄────────► │MATLAB│
│ (logic) │   data only │(viz) │    │ (I/O)   │  commands  │(logic│
└─────────┘             └──────┘    └─────────┘            │+ viz)│
                                                           └──────┘
proximity_dashboard.m               proximity_direct.m
```

## Slide 5: Approach A — Serial Communication
- Arduino runs custom firmware with sensor logic
- Sends "Distance: XX cm" over USB serial at 9600 baud
- MATLAB reads serial stream, parses data, updates GUI
- **Advantage:** Arduino works standalone; MATLAB enhances
- Code snippet: `s = serialport("/dev/cu.usbmodem12101", 9600)`

## Slide 6: Approach B — MATLAB Support Package for Arduino
- MATLAB directly controls hardware pins
- `a = arduino()` — connects and configures board
- `writePWMDutyCycle(a, 'D6', 0.8)` — set LED brightness
- `readDigitalPin(a, 'D4')` — read sensor
- **Advantage:** Rapid prototyping, full MATLAB power (signal processing, ML, etc.)
- **Trade-off:** Slower loop rate due to USB round-trips

## Slide 7: The Dashboard (Screenshot)
- Live scrolling distance plot
- Color-coded zone indicator
- Distance gauge with threshold markers
- Statistics panel (min, max, avg, sample rate)
- Export to CSV for further analysis

## Slide 8: Key MATLAB Features Used
| Feature | How We Used It |
|---------|---------------|
| `serialport()` | Real-time Arduino communication |
| `uifigure` / App Designer | Interactive dashboard GUI |
| `timer` object | Non-blocking periodic data reads |
| `writePWMDutyCycle` | Direct hardware control |
| Data export (`writetable`) | CSV logging for analysis |
| Real-time plotting | Animated line + gauge |

## Slide 9: Demo
- Live demo: wave hand in front of sensor
- Show dashboard updating in real-time
- Show CSV export + quick data analysis plot

## Slide 10: What I Learned
- Hardware is more forgiving than you'd think (except reversed polarity!)
- Serial communication is the easiest bridge between HW and SW
- MATLAB's Support Package makes prototyping fast
- Two architectures serve different needs:
  - Firmware approach → reliable, standalone, fast
  - MATLAB-direct approach → flexible, great for experimentation

## Slide 11: What's Next
- Add LED matrix for visual animations
- Machine Learning: train a gesture classifier from distance patterns
- Signal processing: filter noisy sensor data in MATLAB
- Replace ultrasonic with LIDAR for higher precision

## Slide 12: Resources & Links
- GitHub repo: github.com/deepuhc/elegoo-dj-lightboard
- MATLAB Support Package for Arduino: mathworks.com/hardware-support/arduino-matlab.html
- ELEGOO Kit tutorials: [YouTube playlist link]
