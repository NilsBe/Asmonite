# The boards: the consoles of Asmonite and the photos

## The consoles

The console of Asmonite for each board, in assembly. **Prepare Board** in the Board Manager assembles it and writes
it into the flash of the board; Asmonite looks for `boards\<board>\console.asm` next to Asmonite.exe.

| Folder | Board | Files |
|---|---|---|
| `esp32` | ESP32 | `console.asm`, its DHCP part `console_dhcp.asm` and `console_dhcp_data.asm` (the ESP32-S3 includes them too), `help.txt` (the text of `help` on the board) |
| `esp32s3` | ESP32-S3 | `console.asm` |
| `esp32c3` | ESP32-C3 | `console.asm` and its parts `console_*.asm`, `help.txt`; `contest.asm`, a program for the test of the console |
| `esp32s31` | ESP32-S31 | as the ESP32-C3 (`console.asm`, `console_*.asm`, `help.txt`, `contest.asm`); `s31rom.py`, the test bed over its boot ROM; `stage1.asm`, the first program of the S31 |
| `pico` | Raspberry Pi Pico (W) | `console.asm` and its parts: USB, debug monitor, WiFi (the CYW43439 of the W boards), `console_esp.asm` (the ESP8285 of the clones "Pico W-2023") |
| `pico2` | Raspberry Pi Pico 2 (W) | `console.asm`, its debug monitor, `console_esp_none.asm` (no ESP8285 here: the names the WiFi part calls); `blink_flash.asm` and `blink_arm_flash.asm`, which the Board Manager writes into the flash to switch the cores (RISC-V, Arm) |

The WiFi of the ESP32 boards is in `wlan/`.

## Photos of the boards

The Board Manager of Asmonite (Board > Board Manager) shows the photo of the board you chose. It looks for
`boards\<name>.jpg` (or `.png`) next to Asmonite.exe.

| File | Board |
|---|---|
| esp32.jpg | ESP32 DevKit (ESP-WROOM-32, CP2102) |
| esp32s3.jpg | ESP32-S3 DevKit (N16R8, two USB-C ports) |
| esp32c3.jpg | ESP32-C3 core board (CORE-ESP32) |
| esp32s31.jpg | ESP32-S31 DevKit (ESP32-S31-WROOM-3, two USB-C ports, an RGB LED at GPIO 60; the code on the module made unreadable) |
| pico.jpg | Raspberry Pi Pico (RP2040) |
| pico2.jpg | Raspberry Pi Pico 2 (RP2350) |
| stm32.jpg | STM32F103 "Blue Pill" |
| pico_w.jpg | Raspberry Pi Pico W (and boards like it: their console asks the WiFi chip) |
| pico2_w.jpg | Raspberry Pi Pico 2 W |
| pico_w_2023.jpg | "RP2040 Pico W-2023", a clone with an ESP8285 as its WiFi chip, at UART0 (the Board Manager shows it when the console finds the ESP8285) |

Names the Board Manager also looks for: `debugprobe`, `mangopi`.

The photos were taken by the author of Asmonite. Each one is turned so that the board lies lengthwise with its USB
port on the left, 900 pixels wide, saved as a JPEG without metadata (no location).
