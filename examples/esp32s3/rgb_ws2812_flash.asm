; ESP32-S3: the RGB LED of the board (a WS2812 at GPIO 48) shows red, green and blue in turn, half a second each;
; the program of rgb_ws2812_ram.asm for the flash: it runs at every start of the board, also without the debugger.
;
;   1. plug in the board at the USB port of the chip (Debug > Debug targets: "Set up the USB JTAG" once for each
;      board; a firmware that uses the USB port itself needs BOOT held while RST is pressed, once)
;   2. press F9 (Run) or F7 (Step into): the debugger writes the program as an image of the boot ROM into the flash
;      (over the USB serial port of the chip; a terminal must not have it open), then puts it into the IRAM at
;      0x40378000 as the boot ROM does and runs it there (F7: stops at _start)
;   3. after RST (or unplugged and plugged in again) the boot ROM starts it from the flash by itself
; The program replaces the firmware that was in the flash (at the flash address 0, where the boot ROM looks).
;
; A program that the boot ROM starts from the flash has to switch the watchdogs off itself (the boot ROM switches
; them on; in the download mode they are off): the watchdogs of the timer groups 0 and 1, the RTC watchdog, and the
; super watchdog, which is told to feed itself. Else the chip resets after a few seconds.
;
; Xtensa in short: 16 address registers a0..a15 are a window onto 64 physical ones. call8 turns the window by
; 8 registers when the called function runs entry: its a2..a7 are a10..a15 of the caller (the arguments), its a1
; is the stack pointer, a0 the return address; retw turns the window back. l32r loads a word from a literal
; that stands before the code (the lit_ words): the constants of more than 12 bits come from there.
;
; A WS2812 takes 24 bits (green, red, blue, the high bit first): a 1 is high for 0.7 us, a 0 for 0.35 us, each bit
; 1.25 us; low for more than 50 us takes the colour. The times come from CCOUNT, the cycle counter of the core.
; The core runs from the 40 MHz crystal, divided by SYSTEM_SYSCLK_CONF (0x600C0060, PRE_DIV_CNT in bits 9..0): the
; boot ROM leaves it at 1 (20 MHz) when it starts a program from the flash, at 0 (40 MHz) in its download mode; the
; program sets it to 0 itself, so the times are the same either way. A step in the debugger (inside send_color)
; stretches a bit: the LED then shows some other colour until the next one is sent in full.
;
; The registers (ESP32-S3 Technical Reference Manual, chapter "IO MUX and GPIO Matrix"; ESP-IDF
; components/soc/esp32s3/include/soc: gpio_reg.h, io_mux_reg.h):
;   - IO_MUX_GPIO48 (0x600090C4): MCU_SEL (bits 14..12) = 1 selects the function GPIO, FUN_DRV = 2.
;   - GPIO_FUNC48_OUT_SEL_CFG (0x60004614): 0x100 (SIG_GPIO_OUT) puts the bit of GPIO_OUT1 on the pad.
;   - GPIO_OUT1_W1TS (0x60004014), GPIO_OUT1_W1TC (0x60004018), GPIO_ENABLE1_W1TS (0x60004030): GPIO 32..48,
;     bit 16 is GPIO 48.
.target esp32s3 flash
.arch xtensa
.imagebase 0x40378000

lit_gpio:      dd 0x60004000          ; the GPIO registers
lit_iomux48:   dd 0x600090C4
lit_func48:    dd 0x60004614
lit_pad:       dd 0x1800              ; MCU_SEL = 1 (GPIO), FUN_DRV = 2
lit_led:       dd 0x10000             ; GPIO 48 in the registers of GPIO 32..48
lit_bit23:     dd 0x800000            ; the first bit that goes out
lit_red:       dd 0x002000            ; green, red, blue: not too bright
lit_green:     dd 0x200000
lit_blue:      dd 0x000020
lit_half:      dd 20000000            ; half a second in cycles
lit_sysclk:    dd 0x600C0060          ; SYSTEM_SYSCLK_CONF
lit_wdt_key:   dd 0x50D83AA1          ; the key that unlocks the watchdog registers
lit_swd_key:   dd 0x8F1D312A          ; the key of the super watchdog
lit_timg0:     dd 0x6001F000          ; timer group 0: WDTCONFIG0 at 0x48, WDTWPROTECT at 0x64
lit_timg1:     dd 0x60020000          ; timer group 1
lit_rtc_cntl:  dd 0x60008000          ; RTC: WDTCONFIG0 at 0x98, WDTWPROTECT at 0xB0, SWD_CONF at 0xB4,
                                      ; SWD_WPROTECT at 0xB8
