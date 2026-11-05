# The ESP32-C3 with Asmonite

The ESP32-C3 from Espressif has one RISC-V core (RV32IMC, 160 MHz) and a USB port that is a serial port and a JTAG
debugger at the same time. Asmonite uses both: it debugs a program in the RAM of the chip and writes it into the
flash, **with one USB cable, without a debug probe, without OpenOCD and without ESP-IDF**.

Tested with the LuatOS ESP32C3-CORE (the simple version with one USB-C port at the chip; 4 MB flash, run in DIO mode;
LEDs at GPIO 12 and 13). Other boards whose USB port goes straight to the chip (GPIO 18 and 19) should work the same way;
boards with a USB-serial chip of their own (CP2102, CH340, CH343) give no USB JTAG.

## What you need

- A board with an ESP32-C3 whose USB port is the one of the chip. In the Device Manager it shows as
  "USB JTAG/serial debug unit" and as a COM port.
- Windows 10 or 11.

## Setting up once: the USB JTAG

Windows gives the JTAG part of the USB port the driver WinUSB by itself, but not the entry that programs need to open it.
In Asmonite: **Debug > Debug targets > ESP32-C3 > Set up the USB JTAG**. Windows asks for administrator rights once; then
**Test the connection** should say that the board answers. Windows keeps this for each USB port of the computer: if you
plug the board into another port, press the button again.

## A program in the RAM

```asm
.target esp32c3
.arch riscv32
.imagebase 0x40380000

_start:
    ...
```

Press F9 (run) or F7 (step into). The debugger resets the chip and halts it at once, before the firmware in the flash
starts, loads the program to `0x40380000` and stops at `_start`. Then: steps (F7, F8), breakpoints (F5, the core has
hardware breakpoints for them), registers `x0` .. `x31` and `pc`, memory. After a reset (the RESET button) the firmware
of the flash runs again.

Why the reset: firmware such as LuatOS or ESP-IDF switches on the memory protection of the chip; then nothing can be
written into the RAM of the code until the next reset. Halted before the firmware starts, the whole RAM from
`0x40380000` to `0x403BFFFF` (256 KB) is free for the program.

## A program in the flash

```asm
.target esp32c3 flash
.arch riscv32
.imagebase 0x40380000
```

F9 or F7 now write the program into the flash at address 0, as an image of the boot ROM: the boot ROM loads it into
the RAM at `0x40380000` at every start. The writing goes over the **serial port** of the chip (the COM port of the
board), with the protocol of its boot ROM; no terminal program (PuTTY or similar) may have that port open at that
moment. Then the debugger lets the boot ROM start the program and stops at `_start`, so you see the program exactly as
it starts without the debugger. It also starts by itself after every reset.

This replaces the firmware that was in the flash before (on the LuatOS board: LuatOS; it can be downloaded again
from the maker).

A program in the flash must switch the **watchdogs** off itself: the boot ROM leaves two of them on, and they would
reset the chip after a few seconds. `examples/esp32c3/blink_flash.asm` shows how (a few lines at `_start`).

## The examples

| File | What it does |
|---|---|
| `examples/esp32c3/blink_ram.asm` | The LEDs at GPIO 12 and 13 blink in turn; every change is a line on the USB serial port (COM port): `LED 12 on`, `LED 13 on` |
| `examples/esp32c3/blink_flash.asm` | The same in the flash, with the watchdogs switched off at the start |
| `examples/esp32c3/hello_uart_ram.asm` | "Hello, world!" on UART0 (the pin GPIO 21, not the USB port: a USB-serial adapter there shows it) |

The registers they use are written in their comments, with the source: the headers of ESP-IDF and the ESP32-C3
Technical Reference Manual.

## The output on the USB serial port

The USB port of the chip is a serial port as well (COM port); a program writes a byte into the register
`0x60043000` (`USB_SERIAL_JTAG_EP1`) and sends what is there with bit 0 of `0x60043004` (`EP1_CONF`, `WR_DONE`).
Bit 1 of `EP1_CONF` says that the buffer takes data. If no program on the PC reads the port, the buffer fills; the
examples then drop the line instead of waiting forever. Any terminal shows the lines (the speed does not matter on this
port).

## If something does not work

| Message or sign | What to do |
|---|---|
| "the ESP32-C3 is plugged in, but ... has not given its USB JTAG an interface" | Debug targets > ESP32-C3 > Set up the USB JTAG (once for each USB port) |
| "COM8 is open in another program" | Close the terminal (PuTTY ...), then F9 again |
| "the core of the ESP32-C3 hangs" | Press RESET on the board, then try again |
| The board does not answer at all | Hold BOOT, press RESET, let go of BOOT: the chip waits in its boot ROM; then F9 |
| Nothing on the COM port | Is the program for the USB port (`blink_ram.asm`) or for UART0 (`hello_uart_ram.asm`)? |

## Limits

- One core (the ESP32-C3 has one), the RAM from `0x40380000` to `0x403BFFFF`.
- The assembler has no compressed instructions (C) yet; the disassembler reads them.
- The flash image is for 4 MB of flash in DIO mode at 40 MHz; WiFi and Bluetooth need the firmware of Espressif.
- How the chip does the USB JTAG: the protocol of `esp_usb_jtag.c` of OpenOCD and the RISC-V debug spec 0.13.
