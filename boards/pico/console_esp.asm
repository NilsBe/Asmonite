; The console of Asmonite: the ESP8285 of the clones "Pico W-2023" (an RP2040 with an ESP8285 instead of the
; CYW43439): its part of boards\pico\console.asm (included behind console_wifi.asm; the Pico 2 has none:
; boards\pico2\console_esp_none.asm gives the same names, doing nothing). Thumb-1.

; ---------- the ESP8285 of the clones "Pico W-2023" ----------
;
; These boards have no CYW43439 but an ESP8285 at UART0 (its RX at GPIO 0, its TX at GPIO 1: the pins of the console
; and of the Debug Probe). With the firmware of Asmonite on it (wlan\esp8285_fw.asm) it is a WiFi card: SLIP frames
; (0xC0 ends one; 0xC0 in it is 0xDB 0xDC, 0xDB is 0xDB 0xDD), the first byte their type (P ping -> p, S the state,
; J join, F a frame, C scan, D leave, B faster; back H, F, E an event, G). Our firmware starts at 115200 baud; B makes
; it (and then the console) go to 460800. esp_detect finds it at the start of the console (an RP2040 without a W
; chip) and sends nothing at another rate than 115200 first: an ESP that waits in its download mode (its BOOT button
; held) takes the baud rate of the first bytes that come (autobaud), and a ping at 460800 made it deaf for
; esp8285rom.py. The steps, at 115200: 100 ms only listen; bytes came (an ESP that starts with the board: its boot ROM,
; libmain) -> up to 4 s for the hello of our firmware (H "esp8285 ..."), then up to 8 pings 0.5 s apart (it may start
; more slowly); none came -> a ping P "ASM", 50 ms for p "ASM". It answered: B, its b, UART0 to 460800, a ping there. No answer to the ping at 115200: one at 460800 (the
; console was reset, the ESP runs at 460800 already). Found: WL_ESP 1, UART0 stays at 460800 and belongs to the ESP
; (put_char, poll_byte and irq_on of the console leave it out: the console then only over USB). Else UART0 at 115200
; (on a Pico with a Debug Probe that may have seen the pings as a few bytes of noise)
;
; Found, the bytes of the ESP come by interrupt (esp_irq: its FIFO holds 32 bytes, 0.7 ms at 460800) into a ring of
; 1 KB (ESP_RING); esp_poll takes them through SLIP into WL_RX (the packets of the CYW43439 there are not used). V_WIFI
; is 1 then too: the console treats the ESP as the WiFi chip of a W, and console_wifi.asm calls the functions here where
; it would talk to the CYW43439: wlan_start (esp_start: a ping), wl_off (esp_leave: D), wl_join (esp_join: J),
; wl_read_mac (esp_mac: S), wl_send_now (F), wl_service_one (esp_service: a frame F or an event E of the ring). So
; DHCP, ARP and ping at the prompt (SysTick: wl_tick) and wl_call for programs work as on a W. SysTick gets a lower
; priority than UART0 and USB (its answers take milliseconds on UART0 while bytes come).
E_STEPS         equ 4                   ; WLV + WL_ESP + ...: the steps of esp_detect
E_BYTES         equ 8                   ;   ... the bytes it saw
E_ERRS          equ 12                  ;   ... those with an error
E_HEAD          equ 16                  ;   the ring: where esp_irq puts the next byte
E_TAIL          equ 20                  ;   ... where esp_poll takes the next one
E_LEN           equ 24                  ;   the bytes of the frame in WL_RX so far (esp_poll)
E_ESC           equ 28                  ;   1: an ESC came last
E_LOST          equ 32                  ;   1: bytes were lost (the ring full, an error): the frame is left out
ESP_RING        equ WL_FTX              ; 1 KB (WL_FTX: the frames to the CYW43439, not used with the ESP)
ESP_RING_BITS   equ 10

