# The Board Manager

The Board Manager is the place for your boards. Here you prepare a new board, put files and programs on it, set its
WiFi and its clock, and see what Asmonite knows about it. Open it with **Board > Board Manager**. When you plug in a
board for the first time, it opens by itself.

It works with the ESP32, the ESP32-S3, the ESP32-C3, the ESP32-S31, the Raspberry Pi Pico and the Pico 2 (with and
without W), each over the board's own USB cable. For each board it shows only what works with it.

## A new board in three steps

1. **Plug it in.** The first time, plug in a Pico or Pico 2 while you hold its **BOOTSEL** button (a new, empty board
   does not need it); Windows then shows a drive `RPI-RP2` or `RP2350`. An ESP board you just plug in.
2. **Click "Prepare Board...".** Asmonite writes its console to the flash of the board, creates a file system if
   there is none, and brings the WiFi package along on an ESP board. On the ESP32 this takes about half a minute. If
   an ESP32 does not go into its download mode by itself, Asmonite asks you to hold **BOOT**.
3. **Done.** The Board Manager now shows the files on the board. From now on F9 runs your programs on the board, and
   the debugger works over the same cable.

The console stays in the flash and is back after every reset. When a newer Asmonite brings a newer console, the line
*Console* says so; **Prepare Board...** then writes it again, and your files are kept.

## The window

| Where | What |
|---|---|
| top left | the boards plugged in; **Scan** looks again |
| bottom left | a photo of the board chosen |
| top right | what Asmonite knows about the board (the info lines, see below) |
| below it | the files on the board |
| bottom | the buttons for the board |

When it opens, the Board Manager only reads what does not disturb the board: what Windows says about the USB device
and what the Asmonite console reports. It stops a running program only when you do something that needs the console,
and it asks first.

## The info lines

Right-click a line to see what you can do with it; a double-click picks the first item. **Copy Line** and **Copy All**
copy one line or all of them.

| Line | What it says | Right-click |
|---|---|---|
| *Console* | the version of the console on the board and the current one ("v5 (current: v5)") | for an older version: **Prepare Board...** writes the current one |
| *CPU clock* | the clock of the core | **Set the Clock...**: a clock from the list of the board, until the next reset (see [clock.md](clock.md)) |
| *WiFi* | off, connecting or connected; address and name in the network | **Set Network...**, **WiFi On**, **WiFi Off**, **Forget Network...**, **Set mDNS Name...** |
| *WiFi service* | the version of the WiFi package (ESP boards) | **Install WiFi...** writes the current one |
| *telnet* | whether a password for telnet is set | **Set Password...**, **Clear Password...** |

**Set Network...** lists the networks this PC sees, and on the ESP32-C3, ESP32-S31 and Pico W also the ones the board
sees; **From Windows** fills in the password Windows has saved for that network.

**Set the Clock...** uses the program `setclock` on the board. If it is missing, Asmonite compiles
`examples/<board>/setclock.abel` and uploads it first (it asks). A clock at which the WiFi does not run switches the
WiFi off first (it asks too).

## Files and programs

Right-click a file to see what you can do with it:

| Item | What it does |
|---|---|
| **Run** (Enter, double-click) | starts a program; the window closes, and the tab Serial shows what it writes |
| **Open in Editor** (Enter, double-click) | opens a text file in the editor (a copy: a change stays on the PC) |
| **Autostart** / **No Autostart** | the program starts after every reset (the column *After a reset*) |
| **Download...** | copies the file to the PC |
| **Delete** (Del) | deletes it |
| **Upload File...** | puts a file from the PC on the board (also on the empty list) |
| **Refresh** (F5) | reads the list again |

Files dragged from the Explorer onto the window are uploaded to the board. **Examples...** opens an example for the
board chosen: from `examples\common` (for every board), from the folder of the board, or the overview of the
examples. Asmonite opens it in the editor and, for aBelle, sets **Project > Target** to the board of the tab
Serial: F9 then runs it there.

From the editor, programs get onto the board like this:

| In the editor | What happens |
|---|---|
| F9 | the program runs in the RAM of the board, without a file |
| **Project > Compile and Upload** (Ctrl+Shift+F9) | the program goes onto the board as a file (the name of the source without its extension) |
| **Debug > Upload and Run** (Shift+F9) | the same, then the console starts it |

## The buttons

| Button | What it does |
|---|---|
| **Prepare Board...** | the console into the flash, the file system, the WiFi package (see above) |
| **Reset** | restarts the board and keeps it in the console, even with a program set to autostart |
| **Chip Details** | ESP boards: chip, revision, MAC, crystal, flash (and PSRAM) over the boot ROM; the board restarts for it |
| **Install WiFi...** | writes the WiFi package again (rarely needed) |
| **Format...** | a new, empty file system; all files will be lost |
| **Erase Flash...** | erases the whole flash, as on a new board; then **Prepare Board...** again |
| **Examples...** | opens an example for this board |

Which buttons a board gets:

| Board | Buttons |
|---|---|
| ESP32, ESP32-S3 | **Reset**, **Chip Details**, **Prepare Board...**, **Install WiFi...**, **Format...**, **Erase Flash...** |
| ESP32-C3, ESP32-S31 | as on the ESP32 once the console runs; without it **Reset**, **Chip Details**, **Prepare Board...**, **Erase Flash...** |
| ESP32-S3 or ESP32-C3, not known yet (the same USB id) | **Chip Details**, **Prepare Board...** |
| Pico, Pico 2 with the console | **Reset**, **Prepare Board...** (a new console, without BOOTSEL), **Format...** |
| Pico in its USB boot (BOOTSEL) | **Prepare Board...**, **Start Program** (leaves the USB boot), **Erase Flash...** |
| Pico 2 in its USB boot (BOOTSEL) | **Prepare Board...**, **Arm Cores...**, **RISC-V Cores...** |
| Clone "Pico W-2023" (RP2040 with an ESP8285) | as the Pico, plus **Install WiFi (ESP8285)...** (plug the board in with BOOT held for it; the question says how) |
| a board Asmonite does not know | no buttons; only what Windows says about it |

## Pico 2: Arm or RISC-V cores

The RP2350 of the Pico 2 has two Arm cores and two RISC-V cores; the boot ROM starts the ones the program in the flash
is for. **RISC-V Cores...** and **Arm Cores...** switch a Pico 2 in its USB boot: the Board Manager writes the example
`blink` of the other cores to its drive as a UF2 file, and the LED blinks. The console is an Arm program:
**Prepare Board...** brings it and the Arm cores back.

## When something does not work

| What you see | What helps |
|---|---|
| "The Asmonite console does not respond" | A program runs that Ctrl+C does not stop: **Reset**. Or there is no console in the flash: **Prepare Board...** |
| "The flash is empty (no console)" | **Prepare Board...** |
| "No file system yet" | **Format...** creates one |
| The line *Console* says "older version" | **Prepare Board...** writes the current one; your files are kept |
| An ESP32 does not go into its download mode | hold **BOOT** until Asmonite goes on |
| A Pico does not appear in the list | use a data cable (not a charge-only cable); without a console, plug it in with **BOOTSEL** held |
| The WiFi is still missing after a reset | the address comes a few seconds later: **Refresh** (F5) |

More about each board: [esp32.md](esp32.md), [esp32s3.md](esp32s3.md), [esp32c3.md](esp32c3.md),
[riscv-pico2.md](riscv-pico2.md) (Pico and Pico 2), [t-picoc3.md](t-picoc3.md); all boards at a glance:
[boards.md](boards.md).

## What Asmonite remembers

Asmonite remembers the boards it has seen in the section `[Boards]` of the file `Asmonite.ini` (by their USB serial
number). Only a board that is not in it yet opens the Board Manager by itself, also when Asmonite starts; if Asmonite
is in the background, it flashes in the taskbar. A limit: two ESP32 DevKits with the USB serial chip CP2102 have the
same serial number ("0001"), so the second one counts as seen already.
