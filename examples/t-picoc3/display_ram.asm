; LilyGO T-PicoC3 (RP2040 + ESP32-C3), the RP2040 side: fills the 1.14" display (ST7789, 135 x 240) with one
; colour, then turns the red LED on and waits.
;
; Plug the USB-C plug in so that the RP2040 is connected (its LED is blue), hold BOOT, press RUN, let go of
; BOOT: the drive RPI-RP2 appears. Project > UF2 makes display_ram.uf2; copy it to the drive. The boot ROM
; starts the program in the RAM at 0x20000000; the flash is not touched (RUN starts its program again).
;
; The pins of the RP2040 (github.com/Xinyuan-LilyGO/T-PicoC3): display SCLK 2, MOSI 3 (SPI0), CS 5, DC 1,
; RST 0, backlight 4; PWR_ON 22; red LED 25.
;
; The registers (RP2040 datasheet): RESETS (IO_BANK0, PADS_BANK0, SPI0 out of reset), CLOCKS CLK_PERI_CTRL (the
; clock of the SPI on, from clk_sys), IO_BANK0 GPIOn_CTRL (function 1 SPI, 5 SIO), SIO (outputs), SPI0 (an
; ARM PL022: SSPCR0 8 bits mode 0, SSPCPSR the divider, SSPCR1 on, SSPDR the data, SSPSR TNF bit 1, BSY bit 4).
; The ST7789: SLPOUT 0x11, COLMOD 0x3a (16 bits a pixel), MADCTL 0x36, INVON 0x21 (this panel needs it for
; true colours), NORON 0x13, DISPON 0x29, CASET 0x2a and RASET 0x2b (the window: here the whole memory of the
; controller, 240 x 320, so the visible part is filled whatever its offset is), RAMWR 0x2c (the pixels).
;
; The Cortex-M0+ knows Thumb-1 only: 32-bit constants come from words behind the code ("ldr r0, name"), and
; str takes offsets up to 124. The functions command, data and wait call nothing, so lr stays as it is.
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
COLOUR_HI         equ 0xfd            ; orange: 0xfd20 (5 bits red, 6 green, 5 blue)
COLOUR_LO         equ 0x20

_start:
    ldr  r0, sram_end
    mov  sp, r0

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

    ; the pins: RST, DC, BL, CS, PWR_ON and the LED as outputs of the SIO, SCLK and MOSI to SPI0
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
    ldr  r1, high_pins                  ; RST, DC, CS high, the power on; backlight and LED stay off
    str  r1, [r5, #SIO_GPIO_OUT_SET]

    ; SPI0: 8 bits, mode 0, clk_peri / 4
    ldr  r4, spi0
    movs r1, #7
    str  r1, [r4, #SSPCR0]
    movs r1, #4
    str  r1, [r4, #SSPCPSR]
    movs r1, #2
    str  r1, [r4, #SSPCR1]

    ; a reset of the display: RST low for a moment, then the controller needs 120 ms
    ldr  r0, delay_short
    bl   wait
    movs r1, #PIN_RST
    str  r1, [r5, #SIO_GPIO_OUT_CLR]
    ldr  r0, delay_short
    bl   wait
    str  r1, [r5, #SIO_GPIO_OUT_SET]
    ldr  r0, delay_long
    bl   wait
    movs r1, #PIN_CS                    ; CS low from here on: the display listens
    str  r1, [r5, #SIO_GPIO_OUT_CLR]

    movs r0, #0x11                      ; SLPOUT, then 120 ms
    bl   command
    ldr  r0, delay_long
    bl   wait
    movs r0, #0x3a                      ; COLMOD: 16 bits a pixel
    bl   command
    movs r0, #0x55
    bl   data
    movs r0, #0x36                      ; MADCTL: the normal direction
    bl   command
    movs r0, #0
    bl   data
    movs r0, #0x21                      ; INVON
    bl   command
    movs r0, #0x13                      ; NORON
    bl   command
    movs r0, #0x29                      ; DISPON
    bl   command

    movs r0, #0x2a                      ; CASET: columns 0 .. 239
    bl   command
    movs r0, #0
    bl   data
    movs r0, #0
    bl   data
    movs r0, #0
    bl   data
    movs r0, #239
    bl   data
    movs r0, #0x2b                      ; RASET: rows 0 .. 319 (0x13f)
    bl   command
    movs r0, #0
    bl   data
    movs r0, #0
    bl   data
    movs r0, #1
    bl   data
    movs r0, #0x3f
    bl   data

    movs r0, #0x2c                      ; RAMWR: 240 x 320 pixels, two bytes each
    bl   command
    ldr  r6, pixels
fill:
    movs r0, #COLOUR_HI
    bl   data
    movs r0, #COLOUR_LO
    bl   data
    subs r6, r6, #1
    bne  fill

    ; until the last byte is out, then the backlight and the LED on
    movs r2, #0x10
last_byte:
    ldr  r3, [r4, #SSPSR]
    tst  r3, r2
    bne  last_byte
    movs r1, #PIN_BL
    str  r1, [r5, #SIO_GPIO_OUT_SET]
    ldr  r1, led
    str  r1, [r5, #SIO_GPIO_OUT_SET]
done:
    b    done

; command: sends the byte in r0 with DC low (r4 = SPI0, r5 = SIO; uses r2, r3)
command:
    movs r2, #0x10                      ; BSY: DC changes only when the SPI is idle
command_idle:
    ldr  r3, [r4, #SSPSR]
    tst  r3, r2
    bne  command_idle
    movs r3, #PIN_DC
    str  r3, [r5, #SIO_GPIO_OUT_CLR]
    str  r0, [r4, #SSPDR]
command_sent:
    ldr  r3, [r4, #SSPSR]
    tst  r3, r2
    bne  command_sent
    movs r3, #PIN_DC
    str  r3, [r5, #SIO_GPIO_OUT_SET]
    bx   lr

; data: sends the byte in r0 with DC high, as soon as the FIFO has room (uses r2, r3)
data:
    movs r2, #2                         ; TNF: the transmit FIFO is not full
data_room:
    ldr  r3, [r4, #SSPSR]
    tst  r3, r2
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
sram_end:      dd 0x20042000
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
pixels:        dd 240 * 320
delay_short:   dd 200000
delay_long:    dd 2000000
