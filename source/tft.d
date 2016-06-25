module tftlcd;

import gpio.pinbyte;
import std.stdio;

struct TFTLCD
{
	GPIOPinByte dataPins;

	GPIOPin read;
	GPIOPin write;
	GPIOPin commandData;
	GPIOPin chipSelect;
}
