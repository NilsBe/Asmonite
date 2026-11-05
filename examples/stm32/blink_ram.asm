; STM32F103 ("Blue Pill", Arm Cortex-M3): blinks the LED at PC13, in the RAM.
;
; The debugger loads it into the RAM at 0x20000000 over the USB debug probe (SWCLK, SWDIO, GND at the four
; pins of the board; 3V3 stays free, the board gets its power over its own USB) and stops at _start (F7) or
; runs it (F9). Nothing is written to the flash: after a reset the board runs its old program again.
;
; The registers (STM32F103 reference manual RM0008):
;   - RCC_APB2ENR (0x40021018): bit 4 IOPCEN switches the clock of the port C on
;   - GPIOC_CRH (0x40011004): 4 bits for each of the pins 8..15; PC13 is bits 20..23: MODE = 2 (output,
;     2 MHz), CNF = 0 (push-pull)
;   - GPIOC_BSRR (0x40011010): bit 13 sets PC13 (LED off: the LED is between 3V3 and the pin), bit 29 clears
;     it (LED on)
; After a reset the core runs from the internal 8 MHz oscillator (HSI).
.target stm32f103
.arch thumb
.imagebase 0x20000000

RCC_APB2ENR         equ 0x40021018
IOPCEN              equ 1 << 4
GPIOC_BASE          equ 0x40011000
GPIO_CRH            equ 0x04
GPIO_BSRR           equ 0x10
PC13_MODE_MASK      equ 0xf << 20
PC13_OUTPUT_2MHZ    equ 0x2 << 20
LED_OFF             equ 1 << 13         ; BSRR: set the pin
LED_ON              equ 1 << 29         ; BSRR: clear the pin
DELAY_COUNT         equ 500000

_start:
    ldr  r1, lit_rcc_apb2enr
    ldr  r0, [r1]
    orr  r0, r0, #IOPCEN
    str  r0, [r1]               ; the clock of port C on

    ldr  r1, lit_gpioc
    ldr  r0, [r1, #GPIO_CRH]
    bic  r0, r0, #PC13_MODE_MASK
    orr  r0, r0, #PC13_OUTPUT_2MHZ
    str  r0, [r1, #GPIO_CRH]    ; PC13: output, push-pull

    ldr  r2, lit_led_on
    ldr  r3, lit_led_off
blink_loop:
    str  r2, [r1, #GPIO_BSRR]   ; LED on
    ldr  r0, lit_delay_value
delay_on:
    subs r0, r0, #1
    bne  delay_on
    str  r3, [r1, #GPIO_BSRR]   ; LED off
    ldr  r0, lit_delay_value
delay_off:
    subs r0, r0, #1
    bne  delay_off
    b    blink_loop

    align 4
lit_rcc_apb2enr: dd RCC_APB2ENR
lit_gpioc:       dd GPIOC_BASE
lit_led_on:      dd LED_ON
lit_led_off:     dd LED_OFF
lit_delay_value: dd DELAY_COUNT
