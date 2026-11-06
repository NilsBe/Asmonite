; LilyGO T-PicoC3, the RP2040 side: colourful lines on the display (ST7789, 135 x 240): a black screen, a white
; frame at its edge, and lines in the colours of the rainbow; then the program returns.
;
; Made for the debugger over the USB boot (no debug probe): plug the USB-C plug in so that the RP2040 is connected
; (its LED is blue), hold BOOT, press RUN, let go of BOOT (the drive RPI-RP2 appears), then F9: the program draws
; and returns, the output window shows r0 = 0, and the board is ready for the next F9. With F7 you can step
; through it; a breakpoint at "bl fill_rect" in the loop draws one line for each F9.
;
; The visible 135 x 240 pixels lie inside the memory of the controller (240 x 320) at column 52 and row 40 (as on
; other boards with this panel): fill_rect adds that. If the frame is not whole at the edge, the offsets differ.
;
; fill_rect: the rectangle from (x0, y0) to (x1, y1) in one colour: CASET (the columns), RASET (the rows), RAMWR,
; then two bytes for each pixel (5 bits red, 6 green, 5 blue). Its arguments are in r8..r11 and r6, because the
; Cortex-M0+ has few low registers and command and data use r3 and r7. The setup of the clock, the pins, the SPI
; and the display is the one of display_ram.asm.
.target pico
.arch thumb
.imagebase 0x20000000

RESET_DONE_OFFSET equ 0x08
FUNCSEL_SPI       equ 1
FUNCSEL_SIO       equ 5
SIO_GPIO_OUT_SET  equ 0x14
SIO_GPIO_OUT_CLR  equ 0x18
SIO_GPIO_OE_SET   equ 0x24
SSPCR0            equ 0x00
SSPCR1            equ 0x04
SSPDR             equ 0x08
SSPSR             equ 0x0c
SSPCPSR           equ 0x10
PIN_RST           equ 1 << 0
PIN_DC            equ 1 << 1
PIN_BL            equ 1 << 4
PIN_CS            equ 1 << 5
COL_OFFSET        equ 52                ; where the visible picture lies in the memory of the controller
ROW_OFFSET        equ 40

_start:
    push {r4, r5, r6, r7, lr}

    ; the clock of the SPI on (clk_peri from clk_sys)
    ldr  r0, clk_peri_ctrl
    ldr  r1, clk_enable
    str  r1, [r0]

    ; IO_BANK0, PADS_BANK0 and SPI0 out of reset
    ldr  r0, resets_clr
    ldr  r1, reset_bits
    str  r1, [r0]
    ldr  r0, resets
