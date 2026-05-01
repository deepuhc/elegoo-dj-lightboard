# Serial Protocol - DJ Lightboard

Communication between MATLAB and Arduino over USB Serial at **9600 baud**.

## Commands (MATLAB → Arduino)

| Command | Format | Description | Example |
|---------|--------|-------------|---------|
| Animation | `A<n>\n` | Play animation (1-9), shuffle (10), stop (0) | `A3\n` = Rain |
| Speed | `S<n>\n` | Set speed 1 (slow) to 9 (fast) | `S7\n` |
| Color | `C<r>,<g>,<b>\n` | Set RGB LED (0-255 each) | `C255,0,128\n` |
| Power | `P\n` | Toggle power on/off | `P\n` |
| Query | `?\n` | Request current state | `?\n` |

## Status (Arduino → MATLAB)

Sent on every state change (IR remote press or serial command).

**Format:** `S<anim>,<r>:<g>:<b>,<speed>,<power>\n`

| Field | Values | Description |
|-------|--------|-------------|
| anim | 0-10 | Current animation (0=none, 1-9=specific, 10=shuffle) |
| r:g:b | 0-255 each | Current RGB LED color |
| speed | 1-9 | Current animation speed |
| power | 0 or 1 | Power state |

**Example:** `S3,0:50:255,5,1\n` = Rain animation, blue LED, speed 5, power on

## Animation Map

| ID | Name | IR Button | Sound |
|----|------|-----------|-------|
| 1 | Smiley | 1 | Happy jingle |
| 2 | Heart | 2 | Heartbeat |
| 3 | Rain | 3 | Rain patter |
| 4 | HI! | 4 | Greeting tone |
| 5 | Star | 5 | Sparkle |
| 6 | Snake | 6 | Game beep |
| 7 | Fireworks | 7 | Boom |
| 8 | Spinner | 8 | Whir |
| 9 | Arrows | 9 | Click |
| 10 | Shuffle | 0 | Mixed |
