; The clock of the core after a program, for the console of the ESP32-C3 (boards/esp32c3/console.asm includes it; not
; a program of its own). A program may change the clock (abelle/lib/esp32c3/cpuclock.abel): cpu_clock 80 or 160 MHz
; from the PLL, 40, 20 or 10 MHz from the crystal. The console keeps the clock a program leaves (as on the other
; boards): the library has told the ROM the cycles in a microsecond (ets_update_cpu_frequency) and the APB its
; frequency (RTC_APB_FREQ_REG), timer 0 (millis) and the tick of the WiFi count the crystal. Below 10 MHz the USB port
; of the chip, the console, does not work right (from the crystal its bus, the APB, runs at the clock of the core; seen
; on the ESP32-S3), so the library makes no such clock; a program that sets one itself (PRE_DIV_CNT 4 or more, or
; RC_FAST) and comes back to the console: clock_back takes the crystal undivided again, 40 MHz.

; after a program: from below 10 MHz to the crystal at 40 MHz; any other clock stays
clock_back:
    li   t0, SYSTEM
    lw   t1, 0x58(t0)                   ; SYSCLK_CONF: SOC_CLK_SEL bits 11..10, PRE_DIV_CNT bits 9..0
    srli t2, t1, 10
    andi t2, t2, 3
    li   t3, 1
    beq  t2, t3, ckb_done               ; the PLL
    bnez t2, ckb_low                    ; RC_FAST (not from the library)
    andi t2, t1, 0x3FF
    li   t3, 4
    bltu t2, t3, ckb_done               ; the crystal at 10 MHz or more
ckb_low:
    li   t2, 0xFFF
    or   t1, t1, t2
    xor  t1, t1, t2
    sw   t1, 0x58(t0)                   ; the crystal undivided: 40 MHz
    li   t0, RTC_CNTL                   ; the APB: 40 MHz (Hz >> 12 in both halves)
    li   t1, 0x26252625
    sw   t1, 0xBC(t0)
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   a0, 40
    li   t0, ROM_CPU_SET                ; ets_update_cpu_frequency: the cycles in a microsecond
    jalr ra, 0(t0)
    lw   ra, 12(sp)
    addi sp, sp, 16
ckb_done:
    ret
