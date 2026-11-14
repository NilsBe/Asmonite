; ESP32 (the original, Xtensa LX6): the clock of the core. The program runs it from the crystal (40 MHz) and from
; the PLL at 80, 160 and 240 MHz, one after the other, three seconds each, and writes over UART0 how fast an empty
; loop goes at each: "CPU 240 MHz: 6000 loops per ms, uptime 12345 ms" (under the debugger in the tab Serial, else in
; a terminal on the COM port, 115200 baud).
;
;   1. plug in the board (its USB port goes to a USB serial chip: CP2102, CH340 ...)
;   2. press F9: the program goes into the RAM and runs (over the console, or under the debug monitor of Asmonite);
;      Project > Write to Flash and Run writes it into the flash first, then the board runs it at every start
;
; The boot ROM leaves the core at the crystal; the bootloader of ESP-IDF switches it to the PLL. This program does
; what ESP-IDF does (components/esp_hw_support/port/esp32/rtc_clk.c, the values for a crystal of 40 MHz):
;   - the PLL on: RTC_CNTL_OPTIONS0 bits 18, 10, 8, 6 clear (BIAS_I2C, BBPLL, BBPLL_I2C, BB_I2C: no longer
;     powered down); then its registers over the I2C bus inside the chip, with the function of the ROM
;     rom_i2c_writeReg (0x400041A4; block 0x66, host 4; regi2c_bbpll.h): 0 = 0x18, 1 = 0x20, 4 = 0x9A, 10 = 0, 12 = 0
;   - the PLL at 320 MHz (for 80 and 160 MHz): the voltage of the core DIG_DBIAS = 4 (1.10 V; RTC_CNTL_REG 0x7C, bits
;     13..11), 11 = 0x43, 9 = 0x84, 2 = 0, 3 = 32, 5 = 0xC6; at 480 MHz (for 240 MHz) first DIG_DBIAS = 7 less the
;     eFuse VOL_LEVEL_HP_INV (1.25 V; bits 23..22 of eFuse word 5), 11 = 0xC3, 9 = 0x74, 2 = 0, 3 = 28, 5 = 0xC6;
;     then 200 microseconds for the PLL to settle
;   - DPORT_CPU_PER_CONF (0x3FF0003C) CPUPERIOD_SEL: 0 80, 1 160, 2 240 MHz; then RTC_CNTL_CLK_CONF (0x70) bits 28..27
;     SOC_CLK_SEL = 1: the core runs from the PLL, the clock of the peripherals (APB) is 80 MHz
; Back to the crystal: SOC_CLK_SEL = 0, the PLL powered down, DIG_DBIAS = 4; the APB is 40 MHz again.
; A switch of SOC_CLK_SEL is done in the RTC part, at the cycles of its slow clock (about 150 kHz): the program waits
; for it before it goes on (ESP-IDF: rtc_clk_wait_for_slow_cycle). Without the wait the PLL went off before the core
; was at the crystal, now and then, and the chip hung.
; Between 80 and 160 MHz the PLL stays at 320 MHz and only CPUPERIOD_SEL changes; to another frequency of the PLL the
; program goes over the crystal and gives the PLL a millisecond off, on and after its setup.
; At every change of the APB the divider of UART0 (UART_CLKDIV 0x3FF40014: the APB clock / 115200 in sixteenths, the
; whole part in bits 19..0, the sixteenths in bits 23..20) and of timer 0 of timer group 0 (T0CONFIG: the APB clock
; in MHz in bits 28..13, so it counts microseconds) follow: else the baud rate is wrong (also for the debug monitor)
; and the time too.
;
; The functions are windowed (entry, retw; call8 passes a10 .. a13, the result comes back in a10), as the functions
; of the ROM. The texts are in the DRAM (.data): the IRAM of the program takes words only.
;
; A program that the boot ROM starts from the flash has to switch the watchdogs off itself (see blink_flash.asm).
.target esp32
.arch xtensa
.imagebase 0x40080000

