; Raspberry Pi Pico 2 (RP2350, Arm core Cortex-M33): blinks the LED at GPIO 25.
;
; The same program as blink_flash.asm, for the other pair of cores of the RP2350: the two Arm
; Cortex-M33 instead of the two RISC-V Hazard3. The boot ROM looks at the IMAGE_DEF block and
; starts the cores the program is for.
;
; Asmonite assembles it (.arch thumb: the Cortex-M33 runs Thumb code only), but cannot debug the
; Arm cores yet. To run it:
;   1. Project > Save as UF2 file (Raspberry Pi Pico)
;   2. hold the BOOTSEL button while you plug in the Pico 2, drag the file onto the drive
;
; Differences to the RISC-V program:
;   - a 32-bit constant is loaded with movw (low half) and movt (high half) instead of li
;   - there is a flags register: cmp sets it, bne branches on it
;   - the start of the image is the vector table of the Cortex-M: the stack pointer at the
;     start, then the address of the first instruction (with bit 0 set: Thumb code)
.target pico2
.arch thumb
.imagebase 0x10000000

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

; the vector table: the boot ROM takes the stack pointer and the start address from here
vectors:
    dd SRAM_END                  ; stack pointer at the start
    dd _start + 1                ; reset: the first instruction (+1: Thumb code)
    dd hang + 1                  ; NMI
    dd hang + 1                  ; HardFault

; IMAGE_DEF: tells the boot ROM that this is a program for the Arm cores of the RP2350
image_def:
    dd 0xffffded3                ; start marker
    db 0x42, 1                   ; item IMAGE_TYPE, 1 word
    dw 0x1021                    ; executable | Secure | Arm | RP2350
    db 0xff
    dw 1                         ; the items so far, in words
    db 0
    dd 0                         ; no further block
    dd 0xab123579                ; end marker

_start:
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

hang:
    b    hang
