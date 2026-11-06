; ESP32 (the original, Xtensa LX6): the LED of the board at GPIO 2 on and off, half a second each; the program of
; blink_ram.asm for the flash: it runs at every start of the board.
;
;   1. plug in the board (its USB port goes to a USB serial chip: CP2102, CH340 ...); no terminal may have its
;      COM port open
;   2. press F9: Asmonite resets the chip into the download mode of its boot ROM (on some boards it takes a few
;      tries, or hold BOOT), writes the program as an image of the boot ROM into the flash at 0x1000 and resets the
;      chip: the boot ROM copies it into the RAM at 0x40080000 and jumps to _start, now and after every reset
; The program replaces the firmware that was in the flash (its bootloader at 0x1000, where the boot ROM looks).
;
; A program that the boot ROM starts from the flash has to switch the watchdogs off itself (the boot ROM switches
; them on for this start, the bootloader of ESP-IDF switches them off again): the watchdogs of the timer groups 0
; and 1 and the RTC watchdog. Each is unlocked with the key 0x50D83AA1 in its WPROTECT register, switched off
; (WDTCONFIG0 = 0) and locked again. Else the chip resets after a few seconds.
;
; The core runs at 40 MHz (the crystal) here as well: 20,000,000 cycles of CCOUNT are half a second.
;
; The registers (ESP32 Technical Reference Manual; ESP-IDF components/soc/esp32/include/soc: gpio_reg.h,
; io_mux_reg.h, timer_group_reg.h, rtc_cntl_reg.h): the GPIO ones as in blink_ram.asm;
; TIMG0 0x3FF5F000 and TIMG1 0x3FF60000: WDTCONFIG0 at 0x48, WDTWPROTECT at 0x64;
; RTC_CNTL 0x3FF48000: WDTCONFIG0 at 0x8C, WDTWPROTECT at 0xA4.
.target esp32 flash
.arch xtensa
.imagebase 0x40080000

lit_gpio:     dd 0x3FF44000          ; the GPIO registers
lit_iomux2:   dd 0x3FF49040          ; IO_MUX_GPIO2_REG
lit_pad:      dd 0x2800              ; MCU_SEL = 2 (GPIO), FUN_DRV = 2
lit_half:     dd 20000000            ; half a second in cycles
lit_wdt_key:  dd 0x50D83AA1          ; the key that unlocks the watchdog registers
lit_timg0:    dd 0x3FF5F000          ; timer group 0
lit_timg1:    dd 0x3FF60000          ; timer group 1
lit_rtc_cntl: dd 0x3FF48000          ; RTC_CNTL

_start:
  ; the watchdogs off
  l32r  a2, lit_wdt_key
  movi  a3, 0
  l32r  a4, lit_timg0
  s32i  a2, a4, 0x64                 ; unlock
  s32i  a3, a4, 0x48                 ; WDTCONFIG0 = 0: off
  s32i  a3, a4, 0x64                 ; lock
  l32r  a4, lit_timg1
  s32i  a2, a4, 0x64
  s32i  a3, a4, 0x48
  s32i  a3, a4, 0x64
  l32r  a4, lit_rtc_cntl
  s32i  a2, a4, 0xA4                 ; WDTWPROTECT: unlock
  s32i  a3, a4, 0x8C                 ; WDTCONFIG0 = 0
  s32i  a3, a4, 0xA4                 ; lock
  memw

  l32r  a2, lit_gpio
  l32r  a4, lit_iomux2
  l32r  a5, lit_pad
  s32i  a5, a4, 0
  movi  a5, 0x100                    ; SIG_GPIO_OUT
  movi  a4, 0x538                    ; GPIO_FUNC2_OUT_SEL_CFG_REG - GPIO
  add   a4, a4, a2
  s32i  a5, a4, 0
  movi  a3, 4                        ; 1 << 2: GPIO 2
  s32i  a3, a2, 0x24                 ; GPIO_ENABLE_W1TS: an output
  l32r  a7, lit_half

loop:
  s32i  a3, a2, 0x08                 ; GPIO_OUT_W1TS: on
  call0 wait
  s32i  a3, a2, 0x0C                 ; GPIO_OUT_W1TC: off
  call0 wait
  j     loop

; waits a7 cycles (call0: the return address in a0, no register window; a call target stands at a multiple
; of 4)
align 4
wait:
  rsr   a9, ccount
wait_more:
  rsr   a10, ccount
  sub   a10, a10, a9
  bltu  a10, a7, wait_more
  ret
