module tftlcd;

import gpio.pinbyte;

import core.thread;
import std.stdio;
import std.datetime;

struct TFTLCD
{
	GPIOPinByte dataPins;

	GPIOPin readPin;
	GPIOPin writePin;
	GPIOPin commandDataPin;
	GPIOPin chipSelectPin;

	void write(ubyte value) {
		dataPins.value = value;
		writePin.value = false;
		writePin.value = true;
	}

	ubyte read() {
		readPin.value = false;
		Thread.sleep(400.nsecs);
		auto result = dataPins.value;

		readPin.value = true;
		return result;
	}
}

@("read() should change write pin and wait at least 400 nS")
unittest
{
	auto tft = TFTLCD(GPIOPinByte([8, 9, 2, 3, 4, 5, 6, 7]), GPIOPin(10),
			GPIOPin(11), GPIOPin(12), GPIOPin(13));

	pinChanges[10] = 0;

	auto start = Clock.currTime();
	tft.read;
  auto end = Clock.currTime();

	assert(pinChanges[10] == 2);
	assert(end - start > 400.nsecs);
}

@("write() should change write pin")
unittest
{
	auto tft = TFTLCD(GPIOPinByte([8, 9, 2, 3, 4, 5, 6, 7]), GPIOPin(10),
			GPIOPin(11), GPIOPin(12), GPIOPin(13));

	pinChanges[11] = 0;

	tft.write(0);
	assert(pinChanges[11] == 2);
}