lit_uart0:    dd 0x3FF40000          ; UART0
lit_uart_ahb: dd 0x60000000          ; its FIFO on the AHB (see hello_uart_ram.asm)
lit_timg0:    dd 0x3FF5F000          ; timer group 0
lit_timg1:    dd 0x3FF60000          ; timer group 1
lit_rtc:      dd 0x3FF48000          ; RTC_CNTL
lit_apb:      dd 0x3FF66000          ; APB_CTRL
lit_dport:    dd 0x3FF00000          ; DPORT
lit_efuse:    dd 0x3FF5A000          ; eFuse block 0
lit_wdt_key:  dd 0x50D83AA1          ; unlocks the registers of a watchdog
lit_i2c:      dd 0x400041A4          ; rom_i2c_writeReg(block, host, reg, data)
lit_baud:     dd 115200
lit_16m:      dd 16000000            ; 1 MHz in sixteenths of a baud
lit_t0_up:    dd 0x40000000          ; T0CONFIG: counts up
lit_t0_on:    dd 0xC0000000          ; T0CONFIG: on, counts up
lit_pll_on:   dd 0x00040540          ; RTC_CNTL_OPTIONS0: BIAS_I2C, BBPLL, BBPLL_I2C, BB_I2C powered down
lit_pll_off:  dd 0x00000540          ; ... the PLL and its bus down again
lit_clksel:   dd 0x18000000          ; SOC_CLK_SEL, bits 28..27
lit_dbias:    dd 0x00003800          ; DIG_DBIAS_WAK, bits 13..11
lit_loops:    dd 20000               ; the turns of the loop that is timed
lit_loops_ms: dd 20000000            ; ... times 1000: / microseconds = loops per ms
lit_3s:       dd 3000000             ; three seconds in microseconds
lit_settle:   dd 4000                ; the turns of the loop of settle
lit_digits:   dd digits
lit_s_start:  dd s_start
lit_s_cpu:    dd s_cpu
lit_s_mhz:    dd s_mhz
lit_s_up:     dd s_up
lit_s_end:    dd s_end

_start:
  call8 watchdogs_off
  movi  a10, 40
  call8 set_apb                      ; the timer on, UART0 at 40 MHz (as the boot ROM set it)
  l32r  a10, lit_s_start
  call8 print
again:
  call8 to_xtal
  movi  a10, 40
  call8 report
  movi  a10, 80
  call8 to_pll
  movi  a10, 80
  call8 report
  movi  a10, 160
  call8 to_pll
  movi  a10, 160
  call8 report
  movi  a10, 240
  call8 to_pll
  movi  a10, 240
  call8 report
  j     again

; a line for the clock a2 (MHz), then three seconds
  align 4
report:
  entry a1, 32
  l32r  a10, lit_s_cpu
  call8 print
  mov   a10, a2
  call8 print_dec
  l32r  a10, lit_s_mhz
  call8 print
  call8 loops_per_ms
  call8 print_dec
  l32r  a10, lit_s_up
  call8 print
  call8 micros
  movi  a3, 1000
  quou  a10, a10, a3
  call8 print_dec
  l32r  a10, lit_s_end
  call8 print
  l32r  a10, lit_3s
  call8 wait_us
  retw

; the core and the APB at the crystal (40 MHz), the PLL off
  align 4
to_xtal:
  entry a1, 32
  call8 uart_drain
  l32r  a3, lit_apb
  movi  a4, 0
  s32i  a4, a3, 0                    ; APB_CTRL_SYSCLK_CONF: PRE_DIV_CNT 0, the crystal undivided
  l32r  a3, lit_rtc
  l32i  a4, a3, 0x70
  l32r  a5, lit_clksel
  or    a4, a4, a5
  xor   a4, a4, a5                   ; SOC_CLK_SEL 0: the crystal
  s32i  a4, a3, 0x70
  memw
  call8 settle                       ; the switch takes a few cycles of the slow clock: then the PLL may go off
  movi  a10, 40
  call8 set_apb
  l32i  a4, a3, 0
  l32r  a5, lit_pll_off
  or    a4, a4, a5                   ; the PLL powered down
  s32i  a4, a3, 0
  movi  a10, 4
  call8 set_dbias                    ; 1.10 V
  retw

; the core from the PLL at a2 MHz (80, 160, 240), the APB at 80 MHz
  align 4
to_pll:
  entry a1, 32
  l32r  a3, lit_rtc
  ; from 80 to 160 MHz or back the PLL stays at 320 MHz: only CPUPERIOD_SEL changes (switching the PLL off and on
  ; again so soon hung the chip now and then)
  l32i  a4, a3, 0x70
  extui a4, a4, 27, 2
  movi  a5, 1
  bne   a4, a5, pll_start            ; not at the PLL now
  l32r  a5, lit_dport
  l32i  a4, a5, 0x3C
  extui a4, a4, 0, 2
  movi  a5, 2
  beq   a4, a5, pll_start            ; at 240 MHz now: the PLL at 480
  movi  a5, 240
  beq   a2, a5, pll_start            ; to 240 MHz: the PLL to 480
  call8 uart_drain
  movi  a4, 80
  quou  a4, a2, a4
  addi  a4, a4, -1
  l32r  a5, lit_dport
  s32i  a4, a5, 0x3C                 ; CPUPERIOD_SEL
  memw
  retw
