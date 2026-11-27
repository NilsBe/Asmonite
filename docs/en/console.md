# The console

The console is a small shell on the board, not an interpreter. Asmonite writes it into the flash of the board
(**Prepare Board...** in the Board Manager, see [board-manager.md](board-manager.md)). From then on the board
greets you with a prompt `>` on its serial port, as a small computer would: it keeps files in its flash, starts
programs by their names, connects to the WiFi and answers in the network. It stays in the flash, and it is back
after every program and every reset. It is small: about 16 KB on the ESP32.

Asmonite itself works through it: F9 loads your program into the RAM of the board through the console, the debugger
stops it there, and the Board Manager shows the files and the WiFi by asking the console.

## A session

On an ESP32, in the tab **Serial** of Asmonite or in any terminal program (115200 baud). Network, address, name and
MAC are replaced here.

```text
> info
Chip: ESP32 (Xtensa LX6), core at 160 MHz
Flash: 4 MB (JEDEC id 68 40 16)
MAC of the station: xx:xx:xx:xx:xx:xx
Console: Asmonite console 2
> ls
  help.txt                 960
  hello                   3424
  blink                   3776
  ping                   42400
  setclock               11424
5 file(s), 61984 bytes
> df
5 file(s), 69632 bytes in use, 2019328 bytes free
> run hello
Running hello
Hello, world!

Program ended (code 0).
> run blink
Running blink
blink: the LED of the board, every half second (Ctrl+C ends it)
Program stopped (Ctrl+C).
> setclock 240
the core runs at 240 MHz now, also after this program (until a reset)
> wlan
WiFi network: HomeNet (WPA2)
The WiFi is on and connected.
> name
The name of the board: esp32-lab (esp32-lab.local)
> boot
No autostart.
```

`hello`, `blink`, `ping` and `setclock` are not commands of the console: they are programs in its flash, compiled from
aBelle (a Python-like programming language) by Asmonite. `setclock 240` starts the program `setclock` with the
argument `240`.

## Console or REPL?

MicroPython, CircuitPython or Espruino put an interpreter on the board: at their prompt (the REPL) you type lines of
Python or JavaScript, and the board runs them at once. The console of Asmonite is a shell instead:

| | A REPL (MicroPython) | The console of Asmonite |
|---|---|---|
| What you type | lines of a programming language | commands with arguments: `ls`, `run blink`, `wlan set` |
| What runs | the interpreter reads your program while it runs | your program, compiled for the chip (aBelle or assembly), at the full speed of the core |
| Files | usually through a tool on the PC (mpremote, Thonny) | `ls`, `cat`, `rm`, `df` on the board; upload and download in the Board Manager |
| Programs | scripts the interpreter runs | files that are new commands: `name arguments` |
| Size on the board | the firmware with the interpreter (several hundred KB to more than 1 MB) | the console, about 16 KB on the ESP32; your program comes on top |
| Debugging | `print` | breakpoints, steps, registers and variables in Asmonite, over the same USB cable |

## The commands

| | Command | What it does |
|---|---|---|
| Files | `ls` | the files with their sizes |
| | `cat name` | shows a file |
| | `rm name` | removes a file |
| | `df` | the room in the flash |
| | `format` | a new, empty file system (all files are lost) |
| Programs | `run name` | starts a program |
| | `name arguments` | the same, with arguments: every program in the flash is a command |
| | `boot name` | starts the program after every reset (`boot` alone: which one) |
| | `noboot` | no program after a reset |
| Network | `wlan` | the WiFi: `wlan set` (network and password), `wlan on`, `wlan off`, `wlan clear`, `wlan scan` |
| | `name` | the name of the board in the network, `name.local` (`name set`, `name clear`) |
| | `passwd` | the password for telnet (`passwd set`, `passwd clear`) |
| System | `info` | the chip, its clock, the flash, the MAC, the version of the console |
| | `reset` | starts the chip again |
| | `help` | the list of the commands (the file `help.txt` on the board) |

