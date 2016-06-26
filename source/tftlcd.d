module tftlcd;

import gpio.pinbyte;

import core.thread;
import std.stdio;
import std.datetime;
import std.conv;

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
	GPIOPin resetPin;

	int width;
	int height;

	void hardReset() {
		writePin.value = true;
		readPin.value = true;
		chipSelectPin.value = false;
		commandDataPin.value = false;
		resetPin.value = false;

		dataPins.value = 0;
		log("reset");
		Thread.sleep(120.msecs);
		resetPin.value = true;

		log("reset");
		Thread.sleep(120.msecs);

		writePin.value = false;
		writePin.value = true;

		writePin.value = false;
		writePin.value = true;

		writePin.value = false;
		writePin.value = true;

		writePin.value = false;
		writePin.value = true;

		Thread.sleep(200.msecs);
	}

	void begin(int width, int height)
	{

		Thread.sleep(200.msecs);

		hardReset;

		//begin
/*
		writeRegister(Registers.softReset, 0);
		Thread.sleep(50.msecs);
		writeRegister(Registers.displayOff, 0);
		writeRegister(Registers.sleepOut, 0);

		writeRegister(Registers.powerControl1, 0x23);
		writeRegister(Registers.powerControl2, 0x10);
		writeRegister16(Registers.vComControl1, 0x3E28);
		writeRegister(Registers.vComControl2, 0x86);
		writeRegister(Registers.memmoryControl, Registers.madControlMY | Registers.madControlBGR);
		writeRegister(Registers.pixelFormat, 0x55);
		writeRegister16(Registers.frameControl, 0x001B);

		writeRegister(Registers.entryMode, 0x07);

		Thread.sleep(150.msecs);
		writeRegister(Registers.displayOn, 0);

		Thread.sleep(500.msecs);
		setAddrWindow(0, 0, width - 1, height - 1);*/

		tft_command_write(Registers.softReset);
		Thread.sleep(50.msecs);
		tft_command_write(0x28); //display OFF

		tft_command_write(0xC0); //power control 1
		tft_data_write(0x26);
		tft_data_write(0x04); //second parameter for ILI9340 (ignored by ILI9341)
		tft_command_write(0xC1); //power control 2
		tft_data_write(0x11);

		tft_command_write(0xC5); //VCOM control 1
		tft_data_write(0x35);
		tft_data_write(0x3E);
		tft_command_write(0xC7); //VCOM control 2
		tft_data_write(0xBE);

		tft_command_write(0x36); //memory access control = BGR
		tft_data_write(0x88);

		tft_command_write(0x3A); //pixel format = 16 bit per pixel
		tft_data_write(0x55);

		tft_command_write(0xB1); //frame rate control
		tft_data_write(0x00);
		tft_data_write(0x1B);

		tft_command_write(Registers.entryMode); //entry mode
		tft_data_write(0x07);

		tft_command_write(Registers.sleepOut);
		Thread.sleep(150.msecs);

		setAddrWindow(0, 0, width - 1, height - 1);

		tft_command_write(Registers.displayOn);
		Thread.sleep(500.msecs);

/*
		tft_command_write(0x11); //exit SLEEP mode
		tft_data_write(0x00);
		tft_command_write(0xCB); //Power Control A
		tft_data_write(0x39); //always 0x39
		tft_data_write(0x2C); //always 0x2C
		tft_data_write(0x00); //always 0x
		tft_data_write(0x34); //Vcore = 1.6V
		tft_data_write(0x02); //DDVDH = 5.6V
		tft_command_write(0xCF); //Power Control B
		tft_data_write(0x00); //always 0x
		tft_data_write(0x81); //PCEQ off
		tft_data_write(0x30); //ESD protection
		tft_command_write(0xE8); //Driver timing control A
		tft_data_write(0x85); //non‐overlap
		tft_data_write(0x01); //EQ timing
		tft_data_write(0x79); //Pre‐charge timing
		tft_command_write(0xEA); //Driver timing control B
		tft_data_write(0x00); //Gate driver timing
		tft_data_write(0x00); //always 0x
		tft_command_write(0xED); //Power‐On sequence control
		tft_data_write(0x64); //soft start
		tft_data_write(0x03); //power on sequence
		tft_data_write(0x12); //power on sequence
		tft_data_write(0x81); //DDVDH enhance on
		tft_command_write(0xF7); //Pump ratio control
		tft_data_write(0x20); //DDVDH=2xVCI
		tft_command_write(0xC0); //power control 1
		tft_data_write(0x26);
		tft_data_write(0x04); //second parameter for ILI9340 (ignored by ILI9341)
		tft_command_write(0xC1); //power control 2
		tft_data_write(0x11);
		tft_command_write(0xC5); //VCOM control 1
		tft_data_write(0x35);
		tft_data_write(0x3E);
		tft_command_write(0xC7); //VCOM control 2
		tft_data_write(0xBE);
		tft_command_write(0x36); //memory access control = BGR
		tft_data_write(0x88);
		tft_command_write(0xB1); //frame rate control
		tft_data_write(0x00);
		tft_data_write(0x10);
		tft_command_write(0xB6); //display function control
		tft_data_write(0x0A);
		tft_data_write(0xA2);
		tft_command_write(0x3A); //pixel format = 16 bit per pixel
		tft_data_write(0x55);
		tft_command_write(0xF2); //3G Gamma control
		tft_data_write(0x02); //off
		tft_command_write(0x26); //Gamma curve 3
		tft_data_write(0x01);
		tft_command_write(0x2A); //column address set
		tft_data_write(0x00);
		tft_data_write(0x00); //start 0x00
		tft_data_write(0x00);
		tft_data_write(0xEF); //end 0xEF
		tft_command_write(0x2B); //page address set
		tft_data_write(0x00);
		tft_data_write(0x00); //start 0x00
		tft_data_write(0x01);
		tft_data_write(0x3F); //end 0x013F

		tft_command_write(0x29); //display ON
*/
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
		/*immutable ubyte hi = cast(ubyte)(color >> 8), lo = cast(ubyte) color;

		commandDataPin.value = true;

		write(Registers.memmoryWrite);

		commandDataPin.value = false;

		// Write first pixel normally, decrement counter by 1
		write(hi);
		write(lo);
		len--;

		auto blocks = len / 64; // 64 pixels/block
		auto i = 0;

		while (blocks--)
		{
			i = 16; // 64 pixels/block / 4 pixels/pass
			do
			{
				write(hi);
				write(lo);
				write(hi);
				write(lo);
				write(hi);
				write(lo);
				write(hi);
				write(lo);
			}
			while (--i);
		}
		for (i = len & 63; i--;)
		{
			write(hi);
			write(lo);
		}*/

		tft_command_write(0x2C);

		for(int y=0;y < width ;y++){
			for(int x=0;x < height ;x++){
				auto t = color;

				tft_data_write(cast(ubyte) (t << 8));
				tft_data_write(cast(ubyte) t);
			}
		}
	}

	void setAddrWindow(uint x1, uint y1, uint x2, uint y2)
	{
		uint value;

		value = x1;
		value <<= 16;
		value |= x2;
		writeRegister32(Registers.columnAddressSet, value);

		value = y1;
		value <<= 16;
		value |= y2;
		writeRegister32(Registers.pageAddressSet, value);
	}

	void write(ubyte value)
	{
		dataPins.value = value;
		log("write data pins");
		writePin.value = false;
		log("write pin");
		writePin.value = true;
		log("write pin");
	}

	ubyte read()
	{
		readPin.value = false;
		Thread.sleep(400.nsecs);
		auto result = dataPins.value;

		readPin.value = true;
		return result;
	}

	void tft_command_write(ubyte command) {
		commandDataPin.value = false;
		log("tft_command_write " ~ command.to!string);
    write(command);
	}

	void tft_data_write(ubyte data)
	{
	    commandDataPin.value = true;
			log("tft_data_write");
	    write(data);
	}
/*
	void writeRegister(ubyte command)
	{
		commandDataPin.value = false;
		write(command);
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

		hi = cast(ubyte)(command >> 8);
		lo = cast(ubyte) command;

		commandDataPin.value = false;
		write(hi);
		write(lo);

		hi = cast(ubyte)(value >> 8);
		lo = cast(ubyte) value;
		commandDataPin.value = true;
		write(hi);
		write(lo);
	}
*/
	void writeRegister32(ubyte command, int value)
	{
		tft_command_write(command);

		tft_data_write(cast(ubyte)(value >> 24));
		tft_data_write(cast(ubyte)(value >> 16));
		tft_data_write(cast(ubyte)(value >> 8));
		tft_data_write(cast(ubyte) value);
	}

	void log(string msg = "?") {
		std.stdio.write("RD ");
		readPin.log;

		std.stdio.write(" WR ");
		writePin.log;

		std.stdio.write(" CD ");
		commandDataPin.log;

		std.stdio.write(" CS ");
		chipSelectPin.log;

		std.stdio.write(" RST ");
		resetPin.log;

		std.stdio.write(" DATA ");
		dataPins.log;

		std.stdio.write(" : ", msg);

		std.stdio.writeln;
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
