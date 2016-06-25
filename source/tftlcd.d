module tftlcd;

import gpio.pinbyte;

import core.thread;
import std.stdio;
import std.datetime;

//ILI9341

struct TFTLCD
{
	enum Registers : ubyte
	{
		softReset = 0x01,
		sleepIn = 0x10,
		sleepOut = 0x11,
		normalDisplay = 0x13,
		invertOff = 0x20,
		invertOn = 0x21,
		gammaSet = 0x26,
		displayOff = 0x28,
		displayOn = 0x29,
		columnAddressSet = 0x2A,
		pageAddressSet = 0x2B,
		memmoryWrite = 0x2C,
		pixelFormat = 0x3A,
		frameControl = 0xB1,
		displayFunc = 0xB6,
		entryMode = 0xB7,
		powerControl1 = 0xC0,
		powerControl2 = 0xC1,
		vComControl1 = 0xC5,
		vComControl2 = 0xC7,
		memmoryControl = 0x36,
		madControl = 0x36,

		madControlMY = 0x80,
		madControlMX = 0x40,
		madControlMV = 0x20,
		madControlML = 0x10,
		madControlRGB = 0x00,
		madControlBGR = 0x08,
		madControlMH = 0x04,
	}

	GPIOPinByte dataPins;

	GPIOPin readPin;
	GPIOPin writePin;
	GPIOPin commandDataPin;
	GPIOPin chipSelectPin;

	int width;
	int height;

	void begin(int width, int height)
	{
		chipSelectPin.value = false;

		writeRegister(Registers.softReset, 0);
		Thread.sleep(50.msecs);
		writeRegister(Registers.displayOff, 0);

		writeRegister(Registers.powerControl1, 0x23);
		writeRegister(Registers.powerControl2, 0x10);
		writeRegister16(Registers.vComControl1, 0x2B2B);
		writeRegister(Registers.vComControl2, 0xC0);
		writeRegister(Registers.memmoryControl, Registers.madControlMY | Registers.madControlBGR);
		writeRegister(Registers.pixelFormat, 0x55);
		writeRegister16(Registers.frameControl, 0x001B);

		writeRegister(Registers.entryMode, 0x07);
		writeRegister(Registers.sleepOut, 0);

		Thread.sleep(150.msecs);
		writeRegister(Registers.displayOff, 0);

		Thread.sleep(500.msecs);
		setAddrWindow(0, 0, width - 1, height - 1);

		this.width = width;
		this.height = height;
	}

	void fillScreen(ushort color)
	{
		setAddrWindow(0, 0, width - 1, height - 1);
		flood(color, width * height);
	}

	void flood(ushort color, int len)
	{
		immutable ubyte hi = cast(ubyte)(color >> 8), lo = cast(ubyte) color;

		chipSelectPin.value = false;

		commandDataPin.value = true;
		writeRegister(Registers.memmoryWrite, 0);

		foreach (i; 0 .. len)
		{
			write(hi);
			write(lo);
		}

		chipSelectPin.value = true;
	}

	void setAddrWindow(uint x1, uint y1, uint x2, uint y2)
	{
		chipSelectPin.value = false;
		uint value;

		value = x1;
		value <<= 16;
		value |= x2;
		writeRegister32(Registers.columnAddressSet, value);

		value = y1;
		value <<= 16;
		value |= y2;
		writeRegister32(Registers.pageAddressSet, value);

		chipSelectPin.value = true;
	}

	void write(ubyte value)
	{
		dataPins.value = value;
		writePin.value = false;
		writePin.value = true;
	}

	ubyte read()
	{
		readPin.value = false;
		Thread.sleep(400.nsecs);
		auto result = dataPins.value;

		readPin.value = true;
		return result;
	}

	void writeRegister(ubyte command, ubyte value)
	{
		commandDataPin.value = false;
		write(command);
		commandDataPin.value = true;
		write(value);
	}

	void writeRegister16(ubyte command, ushort value)
	{
		ubyte hi, lo;

		commandDataPin.value = false;
		write(command);

		hi = cast(ubyte)(value >> 8);
		lo = cast(ubyte) value;
		commandDataPin.value = true;
		write(hi);
		write(lo);
	}

	void writeRegister32(ubyte command, int value)
	{
		ubyte hi, lo;

		commandDataPin.value = false;
		write(command);

		commandDataPin.value = true;
		write(cast(ubyte)(value >> 24));
		write(cast(ubyte)(value >> 16));
		write(cast(ubyte)(value >> 8));
		write(cast(ubyte) value);
	}
}

@("read() should change write pin and wait at least 400 nS")
unittest
{
	auto tft = TFTLCD(GPIOPinByte([8, 9, 2, 3, 4, 5, 6, 7]), GPIOPin(10),
			GPIOPin(11), GPIOPin(12), GPIOPin(13));

	pinChanges[10] = 0;

	auto const start = Clock.currTime();
	tft.read;
	auto const end = Clock.currTime();

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