; Raspberry Pi Pico 2 (RP2350, RISC-V core Hazard3): blinks the LED at GPIO 25.
;
; This program runs in the RAM of the board, started by the debugger over OpenOCD:
;   1. connect the Pico 2 to the debug probe and start OpenOCD (Debug > Debug targets > RISC-V
;      board: "Test the connection")
;   2. press F9 (Run) or F7 (Step into): the program is loaded to 0x20000000 and stops at _start
;   3. step with F7/F8, set breakpoints with F5 (the core has 4 hardware breakpoints), look at the
;      registers x0..x31 and at the memory
;
; A program for the flash needs the IMAGE_DEF block in front of the code: see src\tests\riscv\blink.asm.
.target pico2
.arch riscv32
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
DELAY_COUNT       equ 1000000

_start:
    li   sp, SRAM_END

    ; take IO_BANK0 and PADS_BANK0 out of reset
    li   t0, RESETS_BASE + ALIAS_CLR
    li   t1, RESET_IO_BANK0 | RESET_PADS_BANK0
    sw   t1, 0(t0)
    li   t0, RESETS_BASE
wait_reset:
    lw   t2, RESET_DONE_OFFSET(t0)
    and  t2, t2, t1
    bne  t2, t1, wait_reset

    ; remove the pad isolation of GPIO 25
    li   t0, PADS_BANK0_BASE + ALIAS_CLR + PAD_GPIO25
    li   t1, PAD_ISO
    sw   t1, 0(t0)

    ; GPIO 25: function SIO, output
    li   t0, IO_BANK0_BASE + GPIO25_CTRL
    li   t1, FUNCSEL_SIO
    sw   t1, 0(t0)
    li   t0, SIO_BASE
    li   t1, LED_MASK
    sw   t1, SIO_GPIO_OE_SET(t0)

blink_loop:
    sw   t1, SIO_GPIO_OUT_XOR(t0)         ; toggle the LED
    li   t2, DELAY_COUNT
delay:
    addi t2, t2, -1
    bnez t2, delay
    j    blink_loop
