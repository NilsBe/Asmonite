; The clock of the core after a program, for the console of the ESP32 (boards/esp32/console.asm includes it; not a
; program of its own). A program may change the clock (abelle/lib/esp32/cpuclock.abel): cpu_clock 80, 160 or 240 MHz
; from the PLL, 40, 20, 10, 8, 5, 4, 2 or 1 MHz from the crystal; cpu_clock_khz also below 1 MHz. The console keeps
; the clock a program leaves (the user, 2026-11-24: a program that changes the clock means it to stay; setclock):
; from 1 MHz up the library has set the divider of UART0 and the cycles per microsecond for it, so the terminal,
; millis() and the WiFi go on. Only below 1 MHz (PRE_DIV_CNT 40 or more on the crystal, or RC_FAST) the console could
; not talk (115200 baud cannot be made there): clock_back takes the crystal undivided again, 40 MHz. UART0 is right
; then at once: below 1 MHz the library leaves its divider at the one of 40 MHz.

  align 4
lit_ck_tapp:   dd 0x3FFE40F0          ; g_ticks_per_us_app: the cycles of core 1 in a microsecond (the ROM's)
lit_ck_clksel: dd 0x18000000          ; RTC_CNTL_CLK_CONF: SOC_CLK_SEL bits 28..27
lit_ck_settle: dd 4000                ; the turns of the wait for the slow clock: at least 200 us at 40 MHz

; after a program: from below 1 MHz to the crystal at 40 MHz; any other clock stays
  align 4
clock_back:
  entry a1, 32
  l32r  a3, lit_rtc
  l32i  a2, a3, 0x70
  extui a4, a2, 27, 2                ; SOC_CLK_SEL
  l32r  a5, lit_sysclk
  beqi  a4, 2, ckb_low               ; RC_FAST
  bnez  a4, ckb_done                 ; the PLL
  l32i  a6, a5, 0
  extui a6, a6, 0, 10
  movi  a7, 40
  bltu  a6, a7, ckb_done             ; the crystal at 1 MHz or more
ckb_low:
  movi  a6, 0
  s32i  a6, a5, 0                    ; PRE_DIV_CNT 0
  l32r  a6, lit_ck_clksel
  or    a2, a2, a6
  xor   a2, a2, a6
  s32i  a2, a3, 0x70                 ; SOC_CLK_SEL 0: the crystal
  memw
  l32r  a6, lit_ck_settle            ; the switch takes a few cycles of the slow clock
ckb_settle:
  addi  a6, a6, -1
  bnez  a6, ckb_settle
  movi  a6, 40
  l32r  a3, lit_ticks                ; the cycles in a microsecond for the ROM of both cores (and millis)
  s32i  a6, a3, 0
  l32r  a3, lit_ck_tapp
  s32i  a6, a3, 0
ckb_done:
  retw
