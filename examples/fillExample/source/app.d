import tftlcd;
import gpio.pinbyte;

import std.stdio;

void main() {
  auto tft = TFTLCD(GPIOPinByte([5, 6, 13, 19, 26, 21, 20, 16]),
                    GPIOPin(2),
                    GPIOPin(3),
                    GPIOPin(4),
                    GPIOPin(17),
                    GPIOPin(12));

  tft.begin(240, 320);

  ushort color = 0;

  while(true) {
    writeln(color);
    tft.fillScreen(color);

    color++;
  }
}
