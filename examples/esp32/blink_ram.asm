; ESP32 (the original, Xtensa LX6): the LED of the board at GPIO 2 (the blue one of the DevKit V1) on and off,
; half a second each.
;
;   1. plug in the board (its USB port goes to a USB serial chip: CP2102, CH340 ...)
;   2. press F9: Asmonite resets the chip into the download mode of its boot ROM over the lines DTR and RTS (as
;      esptool does; on some boards it takes a few tries, or hold BOOT), the boot ROM puts the program into the RAM
;      at 0x40080000 and jumps to _start
; There is no debugger for the ESP32 yet: the program just runs. After a reset (EN) the firmware of the flash runs
; again; blink_flash.asm is the same program for the flash.
;
; The times come from CCOUNT, the cycle counter of the core: it runs at 40 MHz (the crystal) in the download mode,
; so 20,000,000 cycles are half a second.
;
; The registers (ESP32 Technical Reference Manual, chapter "IO_MUX and GPIO Matrix"; ESP-IDF
; components/soc/esp32/include/soc: gpio_reg.h, io_mux_reg.h):
;   - IO_MUX_GPIO2_REG (0x3FF49040): MCU_SEL (bits 14..12) = 2 selects the function GPIO, FUN_DRV = 2.
;   - GPIO_FUNC2_OUT_SEL_CFG_REG (0x3FF44538): 0x100 (SIG_GPIO_OUT) puts the bit of GPIO_OUT on the pad.
;   - GPIO_OUT_W1TS (0x3FF44008), GPIO_OUT_W1TC (0x3FF4400C), GPIO_ENABLE_W1TS (0x3FF44024): bit n is GPIO n.
.target esp32
.arch xtensa
.imagebase 0x40080000

lit_gpio:     dd 0x3FF44000          ; the GPIO registers
lit_iomux2:   dd 0x3FF49040          ; IO_MUX_GPIO2_REG
lit_pad:      dd 0x2800              ; MCU_SEL = 2 (GPIO), FUN_DRV = 2
lit_half:     dd 20000000           ; half a second in cycles

_start:
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
