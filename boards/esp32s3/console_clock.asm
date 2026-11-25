; The clock of the core after a program, for the console of the ESP32-S3 (boards/esp32s3/console.asm includes it; not
; a program of its own). A program may change the clock (abelle/lib/esp32s3/cpuclock.abel): cpu_clock 80, 160 or 240
; MHz from the PLL, 40, 20 or 10 MHz from the crystal. The console keeps the clock a program leaves (the user,
; 2026-11-24: a program that changes the clock means it to stay; setclock): the library has told the ROM the cycles in
; a microsecond (ets_update_cpu_frequency), so millis() and the waits of the console go on right. Below 10 MHz the USB
; port of the chip does not work right (from the crystal its bus, the APB, runs at the clock of the core; seen
; 2026-11-25: bytes twice at 8 .. 4 MHz, the port dead at 2 MHz), so the library makes no such clock; a program that
; sets one itself (PRE_DIV_CNT 4 or more, or a source other than the crystal and the PLL) and comes back to the
; console: clock_back takes the crystal undivided again, 40 MHz.

  align 4
lit_ck_srcmask: dd 0xFFF              ; SYSTEM_SYSCLK_CONF: SOC_CLK_SEL bits 11..10, PRE_DIV_CNT bits 9..0

; after a program: from below 10 MHz to the crystal at 40 MHz; any other clock stays
  align 4
clock_back:
  entry a1, 32
  l32r  a3, lit_sysclk
  l32i  a2, a3, 0
  extui a4, a2, 10, 2                ; SOC_CLK_SEL
  beqi  a4, 1, ckb_done              ; the PLL
  bnez  a4, ckb_low                  ; RC_FAST (not from the library)
  extui a5, a2, 0, 10
  movi  a6, 4
  bltu  a5, a6, ckb_done             ; the crystal at 10 MHz or more
ckb_low:
  l32r  a6, lit_ck_srcmask
  or    a2, a2, a6
  xor   a2, a2, a6
  s32i  a2, a3, 0                    ; the crystal undivided: 40 MHz
  memw
  movi  a10, 40
  l32r  a8, lit_setfreq              ; ets_update_cpu_frequency: the cycles in a microsecond (both cores, millis)
  callx8 a8
ckb_done:
  retw
