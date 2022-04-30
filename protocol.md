# Symbolics Console Protocol Summary

*Copyright ⓒ 2022 Douglas P. Fields, Jr.*

Last updated: 2022-04-30

Note that the keyboard handling code is complex, but the codes the
console sends seems to be reasonably simple.

# Encoding

Biphase (differential manchester) encoding around 75 kHz
via RS-422. Long pulse is about 13 μs and the short pulses are half that.
Long pulses are logical 1 (marking), and a pair of short pulses are a
logical 0 (spacing).

1 start bit, 8 data bits, 1 stop bit and no parity is used for the serial encoding.

# Commands

A single command to the CPU is encoded in at least one byte
in the format `ABBBCCCC` (MSB to LSB). Note in the protocol on the
wire, the LSB is sent first, so it looks backwards on an oscilloscope.

`A` always seems to be 1.

`BBB` is the type of message the console is sending, from the possibilities below.
The important ones are (in binary):

* `000` - mouse button 
* `001` - mouse move
* `010` - all keys up
* `100` - key down
* `101` - key up

`CCCC` is message dependent. 

## Mouse commands

For the mouse button, `CCCC` is `LMRF` for the the three mouse buttons and
a fourth `F` (that is not seen in testing). Note that the Logitech console mouse 
seems unable to process 
more than one button press at a time, so it will always have one or no bits set.

For the mouse move, `CCCC` is `LRUD` - a single bit indicating that the mouse
moved in that particular direction at that time; with `LR` and `UD` mutually
exclusive.

## Keyboard commands

For key up/down messages, `CCCC` is always `0000`.

A second byte always follows the command byte. For all keys up, this is always `00`.
For the others, it is the keyboard code (listed below).

Whenever there are no keyboard codes pressed, it always sends the all keys up command
instead of a key up command.

For all keys up, `CCCC` is `XMCY`. `X` and `Y` seem always to be `0`, but
`M` is for mode lock still down, and `C` is for caps lock still down, but all other
keys are up.

### Console keyboard oddities

#### Local

`LOCAL` key doesn't seem to send anything to the CPU, but when it is released,
it does send an all keys up command.

#### Locks

`CAPS LOCK` and `MODE LOCK` sends a key down, then lights its light. It is then considered
pressed until tapped again. When it is tapped again, it sends an all keys up (assuming
no other keys or locks are down).
* While either is "down," all keys up changes to an `AX 00` command,
  which seems to mean "no other keys are down
  but for these two shifts." X is `2` for caps-lock only down, `4` for mode-lock only, and `6` for both down.
* When both locks are on, releasing a lock sends the usual `D0 XX` command for the released lock.

Code refers to a scroll lock and a num lock as well, and various other locks.

## Status commands

Status can return:
* 0 - Brightness
* 1 - Volume
* 2 - Switchpack (?) whatever that is
* 4 - Modem status


# System/Console boot

# TODO

* How are the mode lights handled on the keyboard? Can the console
  change their status?
* Status messages from console to CPU
* RS-232 Serial I/O to/from console
* Messages TO the console FROM the CPU such as to set brightness


# Enumerations/Data

## Message types

```
                       raw     with 1bbbxxxx
%TYPE-MOUSE-SWITCH     000     8x
%TYPE-MOUSE-MOVE       001     9x
%TYPE-ALL-KEYS-UP      010     Ax
%TYPE-STATUS           011     Bx
%TYPE-KEY-DOWN         100     Cx
%TYPE-KEY-UP           101     Dx
%TYPE-SERIAL-WINDOW    110     Ex
%TYPE-SERIAL-IN        111     Fx
```


## Keyboard codes (in octal, hex)

* 000 00 local (function on old keyboards)
* 001 01 caps lock
* 002 02 left hyper
* 003 03 left meta
* 004 04 right control
* 005 05 right super
* 006 06 scroll
* 007 07 mode lock
* 010 08 select
* 011 09 left symbol
* 012 0A left super
* 013 0B left control
* 014 0C space
* 015 0D right meta
* 016 0E right hyper
* 017 0F end
* 020 10 z
* 021 11 c
* 022 12 b
* 023 13 m
* 024 14 .
* 025 15 right shift
* 026 16 repeat
* 027 17 abort
* 030 18 left shift
* 031 19 x
* 032 1A v
* 033 1B n
* 034 1C ,
* 035 1D /
* 036 1E right symbol
* 037 1F help
* 040 20 rubout
* 041 21 s
* 042 22 f
* 043 23 h
* 044 24 k
* 045 25 ;
* 046 26 return
* 047 27 complete
* 050 28 network
* 051 29 a
* 052 2A d
* 053 2B g
* 054 2C j
* 055 2D l
* 056 2E '
* 057 2F line
* 060 30 function (local on old keyboards)
* 061 31 w
* 062 32 r
* 063 33 y
* 064 34 i
* 065 35 p
* 066 36 )
* 067 37 page
* 070 38 tab
* 071 39 q
* 072 3A e
* 073 3B t
* 074 3C u
* 075 3D o
* 076 3E (
* 077 3F backspace (\ on old keyboards)
* 100 40 :
* 101 41 2
* 102 42 4
* 103 43 6
* 104 44 8
* 105 45 0
* 106 46 =
* 107 47 \ (` on old keyboards)
* 110 48 1
* 111 49 3
* 112 4A 5
* 113 4B 7
* 114 4C 9
* 115 4D -
* 116 4E `~` (lowercase `~` on old keyboards)
* 117 4F (backspace on old keyboards)
* 120 50 escape
* 121 51 refresh
* 122 52 square
* 123 53 circle
* 124 54 triangle
* 125 55 clear input
* 126 56 suspend
* 127 57 resume

# References

* Source code: `sys.sct/l-sys/wired-console.lisp`,
  function: `wired-slb-console-process-byte`
* Source code: `sys.sct/l-sys/sysdef.lisp`,
  definition: `*SLB-CONSOLE-BYTE-TYPES*`
* Source code: `sys.sct/sys/console.lisp`,
  definition: `*symbolics-keyboard-mapping*`
  * Also `define-kbd-shift-bit`
* Source code: `sys.sct/sys/cold-load-stream.lisp`,
  function: `KBD-CONVERT-TO-SOFTWARE-CHAR-COLD`
* Source code: `sys.sct/serial/console-interface.lisp`,
  has information on serial interface
* Source code: `sys.sct/l-sys/console.lisp`,
  flavor function: `initialize-keyboard shared-nbs-console` and
  function: `console-send-command`

```lisp
  ;; Start reading some parameters.
  (console-send-command self #2r10010000 0)     ;make it tell us the current brightness
  (console-send-command self #2r10010010 0)     ;make it tell us the current volume

  (console-send-command self
                        (dpb (ldb (byte 1 7) funny-brightness) (byte 1 0) #2r10010000)
                        (ldb (byte 7 0) funny-brightness))

  (console-send-command self #2r10010010 (ldb (byte 6 0) (cvt-to-funny-volume new)))

  ;; Reset the console
  (console-send-command self #b10000000 nil t)
```






















































































