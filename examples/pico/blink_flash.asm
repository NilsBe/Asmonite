; Raspberry Pi Pico (RP2040, Cortex-M0+): blinks the LED at GPIO 25, from the flash.
;
; F7 / F9 write it into the flash over the USB debug probe (only the sectors that differ) and debug it
; there; Project > Save as UF2 file makes the file for the BOOTSEL drive. After a reset the Pico starts it
; by itself. (On a Pico W the LED is on the wireless chip, not at GPIO 25.)
;
; A program in the flash of the RP2040 starts with two blocks:
;   - boot2 (.boot2): 256 bytes that set up the flash chip, from the Pico SDK; the boot ROM checks their
;     CRC-32 and runs them
;   - the vector table at 0x10000100, where boot2 jumps: the stack pointer, then the start address (+1:
;     Thumb code)
; The rest is the program of blink_ram.asm.
.target pico
.arch thumb
.imagebase 0x10000000

RESET_DONE_OFFSET equ 0x08
RESET_IO_BANK0    equ 1 << 5
RESET_PADS_BANK0  equ 1 << 8
FUNCSEL_SIO       equ 5
SIO_GPIO_OE_SET   equ 0x24
SIO_GPIO_OUT_XOR  equ 0x1c

    .boot2

vectors:
    dd 0x20042000                ; stack pointer at the start (the end of the RAM)
    dd _start + 1                ; reset: the first instruction (+1: Thumb code)

_start:
    ; take IO_BANK0 and PADS_BANK0 out of reset
    ldr  r0, resets_clr
    ldr  r1, reset_bits
    str  r1, [r0]
    ldr  r0, resets
wait_reset:
    ldr  r2, [r0, #RESET_DONE_OFFSET]
    ands r2, r1
    cmp  r2, r1
    bne  wait_reset

    ; GPIO 25: function SIO, output
    ldr  r0, gpio25_ctrl
    movs r1, #FUNCSEL_SIO
    str  r1, [r0]
    ldr  r0, sio
    ldr  r1, led_mask
    str  r1, [r0, #SIO_GPIO_OE_SET]

blink_loop:
    str  r1, [r0, #SIO_GPIO_OUT_XOR]      ; toggle the LED
    ldr  r2, delay_count
delay:
    subs r2, r2, #1
    bne  delay
    b    blink_loop

; the constants, 4-byte aligned
align 4
resets:       dd 0x4000c000
resets_clr:   dd 0x4000c000 + 0x3000      ; +0x3000 of a register address clears bits
reset_bits:   dd RESET_IO_BANK0 | RESET_PADS_BANK0
gpio25_ctrl:  dd 0x40014000 + 0xcc
sio:          dd 0xd0000000
led_mask:     dd 1 << 25
delay_count:  dd 1000000