**Ctrl+C** stops the program that runs (in the tab Serial: the button **Stop**); on the ESP32 even an endless loop
with the interrupts off. After a reset
the console waits a moment: a key in the terminal (or BOOT) keeps it at the prompt, even with a program set to
autostart; **Reset** in the Board Manager does that too.

## Programs as commands

A program on the board has no extension: `blink.abel` becomes `blink`. A word the console does not know it looks for
as a file; if there is one, it starts the program, and the rest of the line is its arguments (aBelle: `args()`). As a
command the console says nothing before and after it, only an error code, an exception or Ctrl+C. So the console grows
without getting bigger: the network tools of the examples (`ping`, `dns`, `ntp` ...) and `setclock` are such
programs. The program in the editor gets onto the board with **Project > Compile and Upload** (Ctrl+Shift+F9).

A program writes into the flash only through files. It cannot damage the console or the file system.

## What it does in the background

- **It answers in the network:** to ping and to `name.local` (mDNS), on most boards also while a program runs (the
  table below says where).
- **It brings programs back to the prompt:** when a program ends, by `exit`, by an exception (the console says where
  and why) or by Ctrl+C, the console is there again, with its files and its WiFi.
- **It starts a program after a reset** when `boot` names one, for a board that runs on its own.

## How to reach it

- **The tab Serial** of Asmonite, next to the output: it connects to the board by itself.
- **Any terminal program** at 115200 baud (PuTTY, the serial monitor of the Arduino IDE ...).
- **The Board Manager:** the same things with buttons and menus (files, Run, Autostart, WiFi, clock).
- **telnet** over the WiFi: the program `telnetd` of the examples (ESP32, ESP32-S3, Pico W), with the password of
  `passwd`.

## What survives a reset

| Survives | Is gone |
|---|---|
| the files, the console itself | a program F9 loaded into the RAM |
| the autostart program (`boot`) | the clock set by `setclock` (back to the start clock) |
| the WiFi network and its password, the name of the board | what a program did not write into a file |

## Which board can what

| | ESP32 | ESP32-S3 | Pico, Pico 2 (W) | ESP32-C3 | ESP32-S31 |
|---|---|---|---|---|---|
| Files, programs, `boot`, `info`, `reset`, `help` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `run name arguments` | – (`name arguments`) | – (`name arguments`) | ✓ | – (`name arguments`) | – (`name arguments`) |
| `wlan`, `wlan scan`, `name` | ✓ | ✓ | ✓ (W) | ✓ | ✓ |
| `passwd` (telnet) | ✓ | ✓ | ✓ (W) | – | – |
| answers ping while a program runs | ✓ | ✓ | ✓ (W) | ✓ | ✓ |
| `name.local` while a program runs | – (at the prompt) | – (at the prompt) | ✓ (W) | ✓ | ✓ |

A Pico or Pico 2 without WiFi chip has no network commands. All details per board: [boards.md](boards.md), section
"What the consoles can do".

## For programmers: the functions of the console

A program the console starts can call it: `exit`, `put_char`, `get_char`, `poll_char`, `print`, `millis`,
`file_size`, `file_read`, `file_write`, `flash_read`, `args` (the Picos also `led` and `wl_call`). In aBelle,
`include "console.abel"` brings them, with `println`, `print_int` and the other output functions; the example
`examples/common/runs.abel` counts in the file `runs.txt` how often it ran. In assembly they are a table of jumps at a
fixed address: [esp32.md](esp32.md) (ESP32, `0x4009C800`), [esp32c3.md](esp32c3.md), [riscv-pico2.md](riscv-pico2.md)
(Pico and Pico 2).

## What it does not have (yet)

- No history of the lines typed (arrow up) and no completion with Tab.
- No scripts, no pipes, no `if` or loops at the prompt: that is what programs are for.
- No folders: the file system has one list of files.
- No command to type a file in: files come from the PC (Board Manager) or from programs (`file_write`).
