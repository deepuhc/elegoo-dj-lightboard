# Pin Map - DJ Lightboard

## Arduino Mega 2560 Pin Assignments

| Pin | Component         | Type   | Notes                          |
|-----|-------------------|--------|--------------------------------|
| 2   | IR Receiver       | Digital| Interrupt-capable (INT4)       |
| 3   | RGB LED - Blue    | PWM    | 220Ω resistor to LED cathode   |
| 5   | RGB LED - Green   | PWM    | 220Ω resistor to LED cathode   |
| 6   | RGB LED - Red     | PWM    | 220Ω resistor to LED cathode   |
| 8   | Passive Buzzer    | Digital| Direct connection               |
| 10  | MAX7219 CLK       | Digital| SPI Clock                      |
| 11  | MAX7219 CS        | Digital| Chip Select / LOAD             |
| 12  | MAX7219 DIN       | Digital| SPI Data In                    |
| GND | Common Ground     | Power  | Shared by all components       |
| 5V  | Component Power   | Power  | Shared by IR receiver, MAX7219 |

## Wiring Summary

### RGB LED (Common Cathode)
- Red leg → 220Ω resistor → Pin 6
- Green leg → 220Ω resistor → Pin 5
- Blue leg → 220Ω resistor → Pin 3
- Common cathode (longest leg) → GND

### MAX7219 LED Matrix Module
- VCC → 5V
- GND → GND
- DIN → Pin 12
- CS  → Pin 11
- CLK → Pin 10

### IR Receiver (AX-1838HS)
- Signal (S) → Pin 2
- VCC (+)   → 5V
- GND (-)   → GND

### Passive Buzzer
- Positive (+) → Pin 8
- Negative (-) → GND