pll_start:
  call8 to_xtal                      ; from the crystal, as ESP-IDF does
  movi  a10, 1000
  call8 wait_us                      ; the PLL a while off
  l32i  a4, a3, 0
  l32r  a5, lit_pll_on
  or    a4, a4, a5
  xor   a4, a4, a5                   ; the PLL and its bus on
  s32i  a4, a3, 0
  memw
  movi  a10, 1000
  call8 wait_us
  movi  a10, 0
  movi  a11, 0x18
  call8 i2c_write                    ; IR_CAL_DELAY
  movi  a10, 1
  movi  a11, 0x20
  call8 i2c_write                    ; IR_CAL_EXT_CAP
  movi  a10, 4
  movi  a11, 0x9A
  call8 i2c_write                    ; OC_ENB_FCAL
  movi  a10, 10
  movi  a11, 0
  call8 i2c_write                    ; OC_ENB_VCON
  movi  a10, 12
  movi  a11, 0
  call8 i2c_write                    ; BBADC_CAL_7_0
  movi  a4, 240
  beq   a2, a4, pll480
  ; the PLL at 320 MHz (the voltage is 1.10 V already)
  movi  a10, 11
  movi  a11, 0x43
  call8 i2c_write                    ; ENDIV5
  movi  a10, 9
  movi  a11, 0x84
  call8 i2c_write                    ; BBADC_DSMP
  movi  a6, 32                       ; OC_DIV_7_0
  j     pll_div
pll480:
  ; the PLL at 480 MHz: 1.25 V first (7 less the eFuse VOL_LEVEL_HP_INV)
  l32r  a4, lit_efuse
  l32i  a4, a4, 0x14
  extui a4, a4, 22, 2
  movi  a10, 7
  sub   a10, a10, a4
  call8 set_dbias
  movi  a10, 10
  call8 wait_us
  movi  a10, 11
  movi  a11, 0xC3
  call8 i2c_write                    ; ENDIV5
  movi  a10, 9
  movi  a11, 0x74
  call8 i2c_write                    ; BBADC_DSMP
  movi  a6, 28                       ; OC_DIV_7_0
pll_div:
  movi  a10, 2
  movi  a11, 0
  call8 i2c_write                    ; OC_LREF 0, OC_DIV_10_8 0, OC_REF_DIV 0
  movi  a10, 3
  mov   a11, a6
  call8 i2c_write                    ; OC_DIV_7_0
  movi  a10, 5
  movi  a11, 0xC6
  call8 i2c_write                    ; OC_BW 3, OC_DCUR 6
  movi  a10, 1000
  call8 wait_us                      ; the PLL settles (ESP-IDF waits 80 microseconds)
  ; CPUPERIOD_SEL: 80 -> 0, 160 -> 1, 240 -> 2
  movi  a4, 80
  quou  a4, a2, a4
  addi  a4, a4, -1
  l32r  a5, lit_dport
  s32i  a4, a5, 0x3C
  memw
  call8 uart_drain
  l32i  a4, a3, 0x70
  l32r  a5, lit_clksel
  or    a4, a4, a5
  xor   a4, a4, a5
  movi  a5, 1
  slli  a5, a5, 27
  or    a4, a4, a5                   ; SOC_CLK_SEL 1: the PLL
  s32i  a4, a3, 0x70
  memw
  call8 settle
  movi  a10, 80
  call8 set_apb
  retw

; waits until a switch of SOC_CLK_SEL has taken place: it is done in the RTC part, at the cycles of its slow clock
; (about 150 kHz, ESP-IDF waits one of them: rtc_clk_wait_for_slow_cycle). The timer cannot measure it (its clock is
; the one that changes): 4000 turns of a loop, at least 200 microseconds at 40 MHz
  align 4
settle:
  entry a1, 32
  l32r  a2, lit_settle
settle_turn:
  addi  a2, a2, -1
  bnez  a2, settle_turn
  retw

; RTC_CNTL_REG DIG_DBIAS_WAK = a2 (the voltage of the core)
  align 4
set_dbias:
  entry a1, 32
  l32r  a3, lit_rtc
  l32i  a4, a3, 0x7C
  l32r  a5, lit_dbias
  or    a4, a4, a5
  xor   a4, a4, a5
  slli  a5, a2, 11
  or    a4, a4, a5
  s32i  a4, a3, 0x7C
  memw
  retw

; a register of the PLL: a2 the register, a3 the value (rom_i2c_writeReg(0x66, 4, a2, a3))
  align 4
i2c_write:
  entry a1, 32
  movi  a10, 0x66
  movi  a11, 4
  mov   a12, a2
  mov   a13, a3
  l32r  a8, lit_i2c
  callx8 a8
  retw

; UART0 and timer 0 for an APB clock of a2 MHz
  align 4
