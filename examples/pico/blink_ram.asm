; Raspberry Pi Pico (RP2040, Cortex-M0+): blinks the LED at GPIO 25, in the RAM.
;
; The debugger loads it to 0x20000000 over the USB debug probe and stops at _start (F7) or runs it (F9).
; (On a Pico W the LED is on the wireless chip, not at GPIO 25.)
;
; Differences to the program for the Pico 2 (examples\pico2\blink_arm_ram.asm):
;   - the Cortex-M0+ knows Thumb-1 only: no movw/movt; a 32-bit constant comes from a word behind the
;     code with "ldr r0, name" (the words must be 4-byte aligned and at most 1 KB behind the ldr)
;   - other addresses of the registers, and no pad isolation to remove
.target pico
.arch thumb
.imagebase 0x20000000

RESET_DONE_OFFSET equ 0x08
RESET_IO_BANK0    equ 1 << 5
RESET_PADS_BANK0  equ 1 << 8
FUNCSEL_SIO       equ 5
SIO_GPIO_OE_SET   equ 0x24
SIO_GPIO_OUT_XOR  equ 0x1c

_start:
    ldr  r0, sram_end
    mov  sp, r0

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
sram_end:     dd 0x20042000
resets:       dd 0x4000c000
resets_clr:   dd 0x4000c000 + 0x3000      ; +0x3000 of a register address clears bits
reset_bits:   dd RESET_IO_BANK0 | RESET_PADS_BANK0
gpio25_ctrl:  dd 0x40014000 + 0xcc
sio:          dd 0xd0000000
led_mask:     dd 1 << 25
delay_count:  dd 1000000
