; LilyGO T-PicoC3, the RP2040 side: text on the display (ST7789, 135 x 240) and a counter that counts up, with a
; font of its own (5 x 7 dots, digits, capitals and a few signs); the red LED blinks with each count. A key (GPIO 6
; or 7) ends the program: it returns.
;
; Made for the debugger over the USB boot (no debug probe): the RP2040 at the USB-C plug (its LED is blue), hold
; BOOT, press RUN, let go of BOOT (the drive RPI-RP2), then F9. The program draws, counts until a key is pressed and
; returns (r0 = the last digit of the count), and the board is ready for the next F9. A running
; program cannot be paused over the USB boot: for steps, set a breakpoint first (in draw_char, say, to see a letter
; come up dot by dot). If no key ends it, RUN does.
;
; How the text comes about: draw_text takes the characters of a string one by one, draw_char looks up the 7 rows of
; a character in the font (8 bytes each from the space on: (code - 32) * 8; bit 4 of a row is the left dot) and
; draws each of the 5 x 7 dots as a square of scale x scale pixels with fill_rect, in the colour of the text or of
; the background. Then the next character starts 6 dots further right.
;
; The counter: five ASCII digits in the RAM, counted up from the last one as on paper (a 9 becomes 0 and the digit
; before goes up by one). The Cortex-M0+ has no division, so this needs none.
;
; The keys: inputs with the pull-up of their pads on (PADS_BANK0: IE, PUE, SCHMITT); a pressed key pulls its pin to
; GND (so on the T-PicoC3). SIO GPIO_IN has their state.
;
; The setup of the clock, the pins, the SPI and the display and fill_rect are those of lines_ram.asm.
.target pico
.arch thumb
.imagebase 0x20000000

RESET_DONE_OFFSET equ 0x08
FUNCSEL_SPI       equ 1
FUNCSEL_SIO       equ 5
SIO_GPIO_IN       equ 0x04
SIO_GPIO_OUT_SET  equ 0x14
SIO_GPIO_OUT_CLR  equ 0x18
SIO_GPIO_OUT_XOR  equ 0x1c
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
KEYS              equ (1 << 6) | (1 << 7)
PAD_IN_PULLUP     equ 0x5a                ; IE, DRIVE 4 mA, PUE, SCHMITT
COL_OFFSET        equ 52                  ; where the visible picture lies in the memory of the controller
ROW_OFFSET        equ 40

; the variables of the text (r2 points to them): where the next character goes, its size and colours, and what
; draw_char and draw_text are at
V_X     equ 0
V_Y     equ 4
V_SCALE equ 8
V_FG    equ 12
V_BG    equ 16
V_ROWS  equ 20          ; the 7 rows of the character
V_ROW   equ 24
V_COL   equ 28
V_STR   equ 32          ; the next character of the string
V_DIG   equ 36          ; the counter: 5 ASCII digits and a 0

