import tftlcd;
import gpio.pinbyte;

import std.stdio;

void main() {
  auto tft = TFTLCD(GPIOPinByte([8, 9, 2, 3, 4, 5, 6, 7]),
                    GPIOPin(10),
                    GPIOPin(11),
                    GPIOPin(12),
                    GPIOPin(13));

  tft.begin(240, 320);

  ushort color = 0;

  while(true) {
    writeln(color);
    tft.fillScreen(color);

    color++;
  }
}