wait_reset:
    ldr  r2, [r0, #RESET_DONE_OFFSET]
    ands r2, r1
    cmp  r2, r1
    bne  wait_reset

    ; the pins: RST, DC, BL, CS, PWR_ON and the LED as outputs, SCLK and MOSI to SPI0
    ldr  r0, io_bank0
    movs r1, #FUNCSEL_SIO
    str  r1, [r0, #0x04]                ; GPIO0_CTRL: RST
    str  r1, [r0, #0x0c]                ; GPIO1_CTRL: DC
    str  r1, [r0, #0x24]                ; GPIO4_CTRL: BL
    str  r1, [r0, #0x2c]                ; GPIO5_CTRL: CS
    movs r2, #0xb4
    str  r1, [r0, r2]                   ; GPIO22_CTRL: PWR_ON
    movs r2, #0xcc
    str  r1, [r0, r2]                   ; GPIO25_CTRL: the LED
    movs r1, #FUNCSEL_SPI
    str  r1, [r0, #0x14]                ; GPIO2_CTRL: SCLK
    str  r1, [r0, #0x1c]                ; GPIO3_CTRL: MOSI

    ldr  r5, sio
    ldr  r1, out_pins
    str  r1, [r5, #SIO_GPIO_OE_SET]
    ldr  r1, high_pins                  ; RST, DC, CS high, the power on
    str  r1, [r5, #SIO_GPIO_OUT_SET]

    ; SPI0: 8 bits, mode 0, clk_peri / 4
    ldr  r4, spi0
    movs r1, #7
    str  r1, [r4, #SSPCR0]
    movs r1, #4
    str  r1, [r4, #SSPCPSR]
    movs r1, #2
    str  r1, [r4, #SSPCR1]

    ; a reset of the display, then 120 ms
    ldr  r0, delay_short
    bl   wait
    movs r1, #PIN_RST
    str  r1, [r5, #SIO_GPIO_OUT_CLR]
    ldr  r0, delay_short
    bl   wait
    str  r1, [r5, #SIO_GPIO_OUT_SET]
    ldr  r0, delay_long
    bl   wait
    movs r1, #PIN_CS                    ; CS low from here on
    str  r1, [r5, #SIO_GPIO_OUT_CLR]

    movs r0, #0x11                      ; SLPOUT, then 120 ms
    bl   command
    ldr  r0, delay_long
    bl   wait
    movs r0, #0x3a                      ; COLMOD: 16 bits a pixel
    bl   command
    movs r0, #0x55
    bl   data
    movs r0, #0x36                      ; MADCTL: the normal direction (upright)
    bl   command
    movs r0, #0
    bl   data
    movs r0, #0x21                      ; INVON
    bl   command
    movs r0, #0x13                      ; NORON
    bl   command
    movs r0, #0x29                      ; DISPON
    bl   command

    ; black: the whole picture
    movs r6, #0
    movs r0, #0
    mov  r8, r0
    mov  r9, r0
    movs r0, #134
    mov  r10, r0
    movs r0, #239
    mov  r11, r0
    bl   fill_rect

    ; the backlight on: from here on the drawing can be seen
    movs r1, #PIN_BL
    str  r1, [r5, #SIO_GPIO_OUT_SET]

    ; the lines: 4 pixels high, every 8 pixels, from y = 6 on; the colours from the table, one after the other
    adr  r2, colours
    movs r0, #6
    mov  r12, r0                        ; y of the next line
line_loop:
    ldrh r6, [r2]
    adds r2, #2
    ldr  r0, colours_end
    cmp  r2, r0
    bne  colour_ok
    adr  r2, colours                    ; the table from its start again
colour_ok:
    movs r0, #4
    mov  r8, r0                         ; x0
    movs r0, #130
    mov  r10, r0                        ; x1
    mov  r0, r12
    mov  r9, r0                         ; y0
    adds r0, #3
    mov  r11, r0                        ; y1 = y0 + 3
    bl   fill_rect
    mov  r0, r12
    adds r0, #8
    mov  r12, r0
    cmp  r0, #232
    bcc  line_loop

    ; the white frame at the edge, 2 pixels wide: top, bottom, left, right
    ldr  r6, white
    movs r0, #0
    mov  r8, r0
    mov  r9, r0
    movs r0, #134
    mov  r10, r0
    movs r0, #1
    mov  r11, r0
    bl   fill_rect                      ; top
    movs r0, #238
    mov  r9, r0
    movs r0, #239
    mov  r11, r0
    bl   fill_rect                      ; bottom
    movs r0, #0
    mov  r9, r0
    movs r0, #1
    mov  r10, r0
    bl   fill_rect                      ; left (x 0..1, y 0..239)
    movs r0, #133
    mov  r8, r0
    movs r0, #134
    mov  r10, r0
    bl   fill_rect                      ; right

    ; until the last byte is out, then the LED on, and back
    movs r7, #0x10
last_byte:
    ldr  r3, [r4, #SSPSR]
    tst  r3, r7
    bne  last_byte
    ldr  r1, led
    str  r1, [r5, #SIO_GPIO_OUT_SET]
    movs r0, #0
    pop  {r4, r5, r6, r7, pc}

; fill_rect: the rectangle (r8, r9) .. (r10, r11) of the visible picture in the colour r6 (uses r0, r1, r3, r7)
fill_rect:
    push {lr}
    movs r0, #0x2a                      ; CASET: x0 .. x1 (+ the column offset)
    bl   command
    mov  r1, r8
    adds r1, #COL_OFFSET
    lsrs r0, r1, #8
    bl   data
    mov  r0, r1
    bl   data
    mov  r1, r10
    adds r1, #COL_OFFSET
    lsrs r0, r1, #8
    bl   data
    mov  r0, r1
    bl   data
    movs r0, #0x2b                      ; RASET: y0 .. y1 (+ the row offset)
    bl   command
    mov  r1, r9
    adds r1, #ROW_OFFSET
    lsrs r0, r1, #8
    bl   data
    mov  r0, r1
    bl   data
    mov  r1, r11
    adds r1, #ROW_OFFSET
    lsrs r0, r1, #8
    bl   data
    mov  r0, r1
    bl   data
    movs r0, #0x2c                      ; RAMWR, then (x1 - x0 + 1) * (y1 - y0 + 1) pixels
    bl   command
    mov  r0, r10
    mov  r1, r8
    subs r0, r0, r1
    adds r0, #1
    mov  r1, r11
    mov  r3, r9
    subs r1, r1, r3
    adds r1, #1
    muls r1, r0, r1
fill_pixel:
    lsrs r0, r6, #8                     ; the high byte of the colour, then the low one (SSPDR takes 8 bits)
    bl   data
    mov  r0, r6
    bl   data
    subs r1, #1
    bne  fill_pixel
    pop  {pc}

; command: sends the byte in r0 with DC low (r4 = SPI0, r5 = SIO; uses r3, r7)
command:
    movs r7, #0x10                      ; BSY: DC changes only when the SPI is idle
command_idle:
    ldr  r3, [r4, #SSPSR]
    tst  r3, r7
    bne  command_idle
    movs r3, #PIN_DC
    str  r3, [r5, #SIO_GPIO_OUT_CLR]
    str  r0, [r4, #SSPDR]
command_sent:
    ldr  r3, [r4, #SSPSR]
    tst  r3, r7
    bne  command_sent
    movs r3, #PIN_DC
    str  r3, [r5, #SIO_GPIO_OUT_SET]
    bx   lr

; data: sends the byte in r0 with DC high, as soon as the FIFO has room (uses r3, r7)
data:
    movs r7, #2                         ; TNF: the transmit FIFO is not full
data_room:
    ldr  r3, [r4, #SSPSR]
    tst  r3, r7
    beq  data_room
    str  r0, [r4, #SSPDR]
    bx   lr

; wait: counts r0 down to 0 (about 3 cycles a step)
wait:
    subs r0, r0, #1
    bne  wait
    bx   lr

; the constants, 4-byte aligned
align 4
clk_peri_ctrl: dd 0x40008000 + 0x48
clk_enable:    dd 1 << 11                   ; ENABLE, AUXSRC 0 = clk_sys
resets:        dd 0x4000c000
resets_clr:    dd 0x4000c000 + 0x3000       ; +0x3000 of a register address clears bits
reset_bits:    dd (1 << 5) | (1 << 8) | (1 << 16)   ; IO_BANK0, PADS_BANK0, SPI0
io_bank0:      dd 0x40014000
sio:           dd 0xd0000000
spi0:          dd 0x4003c000
out_pins:      dd PIN_RST | PIN_DC | PIN_BL | PIN_CS | (1 << 22) | (1 << 25)
high_pins:     dd PIN_RST | PIN_DC | PIN_CS | (1 << 22)
led:           dd 1 << 25
white:         dd 0xffff
delay_short:   dd 200000
delay_long:    dd 2000000
colours_end:   dd colours + 14

; the colours of the lines (RGB565): red, orange, yellow, green, cyan, blue, violet
colours:
    dw 0xf800, 0xfc00, 0xffe0, 0x07e0, 0x07ff, 0x001f, 0x801f
