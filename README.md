# Symbolics Console Decoder - Terasic Cyclone V GX Starter Kit

**Copyright 2022 Douglas P. Fields, Jr. All Rights Reserved.**

Decode the output from a Symbolics 19" Console to the CPU using
a Terasic Cyclone V GX Starter Kit board and a 
Digilent RS-422 PMOD.

## Signal Information

The signal is RS-422 based, but uses a Biphase encoding.
(This seems also to be called Differential Manchester encoding.)
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

# SystemVerilog Implementation Notes

TODO

# Reverse Engineering the Console Protocol

With the NRZ data, it's possible to decode it using a logic analyzer
set to UART mode at 75 kbaud. (The logic analyzer actually thinks it's
running around 76.92 kbaud. This seems reasonable as it is almost a multiple
of 19.2kbps which would be 76.8kbps.)

Set to 8 data bits, one stop bit and no parity, console seems to send two bytes
of data for each keypress and release. The keyboard has 88 keys on it.
Two keys have a light (CAPS, MODE locks).

TODO: See if it is 7 data bits + parity?
TODO: What's the bit order? (WaveForms decodes UART LSB first.)

## Recordings

Record various keypresses using Waveforms.

Waveforms settings:
* Samples: 100M
* Rate: 500 kHz
* Mode: Record
* Trigger: Normal, Simple (on UART data falling edge)


### Pressed & released the keys a-m, one at a time:
 
Key          Down      Up
--------     -----     -----
a            C0 29     A0 00
b            C0 12     A0 00
c            C0 11     A0 00
d            C0 2A     A0 00
e            C0 3A     A0 00
f            C0 22     A0 00
g            C0 2B     A0 00
h            C0 23     A0 00
i            C0 34     A0 00
j            C0 2C     A0 00
k            C0 24     A0 00
l            C0 2D     A0 00
m            C0 13     A0 00

### Pressed a then b, then released b then a

Key event    Code
--------     -----
a down       C0 29
b down       C0 12
b up         D0 12
a up         A0 00

### Pressed a then b, then released a then b

Key event    Code
--------     -----
a down       C0 29
b down       C0 12
a up         D0 29
b up         A0 00

### Press a, b, c then release b, a, c

Key event    Code
--------     -----
a down       C0 29
b down       C0 12
c down       C0 11
b up         D0 12
a up         D0 29
c up         A0 00

## Summary

Code     Meaning
-----    ----------  
A0 00    All keys up
C0 xx    Key down
D0 xx    Key up




# Miscellaneous Notes

There is a conflict between the Altera USB-Blaster and the Digilent Analog
Discovery 2. They both seem to use FTDI USB interface chips, and plugging
both into the same USB port (by way of a hub) can make the Altera (Quartus)
jtagserver/jtagconfig not see the Altera USB Blaster. So, plug them in in
different ports or orders until you find one that allows both to be used
concurrently. Or, just unplug the analog discovery when you want to program
your Altera (Intel) FPGA over the USB-Blaster.

Got an odd error once from Waveforms:
The device is being used by another application SERC: 1001
JTAG-IDs h44002093 h00000000
Device programming failed.

https://community.intel.com/t5/Programmable-Devices/USB-Blaster-driver-conflict-with-other-FTDI-kit/td-p/72754

https://community.intel.com/t5/Programmable-Devices/USB-Blaster-conflicts-with-other-FTDI-device/td-p/260890

https://forum.digilent.com/topic/8797-analog-discovery-2-and-altera-usb-blaster-conflict/


# References

* Atmel [Manchester Coding Basics](http://ww1.microchip.com/downloads/en/AppNotes/Atmel-9164-Manchester-Coding-Basics_Application-Note.pdf)
  includes a discussion of Biphase encoding as well; see figure 2-1
* [Digilent PMOD RS485](https://digilent.com/reference/pmod/pmodrs485/start)
* Terasic Cyclone V GX Starter Kit
* Intel Quartus 21.1