BLACK   equ 0x0000
WHITE   equ 0xffff
CYAN    equ 0x07ff
GREEN   equ 0x07e0
YELLOW  equ 0xffe0
GREY    equ 0x8410

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

    ; the pins: RST, DC, BL, CS, PWR_ON and the LED as outputs, SCLK and MOSI to SPI0, the keys as inputs
    ldr  r0, io_bank0
    movs r1, #FUNCSEL_SIO
    str  r1, [r0, #0x04]                ; GPIO0_CTRL: RST
    str  r1, [r0, #0x0c]                ; GPIO1_CTRL: DC
    str  r1, [r0, #0x24]                ; GPIO4_CTRL: BL
    str  r1, [r0, #0x2c]                ; GPIO5_CTRL: CS
    str  r1, [r0, #0x34]                ; GPIO6_CTRL: key 1
    str  r1, [r0, #0x3c]                ; GPIO7_CTRL: key 2
    movs r2, #0xb4
    str  r1, [r0, r2]                   ; GPIO22_CTRL: PWR_ON
    movs r2, #0xcc
    str  r1, [r0, r2]                   ; GPIO25_CTRL: the LED
    movs r1, #FUNCSEL_SPI
    str  r1, [r0, #0x14]                ; GPIO2_CTRL: SCLK
    str  r1, [r0, #0x1c]                ; GPIO3_CTRL: MOSI
    ldr  r0, pads_bank0
    movs r1, #PAD_IN_PULLUP
    str  r1, [r0, #0x1c]                ; GPIO6: input with pull-up
    str  r1, [r0, #0x20]                ; GPIO7

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

    ; black: the whole picture, then the backlight on
    movs r6, #BLACK
    movs r0, #0
    mov  r8, r0
    mov  r9, r0
    movs r0, #134
    mov  r10, r0
    movs r0, #239
    mov  r11, r0
    bl   fill_rect
    movs r1, #PIN_BL
    str  r1, [r5, #SIO_GPIO_OUT_SET]

    ; the text: r2 points to the variables from here on
    ldr  r2, vars
    movs r0, #BLACK
    str  r0, [r2, #V_BG]
    movs r0, #2
    str  r0, [r2, #V_SCALE]
    ldr  r0, lit_cyan
    str  r0, [r2, #V_FG]
    movs r0, #20
    movs r1, #12
    ldr  r3, text_title
    bl   text_at                        ; ASMONITE
    ldr  r0, lit_white
    str  r0, [r2, #V_FG]
    movs r0, #20
    movs r1, #36
    ldr  r3, text_board
    bl   text_at                        ; T-PICOC3
    ldr  r0, lit_green
    str  r0, [r2, #V_FG]
    movs r0, #38
    movs r1, #84
    ldr  r3, text_count
    bl   text_at                        ; COUNT
    movs r0, #1
    str  r0, [r2, #V_SCALE]
    ldr  r0, lit_grey
    str  r0, [r2, #V_FG]
    movs r0, #43
    movs r1, #200
    ldr  r3, text_key
    bl   text_at                        ; KEY: END

    ; the counter: 00000, then up until a key is pressed
    mov  r3, r2
    adds r3, #V_DIG
    movs r0, #'0'
    movs r1, #0
digits_zero:
    strb r0, [r3, r1]
    adds r1, #1
    cmp  r1, #5
    bne  digits_zero
    movs r0, #0
    strb r0, [r3, r1]                   ; the end of the string
    movs r0, #4
    str  r0, [r2, #V_SCALE]
    ldr  r0, lit_yellow
    str  r0, [r2, #V_FG]
count_loop:
    movs r0, #8
    movs r1, #108
    mov  r3, r2
    adds r3, #V_DIG
    bl   text_at                        ; the 5 digits, 4 times as large
    ldr  r1, led
    str  r1, [r5, #SIO_GPIO_OUT_XOR]    ; the LED: on, off, on ...
    ; a key pressed (its pin low)? then the end
    ldr  r0, [r5, #SIO_GPIO_IN]
    movs r1, #KEYS
    ands r0, r1
    cmp  r0, r1
    bne  the_end
    ; one up, from the last digit on
    mov  r3, r2
    adds r3, #V_DIG
    movs r1, #4
count_up:
    ldrb r0, [r3, r1]
    adds r0, #1
    cmp  r0, #'9' + 1
    bne  count_store
    movs r0, #'0'                       ; 9 + 1: a 0 here, and the digit before goes up
    strb r0, [r3, r1]
    subs r1, #1
    bpl  count_up
    b    count_loop                     ; 99999 + 1 = 00000
count_store:
    strb r0, [r3, r1]
    b    count_loop

the_end:
    ; until the last byte is out, the LED off, and back: r0 = the last digit of the count
    movs r7, #0x10
last_byte:
    ldr  r3, [r4, #SSPSR]
    tst  r3, r7
    bne  last_byte
    ldr  r1, led
    str  r1, [r5, #SIO_GPIO_OUT_CLR]
    mov  r3, r2
    adds r3, #V_DIG
    ldrb r0, [r3, #4]                   ; ldrb takes offsets up to 31 only
    subs r0, #'0'
    pop  {r4, r5, r6, r7, pc}

; text_at: the string at r3, its first character at (r0, r1), in the size and colours of the variables (r2)
text_at:
    str  r0, [r2, #V_X]
    str  r1, [r2, #V_Y]
    str  r3, [r2, #V_STR]
    ; on in draw_text

; draw_text: the characters of the string at V_STR, until a 0 (uses r0, r1, r3, r6, r7)
draw_text:
    push {lr}
draw_text_next:
    ldr  r0, [r2, #V_STR]
    ldrb r0, [r0]
    cmp  r0, #0
    beq  draw_text_done
    bl   draw_char
    ldr  r0, [r2, #V_STR]
    adds r0, #1
    str  r0, [r2, #V_STR]
    b    draw_text_next
draw_text_done:
    pop  {pc}

; draw_char: the character r0 at (V_X, V_Y), its 5 x 7 dots as squares of V_SCALE pixels; then V_X goes on by
; 6 dots (uses r0, r1, r3, r6, r7)
draw_char:
    push {lr}
    subs r0, #32                        ; the font starts with the space
    lsls r0, r0, #3                     ; 8 bytes a character
    ldr  r1, font_addr
    adds r0, r0, r1
    str  r0, [r2, #V_ROWS]
    movs r0, #0
    str  r0, [r2, #V_ROW]
draw_char_row:
    movs r0, #0
    str  r0, [r2, #V_COL]
draw_char_dot:
    ; the dot: bit (4 - col) of the row
    ldr  r1, [r2, #V_ROWS]
    ldr  r0, [r2, #V_ROW]
    ldrb r1, [r1, r0]
    ldr  r0, [r2, #V_COL]
    movs r3, #4
    subs r3, r3, r0
    lsrs r1, r1, r3
    movs r3, #1
    ldr  r6, [r2, #V_BG]
    tst  r1, r3
    beq  draw_char_colour
    ldr  r6, [r2, #V_FG]
draw_char_colour:
    ; the square: x = V_X + col * scale, y = V_Y + row * scale, scale pixels each way
    ldr  r1, [r2, #V_SCALE]
    ldr  r0, [r2, #V_COL]
    muls r0, r1, r0
    ldr  r3, [r2, #V_X]
    adds r0, r0, r3
    mov  r8, r0
    adds r0, r0, r1
    subs r0, #1
    mov  r10, r0
    ldr  r0, [r2, #V_ROW]
    muls r0, r1, r0
    ldr  r3, [r2, #V_Y]
    adds r0, r0, r3
    mov  r9, r0
    adds r0, r0, r1
    subs r0, #1
    mov  r11, r0
    bl   fill_rect
    ldr  r0, [r2, #V_COL]
    adds r0, #1
    str  r0, [r2, #V_COL]
    cmp  r0, #5
    bne  draw_char_dot
    ldr  r0, [r2, #V_ROW]
    adds r0, #1
    str  r0, [r2, #V_ROW]
    cmp  r0, #7
    bne  draw_char_row
    ; the next character 6 dots further right
    ldr  r1, [r2, #V_SCALE]
    movs r0, #6
    muls r0, r1, r0
    ldr  r1, [r2, #V_X]
    adds r0, r0, r1
    str  r0, [r2, #V_X]
    pop  {pc}

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
pads_bank0:    dd 0x4001c000
sio:           dd 0xd0000000
spi0:          dd 0x4003c000
out_pins:      dd PIN_RST | PIN_DC | PIN_BL | PIN_CS | (1 << 22) | (1 << 25)
high_pins:     dd PIN_RST | PIN_DC | PIN_CS | (1 << 22)
led:           dd 1 << 25
lit_white:         dd WHITE
lit_cyan:          dd CYAN
lit_green:         dd GREEN
lit_yellow:        dd YELLOW
lit_grey:          dd GREY
delay_short:   dd 200000
delay_long:    dd 2000000
vars:          dd 0x20010000                ; the variables of the text, in the RAM behind the program
font_addr:     dd font
text_title:    dd title
text_board:    dd board
text_count:    dd count_label
text_key:      dd key_label

title:         db "ASMONITE", 0
board:         db "T-PICOC3", 0
count_label:   db "COUNT", 0
key_label:     db "KEY: END", 0

; the font: 5 x 7 dots, one byte a row (bit 4 the left dot), 8 bytes a character, from the space (32) to Z (90)
align 4
font:
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 32 space
    db 0x04, 0x04, 0x04, 0x04, 0x04, 0x00, 0x04, 0x00   ; 33 !
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 34 "
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 35 #
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 36 $
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 37 %
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 38 &
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 39 quote
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 40 (
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 41 )
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 42 *
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 43 +
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 44 ,
    db 0x00, 0x00, 0x00, 0x1f, 0x00, 0x00, 0x00, 0x00   ; 45 -
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x0c, 0x00   ; 46 .
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 47 /
    db 0x0e, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0e, 0x00   ; 48 0
    db 0x04, 0x0c, 0x04, 0x04, 0x04, 0x04, 0x0e, 0x00   ; 49 1
    db 0x0e, 0x11, 0x01, 0x02, 0x04, 0x08, 0x1f, 0x00   ; 50 2
    db 0x1f, 0x02, 0x04, 0x02, 0x01, 0x11, 0x0e, 0x00   ; 51 3
    db 0x02, 0x06, 0x0a, 0x12, 0x1f, 0x02, 0x02, 0x00   ; 52 4
    db 0x1f, 0x10, 0x1e, 0x01, 0x01, 0x11, 0x0e, 0x00   ; 53 5
    db 0x06, 0x08, 0x10, 0x1e, 0x11, 0x11, 0x0e, 0x00   ; 54 6
    db 0x1f, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08, 0x00   ; 55 7
    db 0x0e, 0x11, 0x11, 0x0e, 0x11, 0x11, 0x0e, 0x00   ; 56 8
    db 0x0e, 0x11, 0x11, 0x0f, 0x01, 0x02, 0x0c, 0x00   ; 57 9
    db 0x00, 0x0c, 0x0c, 0x00, 0x0c, 0x0c, 0x00, 0x00   ; 58 :
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 59 ;
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 60 <
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 61 =
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 62 >
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 63 ?
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 64 @
    db 0x0e, 0x11, 0x11, 0x1f, 0x11, 0x11, 0x11, 0x00   ; 65 A
    db 0x1e, 0x11, 0x11, 0x1e, 0x11, 0x11, 0x1e, 0x00   ; 66 B
    db 0x0e, 0x11, 0x10, 0x10, 0x10, 0x11, 0x0e, 0x00   ; 67 C
    db 0x1e, 0x11, 0x11, 0x11, 0x11, 0x11, 0x1e, 0x00   ; 68 D
    db 0x1f, 0x10, 0x10, 0x1e, 0x10, 0x10, 0x1f, 0x00   ; 69 E
    db 0x1f, 0x10, 0x10, 0x1e, 0x10, 0x10, 0x10, 0x00   ; 70 F
    db 0x0e, 0x11, 0x10, 0x17, 0x11, 0x11, 0x0f, 0x00   ; 71 G
    db 0x11, 0x11, 0x11, 0x1f, 0x11, 0x11, 0x11, 0x00   ; 72 H
    db 0x0e, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0e, 0x00   ; 73 I
    db 0x07, 0x02, 0x02, 0x02, 0x02, 0x12, 0x0c, 0x00   ; 74 J
    db 0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11, 0x00   ; 75 K
    db 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1f, 0x00   ; 76 L
    db 0x11, 0x1b, 0x15, 0x15, 0x11, 0x11, 0x11, 0x00   ; 77 M
    db 0x11, 0x11, 0x19, 0x15, 0x13, 0x11, 0x11, 0x00   ; 78 N
    db 0x0e, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0e, 0x00   ; 79 O
    db 0x1e, 0x11, 0x11, 0x1e, 0x10, 0x10, 0x10, 0x00   ; 80 P
    db 0x0e, 0x11, 0x11, 0x11, 0x15, 0x12, 0x0d, 0x00   ; 81 Q
    db 0x1e, 0x11, 0x11, 0x1e, 0x14, 0x12, 0x11, 0x00   ; 82 R
    db 0x0f, 0x10, 0x10, 0x0e, 0x01, 0x01, 0x1e, 0x00   ; 83 S
    db 0x1f, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x00   ; 84 T
    db 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0e, 0x00   ; 85 U
    db 0x11, 0x11, 0x11, 0x11, 0x11, 0x0a, 0x04, 0x00   ; 86 V
    db 0x11, 0x11, 0x11, 0x15, 0x15, 0x15, 0x0a, 0x00   ; 87 W
    db 0x11, 0x11, 0x0a, 0x04, 0x0a, 0x11, 0x11, 0x00   ; 88 X
    db 0x11, 0x11, 0x0a, 0x04, 0x04, 0x04, 0x04, 0x00   ; 89 Y
    db 0x1f, 0x01, 0x02, 0x04, 0x08, 0x10, 0x1f, 0x00   ; 90 Z
