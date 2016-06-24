module tftlcd;

import gpio;
import std.stdio;

struct TFTLCD
{
	GPIOPin[8] dataPins;

	GPIOPin read;
	GPIOPin write;
	GPIOPin commandData;
	GPIOPin chipSelect;

	void setReadDirection()
	{
		foreach (pin; dataPins)
		{
			pin.direction = PinDirection.input;
		}
	}

	void setWriteDirection()
	{
		foreach (pin; dataPins)
		{
			pin.direction = PinDirection.output;
		}
	}
}

@("Set read and write direction")
unittest
{
	auto tft = TFTLCD([GPIOPin(8), GPIOPin(9), GPIOPin(2), GPIOPin(3),
			GPIOPin(4), GPIOPin(5), GPIOPin(6), GPIOPin(7)], GPIOPin(10),
			GPIOPin(11), GPIOPin(12), GPIOPin(13));

	tft.setReadDirection();

	foreach (pin; tft.dataPins)
	{
		assert(pin.direction == PinDirection.input);
	}

	tft.setWriteDirection();

	foreach (pin; tft.dataPins)
	{
		assert(pin.direction == PinDirection.output);
	}
}
