# Changing the clock of the core (aBelle)

An aBelle program can change the clock of its board's processor core itself: faster when it has a lot to compute,
slower when it has little to do and should draw less current. The file `cpuclock.abel` has two functions for this:

- `cpu_clock(mhz)` sets the clock in whole MHz, within the range the board normally runs at. `millis()`, the terminal
  and the WiFi keep working correctly.
- `cpu_clock_khz(khz)` goes down to a few kHz. Some limits apply there (see below): on the ESP32 the terminal goes
  silent and `millis()` no longer counts correctly.

The clock stays after the program: the console keeps running at the clock a program leaves, and every program after
it starts at that clock, until another program changes it or the board restarts. This is how you set the clock of the
console; `info` in the console and the line **CPU clock** in the Board Manager show it. A program that needs a clock
only for a while notes the one it found at its start (`cpu_clock(0)`) and sets it again at the end. The console only
refuses to keep clocks at which it could no longer be reached: on the ESP32 below 1 MHz (it goes back to 40 MHz), on
the ESP32-S3 and the ESP32-C3 below 10 MHz (it goes back to 40 MHz), on the Pico and the Pico 2 the clocks from the
crystal below 48 MHz (it goes back to 48 MHz).

This works today on the **ESP32**, the **ESP32-S3**, the **ESP32-C3**, the **Raspberry Pi Pico** and the **Raspberry Pi
Pico 2** (with or without the W). The ESP32-S31 does not have these functions yet (see [Other boards](#other-boards)).

## A first example

```
target "esp32"

include "console.abel"
include "cpuclock.abel"

def main():
    print("the clock now: ")
    print_int(cpu_clock(0))
    println(" MHz")
    cpu_clock(240)
    # ... compute as fast as possible ...
    cpu_clock(10)
    # ... wait, saving current ...
```

`include "cpuclock.abel"` comes after `include "console.abel"`. Asmonite takes the board's file from
`abelle/lib/<board>/`. It is a file of its own rather than part of `console.abel` because aBelle compiles every
function of an included file: every program would otherwise grow by several KB, even one that never changes the clock.

Ready-made examples: `examples/esp32/clockspeed.abel`, `examples/esp32s3/clockspeed.abel`,
`examples/esp32c3/clockspeed.abel`, `examples/pico/clockspeed.abel` and `examples/pico2/clockspeed.abel` run the same
work at each clock and show how long it takes. `slowclock.abel` in the folders of the ESP32 and the Picos blinks the LED
once a second at each clock, down to 5 kHz (ESP32) or 1 kHz (Pico, Pico 2), and keeps time by counting cycles (see
[Time without `millis()`](#time-without-millis)); the ESP32-S3 and the ESP32-C3 have no such example, as their clock
only goes down to 10 MHz. `setclock.abel` sets the clock of the console: upload it, then type `setclock 240` (ESP32,
ESP32-S3), `setclock 160` (ESP32-C3), `setclock 133` (Pico) or `setclock 150` (Pico 2) in the console; `setclock`
without a number shows the clock.

## The functions

### `cpu_clock(mhz)`

| Call | Result |
|---|---|
| `cpu_clock(0)` | only asks: the clock now in MHz (below 1 MHz: 0) |
| `cpu_clock(mhz)` with a value the board supports | sets it and returns the new clock |
| any other value | -1, nothing changes |

### `cpu_clock_khz(khz)`

| Call | Result |
|---|---|
| `cpu_clock_khz(0)` | only asks: the clock now in kHz, also below 1 MHz |
| a value within the board's range | sets the nearest possible clock and returns it in kHz |
| a value outside it | -1, nothing changes |

From 1000 kHz (ESP32), 10000 kHz (ESP32-S3, ESP32-C3) or 48000 kHz (Pico, Pico 2) up, `cpu_clock_khz` simply calls `cpu_clock` with the whole MHz;
the value must then be one that `cpu_clock` supports. Below that, the function divides a clock source by a whole
number and picks the divider that comes closest to the value asked for. That is why the return value matters: it
tells what is really set (on the Pico, `cpu_clock_khz(2500)` gives 2400, for example).

To return to a normal clock, call `cpu_clock(mhz)` (or `cpu_clock_khz` with a value of 1 MHz or 48 MHz and up). If
the program ends at one of the low clocks, the console sets its default clock (see above).

## ESP32

### The clocks

| Clock | Source | with `cpu_clock` | with `cpu_clock_khz` | while the WiFi runs |
|---|---|---|---|---|
| 240, 160, 80 MHz | PLL | ✓ | ✓ (240000, 160000, 80000) | ✓ |
| 40, 20, 10, 8, 5, 4, 2, 1 MHz | crystal (40 MHz divided by 1 … 40) | ✓ | ✓ (40000 … 1000) | – |
| 975 kHz down to 39 kHz | crystal divided by 41 … 1024 | – | ✓ | – |
| below 39 kHz down to about 5 kHz | the internal RC_FAST oscillator, divided by up to 1024 | – | ✓ | – |

After a reset the console runs at 40 MHz, or at 160 MHz with the WiFi.

- **WiFi:** the WiFi needs the PLL, so 80 MHz at least. While the WiFi service runs, every clock from the crystal
  returns -1. Type `wlan off` in the console first and `wlan on` afterwards. Between 80, 160 and 240 MHz the
  connection stays up; this needs WiFi service v12 or later on the board (Board Manager: **Install WiFi...**).
- **`millis()` and the terminal:** at every clock from 1 MHz up they keep working correctly. At each change the
  library recomputes the UART divider so the baud rate stays the same, and tells the ROM how many cycles a
  microsecond has.
- **Below 1 MHz** the clock is too slow to make 115200 baud: the terminal goes silent. Whatever the program printed
  before has already gone out (`cpu_clock_khz` waits until the UART has sent everything). Back at 1 MHz or more, the
  terminal works again. For the same reason no Ctrl+C gets through below 1 MHz (not tested, but the UART then
  receives at the wrong baud rate): the program has to return by itself, otherwise only a reset helps. `millis()`
  counts wrong below 1 MHz; a program that needs to measure time there counts cycles instead (see
  [Time without `millis()`](#time-without-millis)).
- **RC_FAST** is an oscillator inside the chip, without a crystal. The datasheet gives about 8 MHz; on the ESP32
  DevKit it measured about 5.2 MHz, and it varies from chip to chip and with temperature. The library measures it
  against the crystal the first time it is used (with the calibration unit of timer group 0), so the return value is
  right. Below 39 kHz the clocks are only as exact as that measurement.
- **The console after the program:** it keeps any clock from 1 MHz up, also after Ctrl+C, a crash or the debugger;
  the library has already set the UART divider and the cycles per microsecond for it, so the terminal and `millis()`
  keep working. If a program ends below 1 MHz, the console switches back to 40 MHz from the crystal. If you switch the
  WiFi on with `wlan on` at a crystal clock, the WiFi service sets 160 MHz itself.

### Measured

The same work (a loop, `clockspeed`) at each clock, timed by `millis()`, and 3 s of `millis()` checked against the PC:

| Clock | 240 MHz | 160 MHz | 80 MHz | 40 MHz | 20 MHz | 10 MHz | 5 MHz | 2 MHz | 1 MHz |
|---|---|---|---|---|---|---|---|---|---|
| Time | 54 ms | 81 ms | 161 ms | 322 ms | 645 ms | 1290 ms | 2581 ms | 6450 ms | 12900 ms |
| 3 s of `millis()`, on the PC | 2994 ms | 3000 ms | 2999 ms | 2985 ms | 2987 ms | 3010 ms | 3003 ms | 3000 ms | 2995 ms |

Below 1 MHz, measured on the PC (the time between a line before and a line after the slow phase, about 1 s):

| Set | 975 kHz | 500 kHz | 100 kHz | 39 kHz | 20 kHz | 6 kHz | 5 kHz |
|---|---|---|---|---|---|---|---|
| Source | crystal | crystal | crystal | crystal | RC_FAST | RC_FAST | RC_FAST |
| Measured | 973 kHz | 498 kHz | 99 kHz | 38 kHz | 19 kHz | 5.0 kHz | 4.1 kHz |

The lower the clock, the more the switch itself counts (about 1000 cycles, a fifth of a second at 5 kHz); the clock
during the slow phase is right.

## ESP32-S3

### The clocks

| Clock | Source | with `cpu_clock` | with `cpu_clock_khz` | while the WiFi runs |
|---|---|---|---|---|
| 240, 160, 80 MHz | PLL | ✓ | ✓ (240000, 160000, 80000) | ✓ |
| 40, 20, 10 MHz | crystal (40 MHz divided by 1, 2, 4) | ✓ | ✓ (40000, 20000, 10000) | – |
| below 10 MHz | – | – (-1) | – (-1) | – |

After a reset the console runs at 40 MHz, or at 160 MHz with the WiFi. Here `cpu_clock_khz` only takes the whole MHz
that `cpu_clock` takes.

- **Not below 10 MHz:** the console of the S3 talks over the chip's own USB port (USB-Serial-JTAG). When the core runs
  from the crystal, the peripheral bus (APB) gets the same clock as the core, and this USB block needs at least 10 MHz
  of it. Observed: at 8, 5 and 4 MHz characters reached the PC twice; at 2 and 1 MHz the port stopped working
  altogether, even when the program sent nothing meanwhile, and only a reset or plugging the board in again helped. So
  `cpu_clock` returns -1 below 10 MHz, and the S3 has no low clocks like the ESP32.
- **WiFi:** the WiFi needs the PLL. While the WiFi service runs, 40, 20 and 10 MHz return -1; type `wlan off` in the
  console first and `wlan on` afterwards. Between 80, 160 and 240 MHz the connection stays up, and restarting the WiFi
  keeps the clock. This needs WiFi service version 13 or later on the board (Board Manager: **Install WiFi...**).
- **240 MHz** needs one step more voltage on the core. `cpu_clock` raises it before switching to 240 MHz and lowers it
  again after switching away from 240 MHz (see [How it works inside](#how-it-works-inside)).
- **`millis()` and the terminal** keep running correctly at every clock. The PLL stays on at every clock, also while the
  core runs from the crystal, because the USB port takes its 48 MHz from it.
- **The console after the program:** it keeps every clock from 10 MHz up, also after Ctrl+C. Should the core be lower
  after all, it switches back to 40 MHz from the crystal (`boards/esp32s3/console_clock.asm`).

### Measured

The same work as on the ESP32 (`clockspeed`), timed with `millis()` and checked against the chip's SYSTIMER, which
counts the crystal and does not notice the clock of the core:

| Clock | 240 MHz | 160 MHz | 80 MHz | 40 MHz | 20 MHz | 10 MHz |
|---|---|---|---|---|---|---|
| Time | 15 ms | 24 ms | 46 ms | 93 ms | 185 ms | 370 ms |

With the WiFi connected, at each change between 80, 160 and 240 MHz: 4 of 4 pings to the router and a DNS lookup each
time.

## ESP32-C3

### The clocks

| Clock | Source | with `cpu_clock` | with `cpu_clock_khz` | while the WiFi runs |
|---|---|---|---|---|
| 160, 80 MHz | PLL | ✓ | ✓ (160000, 80000) | ✓ |
| 40, 20, 10 MHz | crystal (40 MHz divided by 1, 2, 4) | ✓ | ✓ (40000, 20000, 10000) | – |
| below 10 MHz | – | – (-1) | – (-1) | – |

After a reset the console runs at 160 MHz, with or without the WiFi.

- **Not below 10 MHz:** like the S3, the console of the C3 talks over the chip's own USB port (USB-Serial-JTAG), and
  from the crystal its bus gets the same clock as the core. The 10 MHz limit is taken over from the S3; it has not been
  tried out on the C3 itself.
- **WiFi:** the WiFi needs the PLL. While it runs, 40, 20 and 10 MHz return -1; type `wlan off` in the console first.
  Between 80 and 160 MHz the connection stays up, and the first start of the WiFi after a reset keeps an 80 MHz clock a
  program has set. This needs WiFi service version 7 or later on the board (Board Manager: **Install WiFi...**); with
  an older service `cpu_clock` always refuses the crystal clocks, as it cannot tell whether the WiFi runs.
- **No voltage to change:** unlike the S3, no clock of the C3 needs a different voltage on the core. The console sets
  the one for 160 MHz at its start, and it stays there.
- **`millis()` and the terminal** keep running correctly at every clock: `millis()` counts a timer that runs from the
  crystal, and so does the 10 ms tick the WiFi service uses to do its work while a program computes.
- **The console after the program:** it keeps every clock from 10 MHz up, also after Ctrl+C. Should the core be lower
  after all, it switches back to 40 MHz from the crystal (`boards/esp32c3/console_clock.asm`).

### Measured

The same work as on the ESP32 (`clockspeed`), timed with `millis()`, and 3 s of `millis()` checked from the PC:

| Clock | 160 MHz | 80 MHz | 40 MHz | 20 MHz | 10 MHz |
|---|---|---|---|---|---|
| Time | 22 ms | 44 ms | 87 ms | 175 ms | 350 ms |
| 3 s of `millis()`, on the PC | 3021 ms | 2979 ms | 2999 ms | 2979 ms | 2995 ms |

With the WiFi connected, at each change between 80 and 160 MHz: 4 of 4 pings to the router and a DNS lookup each time.

## Raspberry Pi Pico and Pico 2

### The clocks

| Clock | Source | with `cpu_clock` | with `cpu_clock_khz` |
|---|---|---|---|
| 48 MHz (the console's clock) | PLL_USB | ✓ | ✓ (48000) |
| every whole MHz from 49 to 133 (Pico) or 150 (Pico 2) | PLL_SYS | ✓ | ✓ (in whole MHz) |
| 12000 kHz down to 1 kHz | crystal, 12 MHz divided by a whole number: 12000, 6000, 4000, 3000, 2400, 2000 … 1 kHz | – | ✓ |
| between 12 and 48 MHz | – | – | – (-1) |

133 MHz is the highest clock the RP2040 is specified for at its voltage, 150 MHz for the RP2350.

- **`millis()`, the terminal and USB:** the timer (TIMER) counts from the crystal, and the UART and the USB port get
  their 48 MHz straight from the USB PLL. They do not notice any clock that `cpu_clock` sets.
- **Below about 1 MHz** `millis()` stops: the timer gets its microsecond ticks from the crystal clock, and a core that
  slow no longer takes all of them. The terminal keeps working, but slowly at a few kHz.
- **USB at the clocks from the crystal:** while clk_sys runs from the crystal (12 MHz and less), the PC cannot open the
  COM port anew; Windows reports a timeout ("The semaphore timeout period has expired", seen at 12 and 6 MHz and at
  1 kHz). A port that is already open keeps working; Ctrl+C ends a program at 1 kHz too, after 3 to 4 seconds. After a
  time below a few MHz the next output over USB may also reach the PC about a second late (seen on the Pico; nothing
  is lost).
- **Pico W, Pico 2 W:** the console serves the WiFi every 10 ms from the SysTick timer, which counts at the core
  clock. The library sets it anew at each clock; below 1 MHz it gets its longest period and the WiFi waits. Back at
  48 MHz or more it carries on: pings and DNS worked after 500, 10 and 1 kHz as before. The LED of a W is wired to the
  WiFi chip, and each switch is a talk with it of about 75,000 cycles: almost a second at 100 kHz, over a minute at
  1 kHz.
- **No division at a low clock:** the Cortex-M0+ of the Pico has no divide instruction, so aBelle calls a function
  that takes hundreds of cycles (on the Pico 2 as well: aBelle generates the same Thumb-1 code for both). The library
  therefore computes everything before it slows down. A program that divides at 1 kHz waits a few tenths of a second
  for it.
- **The console after the program:** it keeps any clock from the PLL (48 MHz and up), also after Ctrl+C. If a program
  ends at a clock from the crystal, it switches clk_sys back to its 48 MHz from the USB PLL, sets the divider to 1,
  powers PLL_SYS down and sets SysTick back to 10 ms; otherwise it could no longer be reached over USB.

### Measured

The same work as on the ESP32 (`clockspeed`); 3 s of `millis()` were 2985 to 3012 ms on the PC:

| Clock | 48 MHz | 77 MHz | 100 MHz | 125 MHz | 133 MHz | 150 MHz |
|---|---|---|---|---|---|---|
| Pico (RP2040) | 269 ms | 167 ms | 129 ms | 103 ms | 97 ms | – |
| Pico 2 (RP2350) | 200 ms | 124 ms | 96 ms | – | 72 ms | 64 ms |

With `cpu_clock_khz`, measured on the PC: 12000, 4000 and 1000 kHz are right to about one percent; below that (500 kHz
down to 1 kHz) the values are lower by the cycles of the switch, and on the Pico the occasional second of the USB
transfer adds to it. `millis()` on the board confirms the expected time exactly at 2400 kHz (1042 ms).

## Time without `millis()`

Below 1 MHz `millis()` is no help. A program can count cycles instead: at the start, at full clock, it measures how
long one round of a loop takes, and from that it works out how many rounds make a given time at another clock.

```
cyc100: i32[1]                  # the cycles of a round of count() * 100

def count(n):
    i = 0
    while i < n:
        i += 1

def main():
    t = millis()
    count(200000)                                   # measured at 40 MHz
    cyc100[0] = (millis() - t) * 40000 / 2000       # ms * kHz = cycles; / 200000 rounds * 100
    khz = cpu_clock_khz(10)
    count(khz * 50000 / cyc100[0])                  # half a second at khz: khz * 500 cycles
    cpu_clock(40)
```

On the Pico, `khz * 50000` no longer fits into 32 bits from about 43 MHz up; above 20000 kHz compute
`khz / cyc100[0] * 50000` instead.

## Things to keep in mind

- **Current:** a lower clock means less current; how much exactly has not been measured yet. For long pauses a sleep
  mode (on the ESP32 light sleep or deep sleep, see `examples/esp32/bme280_sleep.abel`) often saves more than a low
  clock.
- **Dividers:** the clocks below 1 MHz come from a divider of at most 1024 (ESP32) or from a whole-number divider of
  12 MHz (Pico). If you need a particular value, use the return value, not the value you asked for.
- **A program called `cpuclock.abel` in your own folder** hides the library: `include` looks in the program's folder
  first.
- **Debugger:** changing the clock under the debugger has not been tested. On the ESP32 the debug monitor talks over
  the UART, so below 1 MHz it cannot answer at a breakpoint.

## Other boards

| Board | Status |
|---|---|
| ESP32-S31 | not yet; its clock system has not been looked into |
| Raspberry Pi Pico W-2023 (clone with an ESP8285) | the Pico library applies; the WiFi over the ESP8285 at a low clock is untested |
| LilyGO T-PicoC3 | the RP2040 side like a Pico (untested), the C3 side like the ESP32-C3 |

## How it works inside

**ESP32.** The core runs either from the PLL or from the crystal (`SOC_CLK_SEL` in the register `RTC_CNTL_CLK_CONF`),
below 39 kHz from RC_FAST. The PLL runs at 320 MHz for 80 and 160 MHz (`CPUPERIOD_SEL` 0 or 1) and at 480 MHz for
240 MHz; at 480 MHz every `CPUPERIOD_SEL` gives 240 MHz. Switching to 240 MHz and back therefore goes through the
crystal: the PLL off, set up anew (over the I2C bus inside the chip, `rom_i2c_writeReg`), and at 480 MHz the core
voltage raised to 1.25 V first. From the crystal the core runs at 40 MHz / (`PRE_DIV_CNT` + 1), 10 bits, so up to
1024. At each change of the APB clock the divider of UART0 is recomputed (the baud rate stays), as is the one of
timer 0 of the WiFi service, and `g_ticks_per_us` of both cores gets the new MHz (the ROM and `millis()` need it).
RC_FAST also needs the bit `DIG_CLK8M_EN`; without it the core gets no clock and stops. At the end of a program the
console only checks whether the core runs below 1 MHz (`PRE_DIV_CNT` 40 or more, or RC_FAST) and then switches back to
the undivided crystal; below 1 MHz the library leaves the UART divider at the value for 40 MHz
(`boards/esp32/console_clock.asm`).

**ESP32-S3.** As in ESP-IDF (`rtc_clk.c` and `clk_tree_ll.h` for the S3, with a 40 MHz crystal): the PLL runs at
480 MHz and gives 80, 160 and 240 MHz (`CPUPERIOD_SEL` 0, 1, 2 in `SYSTEM_CPU_PER_CONF`); the APB gets 80 MHz at each of
them. From the crystal the core runs at 40 MHz / (`PRE_DIV_CNT` + 1) (`SYSTEM_SYSCLK_CONF`, where `SOC_CLK_SEL` also
chooses between the crystal and the PLL). The PLL always stays on, so a change is only: the LDO steps for the new clock
(`SLAVE_PD` in `RTC_CNTL_DATE`: 7 >> (MHz / 80), 7 at the crystal), at 240 MHz one step more voltage on the core, then
`CPUPERIOD_SEL`, the divider and `SOC_CLK_SEL`. Going up, the voltage comes first; going down, it comes last. The ROM
has a single word for the cycles per microsecond, shared by both cores (`ets_update_cpu_frequency`); `ets_delay_us`,
`millis()` of the console and the WiFi service all work from it. Timer 0 of the WiFi service counts the crystal and
does not notice.

The voltage sits in two registers of an analog block (`I2C_DIG_REG`, block 0x6D: `EXT_RTC_DREG` and `EXT_DIG_DREG`,
registers 4 and 6, bits 4 … 0), which can only be reached over an I2C bus inside the chip. They read 24, and 25 for
240 MHz (ESP-IDF uses "dbias + 3" instead of "+ 2" there). Two things were needed for this to work reliably:

- **Not through `rom_i2c_readReg`.** This ROM function jumps through a table of functions in the ROM's RAM (its
  pointer at 0x3FCEF3D4). When the WiFi starts for the first time, the WiFi library puts its own I2C functions into
  that table, and they stay there until a reset. Those functions, however, need a pointer of the library
  (`g_phyFuns`), which is 0 after every new load of the WiFi service until the radio has started again. A change to or
  from 240 MHz right after `wlan on` therefore crashed (exception 0x1C at address 0x160). So `cpu_clock` writes the
  registers of the I2C master (from 0x6000E000) itself, the way the ROM functions behind the table do.
- **While the WiFi runs, the WiFi service does it.** The radio part of the WiFi uses the same I2C bus, on core 1;
  ESP-IDF protects it with a lock across both cores. Here the WiFi service sets the voltage itself (`wifi_dbias`,
  version 13 and later), on core 1 between the tasks of the WiFi: they only switch where they wait, never in the middle
  of a bus access. During a connection attempt the service handles such a request at once, so `cpu_clock` does not
  have to wait for the connection.

Restarting the WiFi no longer sets the clock to 160 MHz: from version 13 the WiFi service keeps a clock from the PLL,
as on the ESP32 from version 12. At the end of a program the console only checks whether the core runs from the
crystal below 10 MHz, and then switches back to the undivided crystal (`boards/esp32s3/console_clock.asm`).

**ESP32-C3.** As in ESP-IDF (`rtc_clk.c` and `clk_tree_ll.h` for the C3): the PLL runs at 480 MHz (the console sets it
up so at its start and leaves it on, as the USB port needs it) and gives 80 and 160 MHz (`CPUPERIOD_SEL` 0, 1 in
`SYSTEM_CPU_PER_CONF`, 0x600C0008); the APB gets 80 MHz at both. From the crystal the core runs at 40 MHz /
(`PRE_DIV_CNT` + 1) (`SYSTEM_SYSCLK_CONF`, 0x600C0058, which also holds `SOC_CLK_SEL`). A change sets these three
fields, writes the APB frequency for the ROM to `RTC_APB_FREQ_REG` (the Hz >> 12, in both halves) and tells the ROM the
cycles per microsecond (`ets_update_cpu_frequency`). The C3 does not need the I2C bus inside the chip for this, so none
of what the S3 needed applies.

Two things were still needed for this to work reliably with the WiFi. The C3 has a single core; the WiFi service runs
alongside while a program computes. So that `cpu_clock` knows whether the WiFi runs, the service has the entry
`wifi_state` from version 7. And `wlan off` now switches the WiFi off even when the board keeps no network: a program
may have started it, and before, it stayed on (and the crystal clocks stayed locked). The WiFi service sets the clock
only at its first start after a reset; from version 7 it keeps a clock from the PLL there instead of always taking
160 MHz. At the end of a program the console only checks whether the core runs from the crystal below 10 MHz (or from
RC_FAST), and then switches back to the undivided crystal (`boards/esp32c3/console_clock.asm`).

**Pico, Pico 2.** In the console clk_sys comes from the USB PLL (48 MHz). `cpu_clock` sets up PLL_SYS the way the
Pico SDK does: 12 MHz × FBDIV / (POSTDIV1 × POSTDIV2), with the VCO between 750 and 1600 MHz; the post dividers are
searched from the top until a VCO fits. The switch follows the datasheet: clk_sys to clk_ref (glitchless), PLL_SYS
reset, set up, waited for until it locks, then the auxiliary source and back. `cpu_clock_khz` leaves clk_sys on
clk_ref (the crystal) and divides with `CLK_SYS_DIV` (a 24-bit integer part on the RP2040, 16 bits on the RP2350). So
that the UART notices none of this, the console feeds clk_peri straight from the USB PLL instead of from clk_sys. At
the end of a program the console only switches back when clk_sys comes from the crystal
(`boards/pico/console_clock.asm`, shared by the Pico and the Pico 2); `info` works out the clock from the same
registers.

## More

- The libraries: `abelle/lib/esp32/cpuclock.abel`, `abelle/lib/esp32s3/cpuclock.abel`,
  `abelle/lib/esp32c3/cpuclock.abel`, `abelle/lib/pico/cpuclock.abel`, `abelle/lib/pico2/cpuclock.abel` (the head of each file describes it in detail).
- The aBelle language: [abelle/README.en.md](../../abelle/README.en.md).
- The boards and their consoles: [boards.md](boards.md).