set_apb:
  entry a1, 32
  l32r  a3, lit_16m
  mull  a3, a3, a2                   ; the APB clock in sixteenths of a baud
  l32r  a4, lit_baud
  srli  a5, a4, 1
  add   a3, a3, a5
  quou  a3, a3, a4                   ; / 115200, rounded
  extui a5, a3, 0, 4                 ; the sixteenths
  srli  a3, a3, 4                    ; the whole part
  slli  a5, a5, 20
  or    a3, a3, a5
  l32r  a4, lit_uart0
  s32i  a3, a4, 0x14                 ; UART_CLKDIV
  l32r  a4, lit_timg0
  slli  a5, a2, 13                   ; the divider of the timer: MHz
  l32r  a6, lit_t0_up
  or    a6, a6, a5
  s32i  a6, a4, 0                    ; the timer off: its divider may change
  l32r  a6, lit_t0_on
  or    a6, a6, a5
  s32i  a6, a4, 0                    ; on again, the count goes on
  memw
  retw

; waits until UART0 has sent all its bytes (the last one leaves the shift register: about 90 microseconds)
  align 4
uart_drain:
  entry a1, 32
  l32r  a3, lit_uart0
drain_wait:
  l32i  a4, a3, 0x1C
  extui a4, a4, 16, 8                ; TXFIFO_CNT
  bnez  a4, drain_wait
  movi  a10, 1000
  call8 wait_us
  retw

; the microseconds of timer 0 (its low 32 bits) in a2
  align 4
micros:
  entry a1, 32
  l32r  a3, lit_timg0
  movi  a4, 1
  s32i  a4, a3, 0x0C                 ; T0UPDATE: the count into T0LO
  memw
  l32i  a2, a3, 0x04                 ; T0LO
  retw

; waits a2 microseconds
  align 4
wait_us:
  entry a1, 32
  call8 micros
  mov   a3, a10
wait_more:
  call8 micros
  sub   a4, a10, a3
  bltu  a4, a2, wait_more
  retw

; how many turns of an empty loop the core makes in a millisecond, in a2
  align 4
loops_per_ms:
  entry a1, 32
  call8 micros
  mov   a3, a10
  l32r  a4, lit_loops
loop_turn:
  addi  a4, a4, -1
  bnez  a4, loop_turn
  call8 micros
  sub   a5, a10, a3                  ; microseconds
  l32r  a6, lit_loops_ms
  quou  a2, a6, a5
  retw

; one byte a2 to UART0; waits while its FIFO is (nearly) full
  align 4
put_char:
  entry a1, 32
  l32r  a3, lit_uart0
  movi  a5, 120
fifo_full:
  l32i  a4, a3, 0x1C
  extui a4, a4, 16, 8                ; TXFIFO_CNT
  bgeu  a4, a5, fifo_full
  l32r  a3, lit_uart_ahb
  s32i  a2, a3, 0                    ; UART_FIFO (AHB)
  memw
  retw

; the text at a2 (up to its 0) to UART0
  align 4
print:
  entry a1, 32
print_next:
  l8ui  a10, a2, 0
  beqz  a10, print_done
  call8 put_char
  addi  a2, a2, 1
  j     print_next
print_done:
  retw

; a2 in decimal (unsigned) to UART0
  align 4
print_dec:
  entry a1, 32
  l32r  a3, lit_digits
  addi  a3, a3, 11
  movi  a4, 0
  s8i   a4, a3, 0
  movi  a5, 10
dec_next:
  addi  a3, a3, -1
  remu  a6, a2, a5
  addi  a6, a6, 48                   ; '0'
  s8i   a6, a3, 0
  quou  a2, a2, a5
  bnez  a2, dec_next
  mov   a10, a3
  call8 print
  retw

; the watchdogs off: unlocked, WDTCONFIG0 = 0, locked again (see blink_flash.asm)
  align 4
watchdogs_off:
  entry a1, 32
  l32r  a2, lit_wdt_key
  movi  a3, 0
  l32r  a4, lit_timg0
  s32i  a2, a4, 0x64
  s32i  a3, a4, 0x48
  s32i  a3, a4, 0x64
  l32r  a4, lit_timg1
  s32i  a2, a4, 0x64
  s32i  a3, a4, 0x48
  s32i  a3, a4, 0x64
  l32r  a4, lit_rtc
  s32i  a2, a4, 0xA4
  s32i  a3, a4, 0x8C
  s32i  a3, a4, 0xA4
  memw
  retw

.data
digits:   db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
s_start:  db 'clock: the crystal, then the PLL at 80, 160 and 240 MHz', 13, 10, 0
s_cpu:    db 'CPU ', 0
s_mhz:    db ' MHz: ', 0
s_up:     db ' loops per ms, uptime ', 0
s_end:    db ' ms', 13, 10, 0
