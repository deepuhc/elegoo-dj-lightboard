/*
 * IR Receiver Test - Prints button codes when you press the remote
 * IR Receiver on Pin 2
 */

#include <IRremote.h>

#define IR_PIN 2

void setup() {
  Serial.begin(9600);
  IrReceiver.begin(IR_PIN, ENABLE_LED_FEEDBACK);
  Serial.println("IR Receiver Test - Point the remote at the sensor and press buttons!");
  Serial.println("Watch for hex codes below:");
  Serial.println("---");
}

void loop() {
  if (IrReceiver.decode()) {
    if (IrReceiver.decodedIRData.decodedRawData != 0) {
      Serial.print("Button pressed! Code: 0x");
      Serial.println(IrReceiver.decodedIRData.decodedRawData, HEX);
    }
    IrReceiver.resume();
  }
}
