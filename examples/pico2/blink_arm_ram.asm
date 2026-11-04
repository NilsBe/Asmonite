; Raspberry Pi Pico 2 (RP2350, Arm core Cortex-M33): blinks the LED at GPIO 25, in the RAM.
;
; The same program as blink_ram.asm, for the Arm cores of the RP2350; blink_arm_flash.asm is the version
; for the flash. The debugger loads it to 0x20000000 over the USB probe and stops at _start (F7) or runs
; it (F9). The chip must run its Arm cores: a program in the RAM cannot switch them, so start
; blink_arm_flash.asm once first if the chip runs its RISC-V cores (the debugger switches it then).
;
; Differences to the RISC-V program:
;   - a 32-bit constant is loaded with movw (low half) and movt (high half) instead of li
;   - there is a flags register: cmp sets it, bne branches on it
.target pico2
.arch thumb
.imagebase 0x20000000

RESETS_BASE       equ 0x40020000
IO_BANK0_BASE     equ 0x40028000
PADS_BANK0_BASE   equ 0x40038000
SIO_BASE          equ 0xd0000000
SRAM_END          equ 0x20082000
ALIAS_CLR         equ 0x3000              ; +0x3000 of a register address clears bits
RESET_DONE_OFFSET equ 0x08
RESET_IO_BANK0    equ 1 << 6
RESET_PADS_BANK0  equ 1 << 9
GPIO25_CTRL       equ 0xcc
FUNCSEL_SIO       equ 5
PAD_GPIO25        equ 0x68
PAD_ISO           equ 1 << 8              ; pad isolation: on after a reset of the RP2350
SIO_GPIO_OE_SET   equ 0x38
SIO_GPIO_OUT_XOR  equ 0x28
LED_MASK          equ 1 << 25
DELAY_COUNT       equ 9000000

_start:
    movw r0, #(SRAM_END & 0xffff)
    movt r0, #(SRAM_END >> 16)
    mov  sp, r0

    ; take IO_BANK0 and PADS_BANK0 out of reset
    movw r0, #((RESETS_BASE + ALIAS_CLR) & 0xffff)
    movt r0, #((RESETS_BASE + ALIAS_CLR) >> 16)
    movw r1, #(RESET_IO_BANK0 | RESET_PADS_BANK0)
    str  r1, [r0]
    movw r0, #(RESETS_BASE & 0xffff)
    movt r0, #(RESETS_BASE >> 16)
wait_reset:
    ldr  r2, [r0, #RESET_DONE_OFFSET]
    and  r2, r2, r1
    cmp  r2, r1
    bne  wait_reset

    ; remove the pad isolation of GPIO 25
    movw r0, #((PADS_BANK0_BASE + ALIAS_CLR + PAD_GPIO25) & 0xffff)
    movt r0, #((PADS_BANK0_BASE + ALIAS_CLR + PAD_GPIO25) >> 16)
    movw r1, #PAD_ISO
    str  r1, [r0]

    ; GPIO 25: function SIO, output
    movw r0, #((IO_BANK0_BASE + GPIO25_CTRL) & 0xffff)
    movt r0, #((IO_BANK0_BASE + GPIO25_CTRL) >> 16)
    movs r1, #FUNCSEL_SIO
    str  r1, [r0]
    movw r0, #(SIO_BASE & 0xffff)
    movt r0, #(SIO_BASE >> 16)
    movw r1, #(LED_MASK & 0xffff)
    movt r1, #(LED_MASK >> 16)
    str  r1, [r0, #SIO_GPIO_OE_SET]

blink_loop:
    str  r1, [r0, #SIO_GPIO_OUT_XOR]      ; toggle the LED
    movw r2, #(DELAY_COUNT & 0xffff)
    movt r2, #(DELAY_COUNT >> 16)
delay:
    subs r2, r2, #1
    bne  delay
    b    blink_loop

