# Symbolics Console Decoder - Terasic Cyclone V GX 

**Copyright 2022 Douglas P. Fields, Jr. All Rights Reserved.**

Decode the output from a Symbolics 19" Console to the CPU using
a Terasic Cyclone V GX Starter Kit board and a 
Digilent RS-422 PMOD.

## Signal Information

The signal is RS-422 based, but uses a Biphase encoding.
* Marking (1) is a long pulse either high or low
* Spacing (0) is a pair of shorrt pulses, either high then low or vice versa

This allows a clock to be recovered from the signal.

Per the 19" Console Mantenance Guide (August 1991):
* "75 Kbaud bidirectional link over a serial line"
* Two pairs of "Serial biphase" for txd and rxd to/from console
* Also: 75 ohm coax line for "phase encoded video"

Per the 19" Premium Console Hardware Technical Support Maintenance Guide
(November 1993):
* "receives keyboard codes, mouse clicks, and mouse movements, translates
  them to Lisp Machine keycodes, and sends them via RS422 serial out the console
  port."

## Timings

75 "KBaud" means 13⅓ μs per bit.

Measurements with the oscilloscope:
* Short biphase pulse: ~6.4 μs
* 2x Long biphase pulse: ~26 μs
* Oscilloscope measured frequency: 38.5KHz; period: 26.00 μs
* Long pulses when no input - so this is likely "marking" (logic 1)

![Short biphase pulse](DS1Z_QuickPrint59.png)*Short biphase pulse*

![Two long biphase pulses](DS1Z_QuickPrint60.png)*Two long biphase pulses*

Conclusions:
* Use 6 μs for the minimum length of a short pulse and 2x that for long pulse
* Ignore pulses that go, say, 3x the length of the short pulse
* Ignore pulses that go less than, say, 0.5 μs
* At 50 MHz system clock, 6 μs is 300 clocks (20 ns or 0.02 μs per clock)

## Equipment Used

Additional equipment used:
* Digilent Analog Discovery 2
* Rigol DS1074Z+ Oscilloscope
* Tek TDS754A Oscilloscope
* Custom Hirose to DB9/SMA cables, using 26AWG twisted pairs and 75 ohm RG-179 coax

# References

* Atmel [Manchester Coding Basics](http://ww1.microchip.com/downloads/en/AppNotes/Atmel-9164-Manchester-Coding-Basics_Application-Note.pdf)
  includes a discussion of Biphase encoding as well; see figure 2-1
* [Digilent PMOD RS485](https://digilent.com/reference/pmod/pmodrs485/start)
* Terasic Cyclone V GX Starter Kit
* Intel Quartus 21.1