esp_detect:
    push {lr}
    ldr  r3, esp_lit_diag           ; the steps (E_STEPS), the bytes (E_BYTES), those with an error (E_ERRS): 0
    movs r0, #0
    str  r0, [r3]
    str  r0, [r3, #4]
    str  r0, [r3, #8]
    adr  r0, esp_hello
    movs r1, #8
    ldr  r2, esp_lit_short
    bl   esp_listen                 ; 100 ms: only listen, at the 115200 of the console (any byte counts)
    cmp  r1, #0
    beq  ed_d1
    movs r2, #1                     ; step 1: bytes in the first 100 ms
    bl   esp_mark
ed_d1:
    cmp  r0, #0
    bne  ed_hello
    cmp  r1, #0
    beq  ed_ping
    adr  r0, esp_hello              ; bytes came: the ESP starts; its hello
    movs r1, #8
    ldr  r2, esp_lit_long
    bl   esp_listen
    cmp  r0, #0
    bne  ed_hello
    movs r2, #4                     ; step 4: no hello, pings at 115200
    bl   esp_mark
    push {r4}                       ; no hello (yet): pings at 115200, 8 of them 0.5 s apart (harmless for a boot
    movs r4, #8                     ; ROM that waits: it takes 115200 then, the rate of esp8285rom.py)
ed_again:
    adr  r0, esp_ping_frame
    movs r1, #6
    bl   esp_raw
    adr  r0, esp_pong
    movs r1, #5
    ldr  r2, esp_lit_500ms
    bl   esp_listen
    cmp  r0, #0
    bne  ed_answered
    subs r4, r4, #1
    bne  ed_again
    pop  {r4}
    pop  {pc}                       ; no answer: no ESP of ours (UART0 stays at 115200)
ed_answered:
    pop  {r4}
    movs r2, #8                     ; step 8: a ping at 115200 answered
    bl   esp_mark
    b    ed_slow
ed_hello:
    movs r2, #2                     ; step 2: the hello came
    bl   esp_mark
    b    ed_slow
ed_ping:
    movs r2, #16                    ; step 16: quiet, a ping at 115200
    bl   esp_mark
    adr  r0, esp_ping_frame         ; quiet: perhaps it runs already; a ping at 115200 first
    movs r1, #6
    bl   esp_raw
    adr  r0, esp_pong
    movs r1, #5
    ldr  r2, esp_lit_50ms
    bl   esp_listen
    cmp  r0, #0
    beq  ed_p460
    movs r2, #32                    ; step 32: answered at 115200
    bl   esp_mark
    b    ed_slow
ed_p460:
    movs r0, #6                     ; 460800: 48,000,000 / (16 * 460800) = 6.51: 6 and 33/64
    movs r1, #33
    bl   esp_baud
    bl   esp_flush
    b    ed_fast                    ; perhaps it runs at 460800 already
ed_slow:
    adr  r0, esp_b_frame            ; it answers at 115200: B, its b at 115200, then both at 460800
    movs r1, #3
    bl   esp_raw
    adr  r0, esp_b_answer
    movs r1, #2
    ldr  r2, esp_lit_50ms
    bl   esp_listen
    cmp  r0, #0
    bne  ed_b
    pop  {pc}                       ; no b: UART0 stays at 115200
ed_b:
    movs r2, #64                    ; step 64: b came
    bl   esp_mark
    movs r0, #6
    movs r1, #33
    bl   esp_baud
    bl   esp_flush
ed_fast:
    push {r4}                       ; pings at 460800, up to 3 (after B the ESP drains its FIFO before it switches:
    movs r4, #3                     ; the first one may come too early)
ed_fast_again:
    adr  r0, esp_ping_frame
    movs r1, #6
    bl   esp_raw
    adr  r0, esp_pong
    movs r1, #5
    ldr  r2, esp_lit_50ms
    bl   esp_listen
    cmp  r0, #0
    bne  ed_fast_ok
    subs r4, r4, #1
    bne  ed_fast_again
    pop  {r4}
    b    ed_none
ed_fast_ok:
    pop  {r4}
    b    ed_found
ed_none:
    movs r0, #26                    ; 115200 again: the console's
    movs r1, #3
    bl   esp_baud
    bl   esp_flush
    pop  {pc}
ed_found:
    movs r2, #128                   ; step 128: answered at 460800
    bl   esp_mark
    ldr  r1, esp_lit_esp            ; the ESP8285 with our firmware
    movs r0, #1
    str  r0, [r1]
    bl   esp_rx_on                  ; its bytes by interrupt, SysTick for its frames, V_WIFI 1
    pop  {pc}

; the steps of esp_detect: E_STEPS |= r2 (a look with mem 0x20039fc8 16: WL_ESP, the steps, the bytes, those with
; an error); keeps r0, r1
esp_mark:
    ldr  r3, esp_lit_diag
    push {r0}
    ldr  r0, [r3]
    orrs r0, r2
    str  r0, [r3]
    pop  {r0}
    bx   lr

; listens on UART0 for r2 microseconds for the bytes r0 (r1 of them, in a row): r0 1 when they came, else 0; r1 1
; when any byte came (one with an error too)
esp_listen:
    push {r4, r5, r6, r7, lr}
    sub  sp, sp, #12                ; [sp] the bytes, [sp + 4] their number, [sp + 8] 1: a byte came
    str  r0, [sp]
    str  r1, [sp, #4]
    movs r0, #0
    str  r0, [sp, #8]
    mov  r7, r2
    movs r4, #0                     ; how many of them came in a row so far
    bl   tick_now
    mov  r6, r0
el_loop:
    ldr  r1, esp_lit_uart0
    ldr  r2, [r1, #UARTFR]
    lsls r2, r2, #27                ; RXFE (bit 4) into N
    bmi  el_wait
    ldr  r0, [r1, #UARTDR]
    movs r2, #1
    str  r2, [sp, #8]
    ldr  r3, esp_lit_diag           ; the bytes (+ 4) and those with an error (+ 8) of esp_detect
    ldr  r2, [r3, #4]
    adds r2, r2, #1
    str  r2, [r3, #4]
    lsls r2, r0, #20
    lsrs r2, r2, #28                ; the errors (bits 11 .. 8): a byte at another baud rate
    beq  el_good
    ldr  r2, [r3, #8]
    adds r2, r2, #1
    str  r2, [r3, #8]
    b    el_bad
el_good:
    uxtb r0, r0
    ldr  r2, [sp]
    ldrb r3, [r2, r4]
    cmp  r0, r3
    beq  el_match
    movs r4, #0
    ldrb r3, [r2]
    cmp  r0, r3
    bne  el_loop
    movs r4, #1                     ; the first one: perhaps the start
    b    el_loop
el_match:
    adds r4, r4, #1
    ldr  r2, [sp, #4]
    cmp  r4, r2
    bne  el_loop
    movs r0, #1
    b    el_ret
el_bad:
    movs r4, #0
    b    el_loop
el_wait:
    bl   tick_now
    subs r0, r0, r6
    cmp  r0, r7
    blo  el_loop
    movs r0, #0
el_ret:
    ldr  r1, [sp, #8]
    add  sp, sp, #12
    pop  {r4, r5, r6, r7, pc}

; r1 bytes from r0 to UART0 as they are (a frame made before: the ping, B)
esp_raw:
    push {r4, lr}
    mov  r3, r0
    mov  r4, r1
    movs r2, #0
    ldr  r0, esp_lit_uart0
ep_next:
    ldr  r1, [r0, #UARTFR]
    lsls r1, r1, #26                ; TXFF (bit 5) into N
    bmi  ep_next
    ldrb r1, [r3, r2]
    str  r1, [r0, #UARTDR]
    adds r2, r2, #1
    cmp  r2, r4
    bne  ep_next
    pop  {r4, pc}

; UART0 to another baud rate: r0 IBRD, r1 FBRD (the PL011 takes them with a write of LCR_H, while it is off: written
; while on, the new rate did not come; the Pico SDK switches it off for that too)
esp_baud:
    ldr  r2, esp_lit_uart0
eb_busy:
    ldr  r3, [r2, #UARTFR]
    lsls r3, r3, #28                ; BUSY (bit 3) into N: the last byte still goes out
    bmi  eb_busy
    movs r3, #0
    str  r3, [r2, #UARTCR]
    str  r0, [r2, #UARTIBRD]
    str  r1, [r2, #UARTFBRD]
    movs r3, #LCR_8BIT_FIFO
    str  r3, [r2, #UARTLCR_H]
    ldr  r3, esp_lit_cr_on
    str  r3, [r2, #UARTCR]
    bx   lr

; what waits in the receive FIFO of UART0: away
esp_flush:
    ldr  r1, esp_lit_uart0
ef_next:
    ldr  r2, [r1, #UARTFR]
    lsls r2, r2, #27                ; RXFE into N
    bmi  ef_done
    ldr  r2, [r1, #UARTDR]
    b    ef_next
ef_done:
    bx   lr

    align 4
esp_lit_uart0:      dd UART0
esp_lit_cr_on:      dd CR_ON
esp_lit_esp:        dd WLV + WL_ESP
esp_lit_short:      dd 100000               ; microseconds
esp_lit_long:       dd 4000000
esp_lit_50ms:       dd 50000
esp_lit_500ms:      dd 500000
esp_lit_diag:       dd WLV + WL_ESP + E_STEPS
esp_ping_frame:
    db   0xC0, 'P', 'A', 'S', 'M', 0xC0
    align 4
esp_pong:
    db   'p', 'A', 'S', 'M', 0xC0
    align 4
esp_hello:
    db   'Hesp8285'                 ; the start of the frame H of our firmware
    align 4
esp_b_frame:
    db   0xC0, 'B', 0xC0
    align 4
esp_b_answer:
    db   'b', 0xC0
    align 4

; r0 1 when the WiFi is the ESP8285 (WL_ESP), else 0; keeps r1 .. r7
esp_mode:
    ldr  r0, esp2_esp
    ldr  r0, [r0]
    bx   lr

; a frame to the ESP: r0 its type, r1 the data, r2 their number (END, type, data with ESC, END)
esp_send:
    push {r4, r5, r6, lr}
    mov  r4, r0
    mov  r5, r1
    mov  r6, r2
    movs r0, #0xC0
    bl   esp_putb
    mov  r0, r4
    bl   esp_putesc
esn_next:
    cmp  r6, #0
    beq  esn_end
    ldrb r0, [r5]
    bl   esp_putesc
    adds r5, r5, #1
    subs r6, r6, #1
    b    esn_next
esn_end:
    movs r0, #0xC0
    bl   esp_putb
    pop  {r4, r5, r6, pc}

; the byte r0 of a frame (END and ESC as two bytes)
esp_putesc:
    push {lr}
    cmp  r0, #0xC0
    beq  epe_end
    cmp  r0, #0xDB
    beq  epe_esc
    bl   esp_putb
    pop  {pc}
epe_end:
    movs r0, #0xDB
    bl   esp_putb
    movs r0, #0xDC
    bl   esp_putb
    pop  {pc}
epe_esc:
    movs r0, #0xDB
    bl   esp_putb
    movs r0, #0xDD
    bl   esp_putb
    pop  {pc}

; the byte r0 to UART0 (waits while its FIFO is full); keeps r4 .. r7
esp_putb:
    ldr  r1, esp2_uart0
epb_wait:
    ldr  r2, [r1, #UARTFR]
    lsls r2, r2, #26                ; TXFF into N
    bmi  epb_wait
    str  r0, [r1, #UARTDR]
    bx   lr

; a request to the ESP: r0 its type, r1 the type of the answer, r2 the microseconds to wait (no data); esp_ask_d: r0
; the type, r1 the data, r2 their number, r3 the type of the answer, a second. r0 the length of the answer in WL_RX
; (its type at +0), -1 none. UART0 at 460800 with its interrupt first (esp_uart); the frames of other types on the
; way go to esp_handle (a frame of the network, an event)
esp_ask:
    push {r4, r5, r6, lr}
    mov  r5, r1
    mov  r6, r2
    movs r1, #0
    movs r2, #0
    b    eak_go
esp_ask_d:
    push {r4, r5, r6, lr}
    mov  r5, r3
    ldr  r6, esp_lit_1s
eak_go:
    push {r0, r1, r2}
    bl   esp_uart
    pop  {r0, r1, r2}
    bl   esp_send
    bl   tick_now
    mov  r4, r0
eak_next:
    bl   esp_poll
    cmp  r0, #0
    bne  eak_frame
    bl   tick_now
    subs r0, r0, r4
    cmp  r0, r6
    blo  eak_next
    movs r0, #0
    mvns r0, r0                     ; -1
    pop  {r4, r5, r6, pc}
eak_frame:
    ldr  r1, esp_lit_rx
    ldrb r1, [r1]
    cmp  r1, r5
    beq  eak_end
    bl   esp_handle
    b    eak_next
eak_end:
    pop  {r4, r5, r6, pc}

; wlan on, wlan scan (wn_chip): the ESP answers a ping? r0 0 (WL_STATE 1 when it was 0), else 1 (it said why)
esp_chip:
    push {lr}
    ldr  r1, esp_lit_wlv
    ldr  r0, [r1, #WL_STATE]
    cmp  r0, #0
    bne  ech_on
    bl   esp_start
    cmp  r0, #0
    bne  ech_fail
    bl   print_inline
    db   'The ESP8285 answers (the firmware of Asmonite on it).', 13, 10, 0
    align 2
ech_on:
    movs r0, #0
    pop  {pc}
ech_fail:
    bl   put_text
    bl   put_nl
    movs r0, #1
    pop  {pc}

; wlan off: the ESP leaves its network (D); it stays on (no pin of the RP2040 switches it)
esp_off:
    push {lr}
    bl   esp_leave
    bl   print_inline
    db   'The ESP8285 is in no network (it stays on).', 13, 10, 0
    align 2
    pop  {pc}

; wlan scan with the ESP: C, its answer c (42 bytes per network: BSSID 6, channel, RSSI, security, name length,
; name 32); each one as a BSS info of the CYW43439 (wl_seen_bss, wl_show_bss: the same lines as on a Pico W)
esp_scan:
    push {r4, r5, r6, lr}
    ldr  r0, esp_lit_seen_n
    movs r1, #0
    str  r1, [r0]
    movs r0, #'C'
    movs r1, #'c'
    ldr  r2, esp_lit_10s
    bl   esp_ask
    cmp  r0, #0
    bgt  esc_got
    bl   wl_scan_failed             ; for a program: WL_SCNT -1, r0 1
    cmp  r0, #0
    bne  esc_quiet
    bl   print_inline
    db   'The ESP8285 gave no answer to the scan.', 13, 10, 0
    align 2
esc_quiet:
    pop  {r4, r5, r6, pc}
esc_got:
    subs r5, r0, #1                 ; the bytes of the networks
    ldr  r4, esp_lit_rx
    adds r4, r4, #1
    cmp  r5, #1
    bne  esc_next
    ldrb r0, [r4]
    cmp  r0, #0xFF
    bne  esc_next
    bl   wl_scan_failed
    cmp  r0, #0
    bne  esc_quiet
    bl   print_inline
    db   'The ESP8285 did not start the scan.', 13, 10, 0
    align 2
    pop  {r4, r5, r6, pc}
esc_next:
    cmp  r5, #42
    blo  esc_end
    ldr  r6, esp_lit_bss
    mov  r0, r6
    movs r1, #80
    bl   wl_memset0
    mov  r0, r6
    adds r0, r0, #8                 ; the BSSID
    mov  r1, r4
    movs r2, #6
    bl   wl_memcpy
    ldrb r0, [r4, #8]               ; the security: not 0, the bit "privacy" of the capability
    cmp  r0, #0
    beq  esc_open
    movs r0, #0x10
    strb r0, [r6, #16]
esc_open:
    ldrb r0, [r4, #9]
    strb r0, [r6, #18]              ; the length of the name
    mov  r0, r6
    adds r0, r0, #19
    mov  r1, r4
    adds r1, r1, #10
    movs r2, #32
    bl   wl_memcpy
    ldrb r0, [r4, #6]
    mov  r1, r6
    adds r1, r1, #72
    strb r0, [r1]                   ; the channel
    ldrb r0, [r4, #7]
    sxtb r0, r0
    mov  r1, r6
    adds r1, r1, #78
    strb r0, [r1]                   ; the RSSI, 16 bits
    asrs r0, r0, #8
    strb r0, [r1, #1]
    bl   wl_seen_bss                ; (r6 the BSS info)
    cmp  r0, #0
    bne  esc_skip
    ldrb r0, [r4, #8]               ; the security (authmode of the ESP8266 SDK: the numbers of the ESP32)
    bl   wl_put_bss
esc_skip:
    adds r4, r4, #42
    subs r5, r5, #42
    b    esc_next
esc_end:
    bl   wl_scan_count
    pop  {r4, r5, r6, pc}

    align 4
esp_lit_rx:         dd WL_RX
esp_lit_1s:         dd 1000000
esp_lit_bss:        dd WL_DATA
esp_lit_seen_n:     dd WLV + WL_NSEEN
esp_lit_wlv:        dd WLV
esp_lit_200ms:      dd 200000
esp_lit_10s:        dd 10000000
esp2_uart0:         dd UART0
esp2_esp:           dd WLV + WL_ESP

; ---------- the ESP8285 as the WiFi chip: its bytes by interrupt, its frames, the join ----------

; found (esp_detect): its bytes by interrupt (esp_irq into ESP_RING), SysTick for its frames (wl_tick_init) with a
; lower priority than UART0 and USB, V_WIFI 1 (the console treats the ESP as the WiFi chip of a W)
esp_rx_on:
    push {lr}
    ldr  r1, esp3_wifi
    movs r0, #1
    str  r0, [r1]
    ldr  r3, esp3_v
    movs r0, #0
    str  r0, [r3, #E_HEAD]
    str  r0, [r3, #E_TAIL]
    str  r0, [r3, #E_LEN]
    str  r0, [r3, #E_ESC]
    str  r0, [r3, #E_LOST]
    ldr  r0, esp3_vtab
    ldr  r1, esp3_irq
    movs r2, #UART0_VECTOR * 4
    str  r1, [r0, r2]               ; UART0: esp_irq (no longer uart_irq of the console)
    ldr  r0, esp3_uart0
    movs r1, #2
    str  r1, [r0, #0x34]            ; UARTIFLS: an interrupt at 4 bytes in the receive FIFO (sending: at half)
    bl   wl_tick_init
    ldr  r0, esp3_shpr3             ; SysTick (bits 31 .. 24): 0x80
    ldr  r1, [r0]
    lsls r1, r1, #8
    lsrs r1, r1, #8
    movs r2, #0x80
    lsls r2, r2, #24
    orrs r1, r2
    str  r1, [r0]
    ldr  r0, esp3_ipr1              ; USB (interrupt 5, bits 15 .. 8): 0x40, UART0 stays at 0
    ldr  r1, [r0]
    ldr  r2, esp3_ff00
    bics r1, r2
    movs r2, #0x40
    lsls r2, r2, #8
    orrs r1, r2
    str  r1, [r0]
    bl   esp_uart
    pop  {pc}

; UART0 at 460800 (a program or the bridge of esp8285rom.py may have changed it) and its interrupt for the bytes that
; come (4 in the FIFO, or a pause)
esp_uart:
    push {lr}
    ldr  r2, esp3_uart0
    ldr  r0, [r2, #UARTIBRD]
    cmp  r0, #6
    beq  eu_irq
    movs r0, #6
    movs r1, #33
    bl   esp_baud
eu_irq:
    ldr  r2, esp3_uart0
    movs r0, #(1 << 4) | (1 << 6)   ; RXIM, RTIM
    str  r0, [r2, #UARTIMSC]
    ldr  r1, esp3_iser
    ldr  r0, esp3_bit
    str  r0, [r1]
    pop  {pc}

; the interrupt of UART0 (an exception): its bytes into ESP_RING; a full ring or a byte with an error sets E_LOST.
; Its interrupts cleared first: a byte that comes after the FIFO was read empty raises a new one
esp_irq:
    push {r4, lr}
    ldr  r3, esp3_v
    ldr  r4, esp3_ring
    ldr  r1, esp3_uart0
    movs r0, #0x7f
    lsls r0, r0, #4                 ; RX, TX, RT and the errors (bits 10 .. 4)
    str  r0, [r1, #UARTICR]
eir_next:
    ldr  r1, esp3_uart0
    ldr  r0, [r1, #UARTFR]
    lsls r0, r0, #27                ; RXFE into N
    bmi  eir_done
    ldr  r0, [r1, #UARTDR]
    lsls r2, r0, #20
    lsrs r2, r2, #28                ; the errors (bits 11 .. 8)
    bne  eir_lost
    ldr  r1, [r3, #E_HEAD]
    adds r2, r1, #1
    lsls r2, r2, #32 - ESP_RING_BITS
    lsrs r2, r2, #32 - ESP_RING_BITS
    ldr  r1, [r3, #E_TAIL]
    cmp  r2, r1
    beq  eir_lost                   ; full
    ldr  r1, [r3, #E_HEAD]
    strb r0, [r4, r1]
    str  r2, [r3, #E_HEAD]
    b    eir_next
eir_lost:
    movs r0, #1
    str  r0, [r3, #E_LOST]
    b    eir_next
eir_done:
    pop  {r4, pc}

; the bytes of the ring through SLIP into WL_RX (E_LEN and E_ESC keep a frame that came in part): r0 the length of a
; whole frame there (its type at +0), 0 when the ring ran empty first. A frame longer than 2048 bytes, or one while
; bytes were lost (E_LOST), is left out
esp_poll:
    push {r4, r5, r6, r7, lr}
    ldr  r7, esp3_v
    ldr  r6, esp3_rx
    ldr  r5, esp3_ring
    ldr  r4, [r7, #E_LEN]
epl_next:
    ldr  r1, [r7, #E_TAIL]
    ldr  r2, [r7, #E_HEAD]
    cmp  r1, r2
    beq  epl_empty
    ldrb r0, [r5, r1]
    adds r1, r1, #1
    lsls r1, r1, #32 - ESP_RING_BITS
    lsrs r1, r1, #32 - ESP_RING_BITS
    str  r1, [r7, #E_TAIL]
    cmp  r0, #0xC0
    beq  epl_end
    ldr  r2, [r7, #E_ESC]
    cmp  r2, #0
    bne  epl_esc
    cmp  r0, #0xDB
    bne  epl_store
    movs r2, #1
    str  r2, [r7, #E_ESC]
    b    epl_next
epl_esc:
    movs r2, #0
    str  r2, [r7, #E_ESC]
    cmp  r0, #0xDC
    bne  epl_esc2
    movs r0, #0xC0
    b    epl_store
epl_esc2:
    cmp  r0, #0xDD
    bne  epl_store
    movs r0, #0xDB
epl_store:
    ldr  r2, esp3_2048
    cmp  r4, r2
    bhs  epl_over                   ; too long: counted on, left out at its END
    strb r0, [r6, r4]
epl_over:
    adds r4, r4, #1
    b    epl_next
epl_end:
    mov  r0, r4
    movs r4, #0
    str  r4, [r7, #E_ESC]
    ldr  r2, [r7, #E_LOST]
    str  r4, [r7, #E_LOST]
    cmp  r2, #0
    bne  epl_next                   ; bytes lost: left out
    cmp  r0, #0
    beq  epl_next                   ; an END between frames
    ldr  r2, esp3_2048
    cmp  r0, r2
    bhi  epl_next
    str  r4, [r7, #E_LEN]
    pop  {r4, r5, r6, r7, pc}
epl_empty:
    str  r4, [r7, #E_LEN]
    movs r0, #0
    pop  {r4, r5, r6, r7, pc}

; wl_service_one with the ESP: a whole frame of the ring (esp_handle)? r0 1, else 0
esp_service:
    push {lr}
    bl   esp_poll
    cmp  r0, #0
    beq  esv_end
    bl   esp_handle
    movs r0, #1
esv_end:
    pop  {pc}

; a frame of the ESP in WL_RX (r0 its length) that answers no request. In the network (WL_STATE 2): F a frame of it
; (ARP and ping for the board answered, wl_answer; else into the ring of the frames for wifi_recv), E 1 (disconnected:
; the board in no network); else nothing
esp_handle:
    push {r4, r5, lr}
    ldr  r4, esp3_rx
    subs r5, r0, #1                 ; the bytes behind the type
    ldrb r0, [r4]
    adds r4, r4, #1
    ldr  r2, esp3_wlv
    ldr  r1, [r2, #WL_STATE]
    cmp  r1, #2
    bne  eh_end
    cmp  r0, #'E'
    beq  eh_event
    cmp  r0, #'F'
    bne  eh_end
    cmp  r5, #14
    blt  eh_end
    mov  r0, r4
    mov  r1, r5
    bl   wl_answer
    cmp  r0, #0
    bne  eh_end
    mov  r0, r4
    mov  r1, r5
    bl   wl_ring_put
    b    eh_end
eh_event:
    ldrb r0, [r4]
    cmp  r0, #1
    bne  eh_end
    movs r0, #1
    str  r0, [r2, #WL_STATE]
eh_end:
    pop  {r4, r5, pc}

; wl_off, wlan off: the ESP leaves its network (D); WL_STATE 0, no address
esp_leave:
    push {lr}
    movs r0, #'D'
    movs r1, #'d'
    ldr  r2, esp3_200ms
    bl   esp_ask
    ldr  r1, esp3_wlv
    movs r0, #0
    str  r0, [r1, #WL_STATE]
    str  r0, [r1, #WL_IP]
    pop  {pc}

; wl_read_mac: the MAC of the ESP (its state S: s, the state, connected, the MAC) into the 6 bytes at r0: r0 0, else 1
esp_mac:
    push {r4, lr}
    mov  r4, r0
    movs r0, #'S'
    movs r1, #'s'
    ldr  r2, esp3_200ms
    bl   esp_ask
    cmp  r0, #9
    blt  emc_fail
    mov  r0, r4
    ldr  r1, esp3_rx
    adds r1, r1, #3
    movs r2, #6
    bl   wl_memcpy
    movs r0, #0
    pop  {r4, pc}
emc_fail:
    movs r0, #1
    pop  {r4, pc}

; wlan_start: the ESP answers a ping? r0 0 (WL_STATE 1 when it was 0), else the text of what went wrong
esp_start:
    push {lr}
    ldr  r1, esp3_wlv
    ldr  r0, [r1, #WL_STATE]
    cmp  r0, #0
    bne  est_ok
    movs r0, #'P'
    movs r1, #'p'
    ldr  r2, esp3_200ms
    bl   esp_ask
    cmp  r0, #0
    blt  est_fail
    ldr  r1, esp3_wlv
    movs r0, #1
    str  r0, [r1, #WL_STATE]
est_ok:
    movs r0, #0
    pop  {pc}
est_fail:
    adr  r0, esp_e_answer
    pop  {pc}

; r1 (0 .. 15) as a hex digit; keeps r0, r2, r3
esp_hexd:
    cmp  r1, #10
    blo  ehd_digit
    adds r1, r1, #'a' - '0' - 10
ehd_digit:
    adds r1, r1, #'0'
    bx   lr

; wl_join with the ESP: the network of WL_NET. D first (after its start the ESP joins the network it knows by itself:
; so the event connected comes for this join), then J: the length of the name, the name, the length of the key, the
; key: the PMK of wlan set (WL_NET + 48) as 64 hex digits (NONOS takes 64 characters as the key itself, no passphrase;
; the console keeps no password), none for an open network. Then up to 15 s for E 0 (connected) or E 1 with a reason
; that says why: 201 the network not found, 2, 15, 202, 204 the key (others: it tries again). r0 0 (WL_STATE 2, WL_MAC,
; the ring of the frames empty), else the text of what went wrong (D: the ESP stops trying)
esp_join:
    push {r4, r5, r6, r7, lr}
    bl   wl_diag_clear
    movs r0, #'D'
    movs r1, #'d'
    ldr  r2, esp3_200ms
    bl   esp_ask
    ldr  r4, esp3_net
    ldr  r5, esp3_dtx               ; J is made in WL_DTX
    ldr  r6, [r4, #12]              ; the length of the name
    strb r6, [r5]
    adds r0, r5, #1
    mov  r1, r4
    adds r1, r1, #16
    mov  r2, r6
    bl   wl_memcpy
    adds r7, r5, r6
    adds r7, r7, #1                 ; the length of the key
    movs r0, #0
    strb r0, [r7]
    adds r7, r7, #1
    ldr  r0, [r4, #8]
    movs r1, #1
    tst  r0, r1
    bne  ej_send                    ; open: no key
    subs r1, r7, #1
    movs r0, #64
    strb r0, [r1]
    movs r3, #0
ej_hex:
    mov  r2, r4
    adds r2, r2, #48
    ldrb r0, [r2, r3]
    lsrs r1, r0, #4
    bl   esp_hexd
    strb r1, [r7]
    movs r1, #15
    ands r1, r0
    bl   esp_hexd
    strb r1, [r7, #1]
    adds r7, r7, #2
    adds r3, r3, #1
    cmp  r3, #32
    blo  ej_hex
ej_send:
    movs r0, #'J'
    mov  r1, r5
    subs r2, r7, r5
    movs r3, #'j'
    bl   esp_ask_d
    mov  r6, r0
    mov  r0, r5
    movs r1, #100
    bl   wl_memset0                 ; the key gone from WL_DTX
    cmp  r6, #2
    blt  ej_noanswer
    ldr  r0, esp3_rx
    ldrb r0, [r0, #1]
    cmp  r0, #1
    bne  ej_noanswer                ; j 0: it did not take it
    bl   tick_now
    mov  r6, r0
ej_wait:
    bl   tick_now
    subs r0, r0, r6
    ldr  r1, esp3_15s
    cmp  r0, r1
    bhs  ej_timeout
    bl   esp_poll
    cmp  r0, #0
    beq  ej_wait
    ldr  r4, esp3_rx
    ldrb r1, [r4]
    cmp  r1, #'E'
    beq  ej_event
    bl   esp_handle
    b    ej_wait
ej_event:
    ldrb r1, [r4, #1]               ; the event
    cmp  r1, #0
    beq  ej_ok
    cmp  r1, #1
    bne  ej_wait
    cmp  r0, #6
    blo  ej_wait
    ldrb r1, [r4, #5]               ; the reason
    cmp  r1, #201
    beq  ej_notfound
    cmp  r1, #2
    beq  ej_key
    cmp  r1, #15
    beq  ej_key
    cmp  r1, #202
    beq  ej_key
    cmp  r1, #204
    beq  ej_key
    b    ej_wait
ej_notfound:
    ldr  r0, esp3_e_notfound
    b    ej_fail
ej_key:
    ldr  r0, esp3_e_key
    b    ej_fail
ej_timeout:
    ldr  r0, esp3_e_jointime
    b    ej_fail
ej_noanswer:
    adr  r0, esp_e_answer
ej_fail:
    push {r0}
    movs r0, #'D'
    movs r1, #'d'
    ldr  r2, esp3_200ms
    bl   esp_ask
    pop  {r0}
    pop  {r4, r5, r6, r7, pc}
ej_ok:
    ldr  r0, esp3_mac
    bl   esp_mac
    ldr  r1, esp3_wlv
    ldr  r0, [r1, #WL_RPUT]
    str  r0, [r1, #WL_RGET]         ; the ring of the frames empty
    movs r0, #0
    str  r0, [r1, #WL_SEQ]
    movs r0, #1
    str  r0, [r1, #WL_SEQMAX]       ; wl_credit: always 1 (esp_send waits for room in the FIFO)
    movs r0, #2
    str  r0, [r1, #WL_STATE]
    movs r0, #0
    pop  {r4, r5, r6, r7, pc}

    align 4
esp3_v:             dd WLV + WL_ESP
esp3_wlv:           dd WLV
esp3_wifi:          dd VARS + V_WIFI
esp3_rx:            dd WL_RX
esp3_ring:          dd ESP_RING
esp3_2048:          dd 2048
esp3_uart0:         dd UART0
esp3_vtab:          dd VTAB
esp3_irq:           dd esp_irq + RUN_OFFSET + 1
esp3_shpr3:         dd 0xe000ed20
esp3_ipr1:          dd 0xe000e404
esp3_ff00:          dd 0xff00
esp3_iser:          dd NVIC_ISER
esp3_bit:           dd UART0_IRQ_BIT
esp3_200ms:         dd 200000
esp3_15s:           dd 15000000
esp3_net:           dd WL_NET
esp3_dtx:           dd WL_DTX
esp3_mac:           dd WLV + WL_MAC
esp3_e_notfound:    dd wl_e_notfound + RUN_OFFSET
esp3_e_key:         dd wl_e_key + RUN_OFFSET
esp3_e_jointime:    dd wl_e_jointime + RUN_OFFSET
esp_e_answer:
    db   'The ESP8285 does not answer (its firmware: python wlan\esp8285rom.py fw, with its BOOT button).', 0
    align 4
