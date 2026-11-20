; blink for the Raspberry Pi Pico 2 (RP2350, Hazard3 RISC-V core): blinks the LED at GPIO 25.
;
; This one goes into the flash (.imagebase 0x10000000): F7 over the USB probe writes it there (only the
; sectors that differ are erased and written) and stops at _start. The IMAGE_DEF block at the start
; tells the boot ROM that RISC-V code follows, so the program also starts by itself after a reset.
.target pico2
.arch riscv32
.imagebase 0x10000000

RESETS_BASE      equ 0x40020000
IO_BANK0_BASE    equ 0x40028000
PADS_BANK0_BASE  equ 0x40038000
SIO_BASE         equ 0xd0000000
SRAM_END         equ 0x20082000
ALIAS_CLR        equ 0x3000
RESET_OFFSET     equ 0x00
RESET_DONE_OFFSET equ 0x08
RESET_IO_BANK0   equ 1 << 6
RESET_PADS_BANK0 equ 1 << 9
GPIO25_CTRL      equ 0xcc
FUNCSEL_SIO      equ 5
PAD_GPIO25       equ 0x68
PAD_ISO          equ 1 << 8
SIO_GPIO_OE_SET  equ 0x38
SIO_GPIO_OUT_XOR equ 0x28
LED_MASK         equ 1 << 25
DELAY_COUNT      equ 1000000

; IMAGE_DEF block: tells the boot ROM that RISC-V code follows (must be in the first 4 KB)
image_def:
    dd 0xffffded3            ; start marker
    db 0x42, 1               ; item IMAGE_TYPE, 1 word
    dw 0x1101                ; EXE | RISC-V | RP2350
    db 0x44, 3               ; item ENTRY_POINT, 3 words
    dw 0                     ; padding
    dd _start                ; pc at the start
    dd SRAM_END              ; initial stack pointer
    db 0xff                  ; item LAST
    dw 4                     ; sum of the sizes of the items before (in words)
    db 0
    dd 0                     ; offset to the next block (0: only this one)
    dd 0xab123579            ; end marker

_start:
    li   sp, SRAM_END
    li   t0, RESETS_BASE + ALIAS_CLR
    li   t1, RESET_IO_BANK0 | RESET_PADS_BANK0
    sw   t1, RESET_OFFSET(t0)
    li   t0, RESETS_BASE
wait_reset:
    lw   t2, RESET_DONE_OFFSET(t0)
    and  t2, t2, t1
    bne  t2, t1, wait_reset
    li   t0, PADS_BANK0_BASE + ALIAS_CLR + PAD_GPIO25
    li   t1, PAD_ISO
    sw   t1, 0(t0)
    li   t0, IO_BANK0_BASE + GPIO25_CTRL
    li   t1, FUNCSEL_SIO
    sw   t1, 0(t0)
    li   t0, SIO_BASE
    li   t1, LED_MASK
    sw   t1, SIO_GPIO_OE_SET(t0)
blink_loop:
    sw   t1, SIO_GPIO_OUT_XOR(t0)
    li   t2, DELAY_COUNT
delay:
    addi t2, t2, -1
    bnez t2, delay
    j    blink_loop
