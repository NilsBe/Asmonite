; STM32F103 ("Blue Pill", Arm Cortex-M3): "Hello, world!" about once a second through USART1, in the RAM.
;
; USART1 sends on PA9. The Raspberry Pi Debug Probe has a serial port of its own (its connector "U"): its RX at
; PA9, GND at G; its TX may go to PA10 (the RX of USART1, not used here). Press F9: the debugger loads the program
; over the probe (SWD), and the tab Serial next to the output window connects to the COM port of the probe and
; shows the text (115200 baud, 8N1).
;
; The registers (STM32F103 reference manual RM0008):
;   - RCC_APB2ENR (0x40021018): bit 2 IOPAEN (port A), bit 14 USART1EN
;   - GPIOA_CRH (0x40010804): 4 bits for each of the pins 8..15; PA9 is bits 4..7: MODE = 3 (output, 50 MHz),
;     CNF = 2 (alternate function push-pull: the pin belongs to USART1) = 0xB
;   - USART1 (0x40013800): SR 0x00 (bit 7 TXE: the data register takes the next byte), DR 0x04, BRR 0x08,
;     CR1 0x0c (bit 13 UE, bit 3 TE)
; After a reset the core and the APB2 bus run from the internal 8 MHz oscillator (HSI): BRR = 8,000,000 / 115200 =
; 69.4 = 0x45 (mantissa 4, fraction 5/16). The HSI is exact to about 1 %, enough for a UART.
.target stm32f103
.arch thumb
.imagebase 0x20000000

APB2_IOPAEN         equ 1 << 2
APB2_USART1EN       equ 1 << 14
GPIO_CRH            equ 0x04
PA9_MASK            equ 0xf << 4
PA9_AF_PUSH_PULL    equ 0xb << 4
USART_SR            equ 0x00
USART_SR_TXE        equ 1 << 7
USART_DR            equ 0x04
USART_BRR           equ 0x08
USART_CR1           equ 0x0c
BRR_115200_HSI      equ 0x45
CR1_UE_TE           equ (1 << 13) | (1 << 3)

_start:
    ; the clocks of port A and USART1
    ldr  r1, lit_rcc_apb2enr
    ldr  r0, [r1]
    ldr  r2, lit_apb2_bits
    orr  r0, r0, r2
    str  r0, [r1]

    ; PA9: alternate function, push-pull
    ldr  r1, lit_gpioa
    ldr  r0, [r1, #GPIO_CRH]
    bic  r0, r0, #PA9_MASK
    orr  r0, r0, #PA9_AF_PUSH_PULL
    str  r0, [r1, #GPIO_CRH]

    ; USART1: 115200 baud, 8N1, the sender on
    ldr  r4, lit_usart1
    movs r0, #BRR_115200_HSI
    str  r0, [r4, #USART_BRR]
    movw r0, #CR1_UE_TE
    str  r0, [r4, #USART_CR1]

again:
    adr  r5, message
next_byte:
    ldrb r0, [r5]
    cmp  r0, #0
    beq  sent
tx_wait:
    ldr  r1, [r4, #USART_SR]
    tst  r1, #USART_SR_TXE
    beq  tx_wait
    str  r0, [r4, #USART_DR]
    adds r5, r5, #1
    b    next_byte
sent:
    ldr  r2, lit_delay
delay:
    subs r2, r2, #1
    bne  delay
    b    again

    align 4
lit_rcc_apb2enr:   dd 0x40021018
lit_gpioa:         dd 0x40010800
lit_usart1:        dd 0x40013800
lit_apb2_bits:     dd APB2_IOPAEN | APB2_USART1EN
lit_delay:         dd 2000000              ; about a second at 8 MHz
message:
    db   'Hello, world!', 13, 10, 0