lit_bit31:     dd 0x80000000          ; SWD_AUTO_FEED_EN

_start:
  ; the watchdogs off
  l32r  a2, lit_wdt_key
  movi  a4, 0
  l32r  a3, lit_timg0
  s32i  a2, a3, 0x64                  ; unlock
  s32i  a4, a3, 0x48                  ; off
  s32i  a4, a3, 0x64                  ; lock
  l32r  a3, lit_timg1
  s32i  a2, a3, 0x64
  s32i  a4, a3, 0x48
  s32i  a4, a3, 0x64
  l32r  a3, lit_rtc_cntl
  s32i  a2, a3, 0xb0
  s32i  a4, a3, 0x98
  s32i  a4, a3, 0xb0
  l32r  a2, lit_swd_key
  s32i  a2, a3, 0xb8
  l32i  a5, a3, 0xb4
  l32r  a6, lit_bit31
  or    a5, a5, a6
  s32i  a5, a3, 0xb4                  ; the super watchdog feeds itself
  s32i  a4, a3, 0xb8
  memw
  ; the core at 40 MHz: PRE_DIV_CNT = 0
  l32r  a3, lit_sysclk
  l32i  a4, a3, 0
  movi  a5, -1024                     ; 0xFFFFFC00: all bits but those of PRE_DIV_CNT
  and   a4, a4, a5
  s32i  a4, a3, 0
  memw
  ; GPIO 48: a GPIO, an output, low
  l32r  a2, lit_gpio
  l32r  a3, lit_iomux48
  l32r  a4, lit_pad
  s32i  a4, a3, 0
  l32r  a3, lit_func48
  movi  a4, 0x100
  s32i  a4, a3, 0
  l32r  a3, lit_led
  s32i  a3, a2, 0x18                  ; GPIO_OUT1_W1TC: low
  s32i  a3, a2, 0x30                  ; GPIO_ENABLE1_W1TS: an output
  memw
colors:
  l32r  a10, lit_red
  call8 send_color
  l32r  a10, lit_half
  call8 wait
  l32r  a10, lit_green
  call8 send_color
  l32r  a10, lit_half
  call8 wait
  l32r  a10, lit_blue
  call8 send_color
  l32r  a10, lit_half
  call8 wait
  j     colors

; send_color(a2 = the colour as GRB): the 24 bits to the WS2812
  align 4
send_color:
  entry a1, 32
  l32r  a3, lit_gpio
  l32r  a4, lit_led
  l32r  a5, lit_bit23
  movi  a6, 6                         ; cycles to wait: a 0 is high for about 0.3 us, a 1 for about 0.7 us
  movi  a7, 22                        ; (the loops and the GPIO write add 4 to 8 cycles)
  movi  a8, 50                        ; every bit 1.25 us
next_bit:
  rsr.ccount a9                       ; the start of the bit
  s32i  a4, a3, 0x14                  ; GPIO_OUT1_W1TS: high (no memw here: it would stretch the bit)
  and   a10, a2, a5
  mov   a11, a6
  beqz  a10, high_time
  mov   a11, a7
high_time:
  rsr.ccount a12
  sub   a12, a12, a9
  bltu  a12, a11, high_time
  s32i  a4, a3, 0x18                  ; GPIO_OUT1_W1TC: low
low_time:
  rsr.ccount a12
  sub   a12, a12, a9
  bltu  a12, a8, low_time
  srli  a5, a5, 1
  bnez  a5, next_bit
  retw

; wait(a2 = cycles)
  align 4
wait:
  entry a1, 32
  rsr.ccount a3
waiting:
  rsr.ccount a4
  sub   a4, a4, a3
  bltu  a4, a2, waiting
  retw
