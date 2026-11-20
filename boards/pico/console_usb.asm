; The console of Asmonite over the USB cable of the board: a USB device (CDC-ACM, a COM port on the PC), the part of
; boards\pico\console.asm and boards\pico2\console.asm that talks to the USB controller. It is the USB code of
; usb_cdc.asm (the same requests, descriptors and plan of the DPRAM), driven by the interrupt of the controller
; (usb_irq) instead of a loop: so the console answers on USB also while a program runs. Thumb-1, for both chips.
;
; The console has set up the clocks before usb_init: clk_usb at 48 MHz from PLL_USB (and clk_sys from it too).
; It gives: USB_IRQN (the number of the interrupt of the controller: 5 on the RP2040, 14 on the RP2350), USB_RESET_BIT
; (its bit in RESETS), RESETS, USBV (128 bytes for the variables U_ below), USB_RXB and USB_TXB (two rings of 256
; bytes), VARS + V_RUN (1 while a program runs; 2 while it stands under a debug monitor: a Ctrl+C goes into the ring
; then), and the function con_ctrl_c (called in the interrupt, r0 the frame of
; the exception, when a Ctrl+C came while a program runs).
;
; For the console:
;   usb_init           the controller on, the pull-up at D+ (the PC sees the device), its interrupt on
;   usb_putc(r0)       the byte to the host (keeps r0). Only when a terminal has the port open (DTR); when the ring is
;                      full it waits for the interrupt to empty it, at most about 50 ms, then the byte is dropped (a
;                      terminal that reads nothing does not stop the console)
;   usb_getc()         the next byte from the host, -1 if none came
;   usb_flush()        waits until what is in the ring has gone (before a reset)
; What comes from the host goes into the ring USB_RXB; a packet waits in the buffer of EP2 OUT while the ring has no
; room for it (the host gets NAK meanwhile). What goes out waits in USB_TXB; the interrupt sends it in packets of up
; to 64 bytes (a full packet with nothing behind it is followed by one of 0 bytes).
;
; The device: VID/PID 0x1209/0x0001, the test number of pid.codes (for tests on your desk; a device that others get
; needs a number of its own); "Asmonite console", its serial number the chip and the id of the board: RP2040-... or
; RP2350-... (u_make_serial; Windows shows it in the id of the device, USB\VID_1209&PID_0001\RP2350-...: so Asmonite
; knows the board without asking it, and two boards get two COM ports). The console gives USB_UID (8 bytes: the id of
; the board, read before usb_init) and USB_SERIAL (48 bytes for the descriptor).
;
; In the interrupt r5 is the USB registers, r6 the variables (USBV), r7 the buffer control words (0x50100080), as in
; usb_cdc.asm; u_regs sets them. The functions for the console keep r4 .. r7.

USB_DPRAM       equ 0x50100000
USB_REGS        equ 0x50110000
USB_BUFCTRL     equ USB_DPRAM + 0x80
USB_ADDR_ENDP   equ 0x00            ; USB registers (r5)
USB_MAIN_CTRL   equ 0x40
USB_SIE_CTRL    equ 0x4c
USB_SIE_STATUS  equ 0x50
USB_BUFF_STATUS equ 0x58
USB_EP_STALL    equ 0x68            ; EP_STALL_ARM
USB_MUXING      equ 0x74
USB_PWR         equ 0x78
USB_INTE        equ 0x90            ; BUFF_STATUS bit 4, BUS_RESET bit 12, SETUP_REQ bit 16
USB_EC_EP1_IN   equ 0x08            ; endpoint control, from the DPRAM
USB_EC_EP2_IN   equ 0x10
USB_EC_EP2_OUT  equ 0x14
USB_BC_EP0_IN   equ 0x00            ; buffer control, from USB_BUFCTRL (r7)
USB_BC_EP0_OUT  equ 0x04
USB_BC_EP2_IN   equ 0x10
USB_BC_EP2_OUT  equ 0x14
USB_EP0_BUF     equ USB_DPRAM + 0x100
USB_EP2_OUT_BUF equ USB_DPRAM + 0x1c0
USB_EP2_IN_BUF  equ USB_DPRAM + 0x200
USB_NVIC_ISER   equ 0xe000e100

U_EP0_PTR       equ 0               ; the variables (r6)
U_EP0_LEFT      equ 4               ; bytes of the IN data stage still to send
U_EP0_PID       equ 8               ; 1: the next EP0 packet is DATA1
U_EP0_STAGE     equ 12              ; 1: an IN data stage runs, 2: the IN status packet, 0: neither
U_EP0_ZLP       equ 16              ; 1: a packet of 0 bytes ends the data stage
U_EP0_OUT       equ 20              ; 1: the OUT data stage of SET_LINE_CODING comes
U_WLENGTH       equ 24              ; wLength of the setup packet
U_ADDR          equ 28              ; the new address + 0x100 until the status of SET_ADDRESS has gone, else 0
U_CONFIG        equ 32
U_DTR           equ 36              ; 1: a terminal has the port open
U_IN_BUSY       equ 40              ; 1: EP2 IN is on its way
U_IN_LEN        equ 44              ; its length
U_IN_PID        equ 48
U_OUT_PID       equ 52
U_RX_HEAD       equ 56              ; the ring of what came: where the next byte goes ...
U_RX_TAIL       equ 60              ; ... and where usb_getc takes the next one
U_RX_HOLD       equ 64              ; 1: a packet waits in the EP2 OUT buffer for room in the ring
U_RX_LEN        equ 68              ; its length
U_TX_HEAD       equ 72              ; the ring of what goes: where usb_putc puts the next byte ...
U_TX_TAIL       equ 76              ; ... and where the next packet starts
U_CC            equ 80              ; not 0: a Ctrl+C came while a program runs
U_ZERO          equ 84              ; a word of 0 (GET_STATUS, GET_INTERFACE)
U_LINE          equ 88              ; the line coding: 7 bytes (88 .. 95)
U_BOOTSEL       equ 96              ; 1: the host set 1200 baud: into the USB boot after the status (u_enter_boot)

; ---------- for the console ----------

; the controller out of reset, its DPRAM and the variables 0, to its PHY, VBUS forced, on; EP0 with an interrupt bit
; per buffer, the interrupts of BUFF_STATUS, BUS_RESET and SETUP_REQ; then the pull-up at D+
usb_init:
    push {r4, r5, r6, r7, lr}
    ldr  r0, ui_lit_reset_bit
    ldr  r1, ui_lit_resets_set
    str  r0, [r1]
    ldr  r1, ui_lit_resets_clr
    str  r0, [r1]
    ldr  r1, ui_lit_resets
uin_reset:
    ldr  r2, [r1, #8]               ; RESET_DONE
    ands r2, r0
    cmp  r2, r0
    bne  uin_reset
    bl   u_regs
    bl   u_make_serial
    movs r0, #0
    movs r2, #128
uin_vars:
    subs r2, #4
    str  r0, [r6, r2]
    bne  uin_vars
    ldr  r0, ui_lit_baud
    str  r0, [r6, #U_LINE]          ; the line coding: 115200 baud, 1 stop bit, no parity, 8 bits
    mov  r1, r6
    adds r1, #U_LINE
    movs r0, #8
    strb r0, [r1, #6]
    mov  r1, r7
    subs r1, #0x80                  ; the DPRAM: all 0
    movs r0, #0
    movs r2, #1
    lsls r2, r2, #12
uin_dpram:
    subs r2, #4
    str  r0, [r1, r2]
    bne  uin_dpram
    movs r0, #0x09                  ; TO_PHY, SOFTCON
    str  r0, [r5, #USB_MUXING]
    movs r0, #0x0c                  ; VBUS_DETECT, VBUS_DETECT_OVERRIDE_EN: as if VBUS were seen
    str  r0, [r5, #USB_PWR]
    movs r0, #1                     ; CONTROLLER_EN, device mode (RP2350: PHY_ISO goes to 0)
    str  r0, [r5, #USB_MAIN_CTRL]
    ldr  r0, ui_lit_ep0_int
    str  r0, [r5, #USB_SIE_CTRL]    ; EP0_INT_1BUF: a BUFF_STATUS bit for each EP0 buffer
    ldr  r0, ui_lit_inte
    movs r1, #USB_INTE
    str  r0, [r5, r1]
    ldr  r0, ui_lit_pullup
    str  r0, [r5, #USB_SIE_CTRL]    ; and PULLUP_EN: now the PC sees the device
    ldr  r1, ui_lit_iser
    movs r0, #1
    lsls r0, r0, #USB_IRQN
    str  r0, [r1]
    cpsie i
    pop  {r4, r5, r6, r7, pc}

    align 4
ui_lit_reset_bit:   dd USB_RESET_BIT
ui_lit_resets_set:  dd RESETS + 0x2000
ui_lit_resets_clr:  dd RESETS + 0x3000
ui_lit_resets:      dd RESETS
ui_lit_baud:        dd 115200
ui_lit_ep0_int:     dd 1 << 29
ui_lit_inte:        dd (1 << 4) | (1 << 12) | (1 << 16)
ui_lit_pullup:      dd (1 << 29) | (1 << 16)
ui_lit_iser:        dd USB_NVIC_ISER

; the serial number into USB_SERIAL as a string descriptor (48 bytes): "RP2040-" or "RP2350-" (Asmonite tells the
; Pico from the Pico 2 by it), then the 8 bytes of USB_UID as 16 hex digits: so each board has a number of its own
; (Windows gives each its own COM port)
u_make_serial:
    push {r4, lr}
    ldr  r0, ums_lit_serial
    movs r1, #48
    strb r1, [r0]
    movs r1, #3                     ; STRING
    strb r1, [r0, #1]
    adds r0, #2
    adr  r1, ums_prefix
    movs r2, #7
ums_prefix_loop:
    ldrb r3, [r1]
    strb r3, [r0]
    movs r3, #0
    strb r3, [r0, #1]               ; UTF-16
    adds r1, #1
    adds r0, #2
    subs r2, #1
    bne  ums_prefix_loop
    ldr  r1, ums_lit_uid
    movs r2, #8
ums_byte:
    ldrb r3, [r1]
    lsrs r4, r3, #4
    bl   ums_digit
    movs r4, #15
    ands r4, r3
    bl   ums_digit
    adds r1, #1
    subs r2, #1
    bne  ums_byte
    pop  {r4, pc}

; the hex digit r4 (0 .. 15) at r0 (UTF-16), r0 behind it
ums_digit:
    cmp  r4, #10
    blo  umd_num
    adds r4, #7                     ; 'A' - '0' - 10
umd_num:
    adds r4, #'0'
    strb r4, [r0]
    movs r4, #0
    strb r4, [r0, #1]
    adds r0, #2
    bx   lr

    align 4
ums_lit_serial: dd USB_SERIAL
ums_lit_uid:    dd USB_UID
ums_prefix:
.if USB_IRQN == 5
    db   'RP2040-'
.else
    db   'RP2350-'
.endif
    align 2

; the byte r0 to the host (keeps r0)
usb_putc:
    push {r0, r4, r5, r6, r7, lr}
    bl   u_regs
    ldr  r1, [r6, #U_DTR]
    cmp  r1, #0
    beq  up_end                     ; no terminal: nobody would take it
    ldr  r1, up_lit_tries
    push {r1}                       ; [sp]: the tries left, [sp + 4]: the byte
up_try:
    mrs  r4, primask
    cpsid i
    ldr  r1, [r6, #U_TX_HEAD]
    adds r2, r1, #1
    uxtb r2, r2
    ldr  r0, [r6, #U_TX_TAIL]
    cmp  r2, r0
    beq  up_full
    ldr  r0, up_lit_txb
    adds r1, r0, r1
    ldr  r0, [sp, #4]
    strb r0, [r1]
    str  r2, [r6, #U_TX_HEAD]
    bl   u_kick
    msr  primask, r4
    b    up_done
up_full:
    ; the ring is full: the interrupt empties it. In the interrupt of USB itself the byte is dropped; in another
    ; exception (a fault) or with the interrupts off the controller is run from here
    mrs  r0, ipsr
    cmp  r0, #16 + USB_IRQN
    beq  up_drop
    cmp  r4, #0
    bne  up_poll
    cmp  r0, #0
    beq  up_wait
up_poll:
    bl   u_service
up_wait:
    msr  primask, r4
    ldr  r0, [sp]
    subs r0, #1
    str  r0, [sp]
    bne  up_try
    b    up_done                    ; the host takes nothing: the byte is dropped
up_drop:
    msr  primask, r4
up_done:
    add  sp, #4
up_end:
    pop  {r0, r4, r5, r6, r7, pc}

    align 4
up_lit_tries:   dd 0x40000          ; about 50 ms at 48 MHz
up_lit_txb:     dd USB_TXB

; the next byte from the host in r0, -1 if none came
usb_getc:
    push {r4, r5, r6, r7, lr}
    bl   u_regs
    mrs  r4, primask
    cpsid i
    cmp  r4, #0
    beq  ug_take
    bl   u_service                  ; the interrupts are off: the controller from here
ug_take:
    ldr  r1, [r6, #U_RX_TAIL]
    ldr  r2, [r6, #U_RX_HEAD]
    movs r0, #0
    mvns r0, r0                     ; -1
    cmp  r1, r2
    beq  ug_end
    ldr  r0, ug_lit_rxb
    ldrb r0, [r0, r1]
    adds r1, #1
    uxtb r1, r1
    str  r1, [r6, #U_RX_TAIL]
    push {r0}
    bl   u_rx_take                  ; a packet that waited for room
    pop  {r0}
ug_end:
    msr  primask, r4
    pop  {r4, r5, r6, r7, pc}

    align 4
ug_lit_rxb:     dd USB_RXB

; waits until the ring is empty and the last packet has gone (at most about 100 ms)
usb_flush:
    push {r4, r5, r6, r7, lr}
    bl   u_regs
    ldr  r4, uf_lit_tries
uf_loop:
    ldr  r0, [r6, #U_DTR]
    cmp  r0, #0
    beq  uf_end
    ldr  r0, [r6, #U_TX_HEAD]
    ldr  r1, [r6, #U_TX_TAIL]
    cmp  r0, r1
    bne  uf_wait
    ldr  r0, [r6, #U_IN_BUSY]
    cmp  r0, #0
    beq  uf_end
uf_wait:
    subs r4, #1
    bne  uf_loop
uf_end:
    pop  {r4, r5, r6, r7, pc}

    align 4
uf_lit_tries:   dd 0x80000

; the interrupt of the USB controller: what it has to say, then a Ctrl+C for the console
usb_irq:
    push {r4, r5, r6, r7, lr}
    bl   u_regs
    bl   u_service
    ldr  r0, [r6, #U_CC]
    cmp  r0, #0
    beq  uirq_end
    movs r0, #0
    str  r0, [r6, #U_CC]
    add  r0, sp, #20                ; the frame of the exception, above what this handler pushed
    bl   con_ctrl_c
uirq_end:
    pop  {r4, r5, r6, r7, pc}

; r5, r6, r7 for the functions below
u_regs:
    ldr  r5, ur_lit_regs
    ldr  r6, ur_lit_vars
    ldr  r7, ur_lit_bufctrl
    bx   lr

    align 4
ur_lit_regs:    dd USB_REGS
ur_lit_vars:    dd USBV
ur_lit_bufctrl: dd USB_BUFCTRL

; ---------- the controller (r5, r6, r7 set, no interrupt between) ----------

; a bus reset, the buffers that are done, a setup packet
u_service:
    push {lr}
    ldr  r0, [r5, #USB_SIE_STATUS]
    movs r1, #1
    lsls r1, r1, #19                ; BUS_RESET
    tst  r0, r1
    beq  us_buffers
    bl   u_bus_reset
us_buffers:
    ldr  r0, [r5, #USB_BUFF_STATUS]
    cmp  r0, #0
    beq  us_setup
    bl   u_buffers                  ; first the buffers that are done, then a new setup packet
us_setup:
    ldr  r0, [r5, #USB_SIE_STATUS]
    movs r1, #1
    lsls r1, r1, #17                ; SETUP_REC
    tst  r0, r1
    beq  us_end
    bl   u_setup
us_end:
    pop  {pc}

u_bus_reset:
    movs r0, #1
    lsls r0, r0, #19
    str  r0, [r5, #USB_SIE_STATUS]  ; BUS_RESET cleared (a 1 clears it)
    movs r0, #0
    str  r0, [r5, #USB_ADDR_ENDP]   ; address 0 again
    str  r0, [r6, #U_ADDR]
    str  r0, [r6, #U_CONFIG]
    str  r0, [r6, #U_DTR]
    str  r0, [r6, #U_IN_BUSY]
    str  r0, [r6, #U_RX_HOLD]
    str  r0, [r6, #U_EP0_STAGE]
    ldr  r0, [r6, #U_TX_HEAD]
    str  r0, [r6, #U_TX_TAIL]       ; what waited to go: away
    bx   lr

; the buffer control word at r7 + r0 = r1 (length, FULL, PID), then with AVAILABLE as well (clk_sys and clk_usb both
; at 48 MHz: no wait between the two)
u_arm:
    str  r1, [r7, r0]
    movs r2, #1
    lsls r2, r2, #10                ; AVAILABLE
    orrs r1, r2
    str  r1, [r7, r0]
    bx   lr

; r2 bytes from r0 to r1; r0 and r1 end behind them
u_copy:
    cmp  r2, #0
    beq  ucp_done
ucp_loop:
    ldrb r3, [r0]
    strb r3, [r1]
    adds r0, r0, #1
    adds r1, r1, #1
    subs r2, r2, #1
    bne  ucp_loop
ucp_done:
    bx   lr

; ---------- EP0 ----------

; the next packet of the IN data stage: up to 64 bytes from U_EP0_PTR (0 bytes when nothing is left)
u_ep0_send_next:
    push {r4, lr}
    ldr  r4, [r6, #U_EP0_LEFT]
    cmp  r4, #64
    bls  usn_n
    movs r4, #64
usn_n:
    ldr  r0, [r6, #U_EP0_PTR]
    ldr  r1, usn_lit_buf
    mov  r2, r4
    bl   u_copy
    str  r0, [r6, #U_EP0_PTR]
    ldr  r0, [r6, #U_EP0_LEFT]
    subs r0, r0, r4
    str  r0, [r6, #U_EP0_LEFT]
    movs r1, #1
    lsls r1, r1, #15                ; FULL
    orrs r1, r4
    ldr  r0, [r6, #U_EP0_PID]
    cmp  r0, #0
    beq  usn_pid0
    movs r2, #1
    lsls r2, r2, #13                ; DATA1
    orrs r1, r2
usn_pid0:
    movs r2, #1
    eors r0, r2
    str  r0, [r6, #U_EP0_PID]       ; the other PID for the next packet
    movs r0, #USB_BC_EP0_IN
    bl   u_arm
    pop  {r4, pc}

    align 4
usn_lit_buf:    dd USB_EP0_BUF

; an IN data stage: r1 bytes from r0 (at most wLength)
u_ep0_in_data:
    ldr  r2, [r6, #U_WLENGTH]
    cmp  r1, r2
    bls  uid_len
    mov  r1, r2
uid_len:
    str  r0, [r6, #U_EP0_PTR]
    str  r1, [r6, #U_EP0_LEFT]
    movs r3, #0                     ; a packet of 0 bytes behind it: when it is shorter than asked for and its last
    cmp  r1, r2                     ; packet is a full one (64 bytes)
    bhs  uid_zlp
    cmp  r1, #0
    beq  uid_zlp
    movs r0, #63
    tst  r1, r0
    bne  uid_zlp
    movs r3, #1
uid_zlp:
    str  r3, [r6, #U_EP0_ZLP]
    movs r0, #1
    str  r0, [r6, #U_EP0_STAGE]
    b    u_ep0_send_next

; the status of a request without data, or with OUT data: an IN packet of 0 bytes, DATA1
u_ep0_status_in:
    movs r0, #0
    str  r0, [r6, #U_EP0_LEFT]
    str  r0, [r6, #U_EP0_ZLP]
    movs r0, #2
    str  r0, [r6, #U_EP0_STAGE]
    movs r0, #1
    str  r0, [r6, #U_EP0_PID]
    b    u_ep0_send_next

; EP0 OUT ready for a packet, DATA1: the data of SET_LINE_CODING, or the status after an IN data stage
u_ep0_out_status:
    movs r1, #64
    movs r2, #1
    lsls r2, r2, #13                ; DATA1
    orrs r1, r2
    movs r0, #USB_BC_EP0_OUT
    b    u_arm

; a request the device does not know: STALL on EP0 (the next setup packet ends it)
u_ep0_stall:
    movs r0, #3
    str  r0, [r5, #USB_EP_STALL]    ; EP0 IN and OUT
    movs r1, #1
    lsls r1, r1, #11                ; STALL
    str  r1, [r7, #USB_BC_EP0_IN]
    str  r1, [r7, #USB_BC_EP0_OUT]
    movs r0, #0
    str  r0, [r6, #U_EP0_STAGE]
    bx   lr

; a buffer of EP0 IN has gone
u_ep0_in_done:
    ldr  r0, [r6, #U_EP0_STAGE]
    cmp  r0, #1
    bne  uei_status
    ldr  r0, [r6, #U_EP0_LEFT]      ; the data stage: more of it?
    cmp  r0, #0
    beq  uei_last
    b    u_ep0_send_next
uei_last:
    ldr  r0, [r6, #U_EP0_ZLP]
    cmp  r0, #0
    beq  uei_out
    movs r0, #0
    str  r0, [r6, #U_EP0_ZLP]
    b    u_ep0_send_next            ; nothing left: the packet of 0 bytes
uei_out:
    movs r0, #0
    str  r0, [r6, #U_EP0_STAGE]
    b    u_ep0_out_status           ; the host sends its status packet (0 bytes)
uei_status:
    cmp  r0, #2
    bne  uei_end
    movs r0, #0
    str  r0, [r6, #U_EP0_STAGE]
    ldr  r0, [r6, #U_BOOTSEL]       ; the status of 1200 baud: into the USB boot
    cmp  r0, #0
    beq  uei_addr
    b    u_enter_boot
uei_addr:
    ldr  r0, [r6, #U_ADDR]          ; the status of SET_ADDRESS: only now the new address
    cmp  r0, #0
    beq  uei_end
    movs r1, #0x7f
    ands r0, r1
    str  r0, [r5, #USB_ADDR_ENDP]
    movs r0, #0
    str  r0, [r6, #U_ADDR]
uei_end:
    bx   lr

; a buffer of EP0 OUT has come: the line coding, or the status packet of the host
u_ep0_out_done:
    ldr  r0, [r6, #U_EP0_OUT]
    cmp  r0, #0
    beq  ueo_end
    push {lr}
    movs r0, #0
    str  r0, [r6, #U_EP0_OUT]
    ldr  r0, ueo_lit_buf
    mov  r1, r6
    adds r1, #U_LINE
    movs r2, #7
    bl   u_copy                     ; baud rate, stop bits, parity, data bits: kept
    ldr  r0, [r6, #U_LINE]
    ldr  r1, ueo_lit_1200
    cmp  r0, r1
    bne  ueo_status
    movs r0, #1
    str  r0, [r6, #U_BOOTSEL]       ; 1200 baud: into the USB boot when the status has gone
ueo_status:
    bl   u_ep0_status_in
    pop  {pc}
ueo_end:
    bx   lr

    align 4
ueo_lit_buf:    dd USB_EP0_BUF
ueo_lit_1200:   dd 1200

; the "1200 baud trick" (as the boards of Arduino and the Pico SDK): the host set 1200 baud, the status of it has gone:
; the chip restarts into its USB boot (BOOTSEL: its drive and PICOBOOT), so that Asmonite can write a new console
; without the button. The function of the boot ROM (rom_find of the console): reset_usb_boot (UB) on the RP2040,
; reboot (RB) with BOOTSEL on the RP2350. It does not return
u_enter_boot:
    push {r4, lr}
    movs r0, #0
    str  r0, [r6, #U_BOOTSEL]
    cpsid i
.if USB_IRQN == 5
    ldr  r0, ubs_lit_ub
    bl   rom_find
    cmp  r0, #0
    beq  ubs_none
    mov  r2, r0
    movs r0, #0                     ; no LED for the activity
    movs r1, #0                     ; both interfaces (the drive and PICOBOOT)
    blx  r2
.else
    ldr  r0, ubs_lit_rb
    bl   rom_find
    cmp  r0, #0
    beq  ubs_none
    mov  r4, r0
    ldr  r0, ubs_lit_flags          ; REBOOT_TYPE_BOOTSEL, NO_RETURN_ON_SUCCESS
    movs r1, #10                    ; in 10 ms
    movs r2, #0                     ; both interfaces, no LED
    movs r3, #0
    blx  r4
.endif
ubs_none:
    cpsie i                         ; (no such function: the console goes on)
    pop  {r4, pc}

    align 4
ubs_lit_ub:     dd 'U' | ('B' << 8)
ubs_lit_rb:     dd 'R' | ('B' << 8)
ubs_lit_flags:  dd 0x0102

; ---------- setup packets ----------

u_setup:
    push {r4, lr}
    movs r0, #1
    lsls r0, r0, #17
    str  r0, [r5, #USB_SIE_STATUS]  ; SETUP_REC cleared
    mov  r4, r7
    subs r4, #0x80                  ; r4: the setup packet (DPRAM)
    movs r0, #0
    str  r0, [r6, #U_EP0_OUT]
    str  r0, [r6, #U_EP0_STAGE]
    movs r0, #1
    str  r0, [r6, #U_EP0_PID]       ; the first packet after a setup packet is DATA1
    ldrb r0, [r4, #6]
    ldrb r1, [r4, #7]
    lsls r1, r1, #8
    orrs r0, r1
    str  r0, [r6, #U_WLENGTH]
    ldrb r0, [r4, #0]               ; bmRequestType
    ldrb r1, [r4, #1]               ; bRequest
    movs r2, #0x60
    ands r2, r0                     ; the type: 0x00 standard, 0x20 class
    cmp  r2, #0x20
    beq  ust_class
    cmp  r2, #0
    bne  ust_stall
    cmp  r1, #6
    bne  ust_1
    bl   u_get_descriptor
    b    ust_done
ust_1:
    cmp  r1, #5
    bne  ust_2
    bl   u_set_address
    b    ust_done
ust_2:
    cmp  r1, #9
    bne  ust_3
    bl   u_set_configuration
    b    ust_done
ust_3:
    cmp  r1, #8                     ; GET_CONFIGURATION: 1 byte
    bne  ust_4
    mov  r0, r6
    adds r0, #U_CONFIG
    movs r1, #1
    bl   u_ep0_in_data
    b    ust_done
ust_4:
    cmp  r1, #0                     ; GET_STATUS: 2 bytes 0
    bne  ust_5
    mov  r0, r6
    adds r0, #U_ZERO
    movs r1, #2
    bl   u_ep0_in_data
    b    ust_done
ust_5:
    cmp  r1, #10                    ; GET_INTERFACE: 1 byte 0
    bne  ust_6
    mov  r0, r6
    adds r0, #U_ZERO
    movs r1, #1
    bl   u_ep0_in_data
    b    ust_done
ust_6:
    cmp  r1, #1                     ; CLEAR_FEATURE, SET_FEATURE, SET_INTERFACE: done
    beq  ust_ack
    cmp  r1, #3
    beq  ust_ack
    cmp  r1, #11
    beq  ust_ack
    b    ust_stall
ust_class:
    cmp  r1, #0x20                  ; SET_LINE_CODING: 7 bytes come in the OUT data stage
    bne  ust_c1
    movs r0, #1
    str  r0, [r6, #U_EP0_OUT]
    bl   u_ep0_out_status
    b    ust_done
ust_c1:
    cmp  r1, #0x21                  ; GET_LINE_CODING
    bne  ust_c2
    mov  r0, r6
    adds r0, #U_LINE
    movs r1, #7
    bl   u_ep0_in_data
    b    ust_done
ust_c2:
    cmp  r1, #0x22                  ; SET_CONTROL_LINE_STATE: DTR, RTS
    bne  ust_c3
    bl   u_line_state
    b    ust_done
ust_c3:
    cmp  r1, #0x23                  ; SEND_BREAK
    beq  ust_ack
ust_stall:
    bl   u_ep0_stall
    b    ust_done
ust_ack:
    bl   u_ep0_status_in
ust_done:
    pop  {r4, pc}

; SET_ADDRESS: the address counts only after the status packet (u_ep0_in_done)
u_set_address:
    ldrb r0, [r4, #2]
    movs r1, #1
    lsls r1, r1, #8
    orrs r0, r1
    str  r0, [r6, #U_ADDR]
    b    u_ep0_status_in

; SET_CONFIGURATION: the endpoints on, EP2 OUT waits for the first packet
u_set_configuration:
    push {lr}
    ldrb r0, [r4, #2]
    str  r0, [r6, #U_CONFIG]
    cmp  r0, #0
    beq  usc_ack
    ldr  r0, usc_lit_ep1_in
    str  r0, [r4, #USB_EC_EP1_IN]
    ldr  r0, usc_lit_ep2_in
    str  r0, [r4, #USB_EC_EP2_IN]
    ldr  r0, usc_lit_ep2_out
    str  r0, [r4, #USB_EC_EP2_OUT]
    movs r0, #0
    str  r0, [r6, #U_IN_PID]        ; the bulk endpoints start with DATA0
    str  r0, [r6, #U_OUT_PID]
    str  r0, [r6, #U_IN_BUSY]
    str  r0, [r6, #U_RX_HOLD]
    bl   u_ep2_arm_out
usc_ack:
    bl   u_ep0_status_in
    pop  {pc}

    align 4
usc_lit_ep1_in:     dd (1 << 31) | (1 << 29) | (3 << 26) | 0x180    ; ENABLE, INTERRUPT_PER_BUFF, interrupt
usc_lit_ep2_in:     dd (1 << 31) | (1 << 29) | (2 << 26) | 0x200    ; bulk
usc_lit_ep2_out:    dd (1 << 31) | (1 << 29) | (2 << 26) | 0x1c0

; SET_CONTROL_LINE_STATE: bit 0 of wValue is DTR (a terminal has the port open). When it changes, what waited to go
; is dropped: it was for another terminal
u_line_state:
    ldrb r0, [r4, #2]
    movs r1, #1
    ands r0, r1
    ldr  r1, [r6, #U_DTR]
    str  r0, [r6, #U_DTR]
    cmp  r0, r1
    beq  uls_ack
    ldr  r0, [r6, #U_TX_HEAD]
    str  r0, [r6, #U_TX_TAIL]
uls_ack:
    b    u_ep0_status_in

; GET_DESCRIPTOR: wValue high byte the type (1 device, 2 configuration, 3 string), low byte the index
u_get_descriptor:
    push {lr}
    ldrb r2, [r4, #3]
    ldrb r3, [r4, #2]
    cmp  r2, #1
    bne  ugd_2
    adr  r0, u_desc_device
    movs r1, #18
    b    ugd_send
ugd_2:
    cmp  r2, #2
    bne  ugd_3
    adr  r0, u_desc_config
    movs r1, #75
    b    ugd_send
ugd_3:
    cmp  r2, #3                     ; anything else (device qualifier, ...): STALL
    bne  ugd_stall
    cmp  r3, #0
    bne  ugd_s1
    adr  r0, u_desc_lang
    b    ugd_str
ugd_s1:
    cmp  r3, #1
    bne  ugd_s2
    adr  r0, u_desc_maker
    b    ugd_str
ugd_s2:
    cmp  r3, #2
    bne  ugd_s3
    adr  r0, u_desc_product
    b    ugd_str
ugd_s3:
    cmp  r3, #3
    bne  ugd_stall
    ldr  r0, ugd_lit_serial
ugd_str:
    ldrb r1, [r0]                   ; a string descriptor: its first byte is its length
ugd_send:
    bl   u_ep0_in_data
    pop  {pc}
ugd_stall:
    bl   u_ep0_stall
    pop  {pc}

    align 4
ugd_lit_serial: dd USB_SERIAL

    align 4
u_desc_device:
    db 18, 1                        ; bLength, DEVICE
    db 0x00, 0x02                   ; USB 2.0 (full speed)
    db 0xef, 0x02, 0x01             ; class, subclass, protocol: "see the IAD" (a function of two interfaces)
    db 64                           ; EP0: 64 bytes
    db 0x09, 0x12                   ; idVendor 0x1209 (pid.codes)
    db 0x01, 0x00                   ; idProduct 0x0001 (the test number)
    db 0x00, 0x01                   ; bcdDevice 1.00
    db 1, 2, 3                      ; the strings: maker, product, serial number
    db 1                            ; one configuration

    align 4
u_desc_config:
    db 9, 2, 75, 0, 2, 1, 0, 0x80, 50   ; CONFIGURATION: 75 bytes in all, 2 interfaces, value 1, bus powered, 100 mA
    db 8, 0x0b, 0, 2, 2, 2, 0, 0        ; IAD: interfaces 0 and 1 are one function, CDC ACM
    db 9, 4, 0, 0, 1, 2, 2, 0, 0        ; INTERFACE 0: 1 endpoint, CDC, ACM
    db 5, 0x24, 0x00, 0x10, 0x01        ;   CDC header: CDC 1.10
    db 5, 0x24, 0x01, 0x00, 1           ;   call management: data interface 1
    db 4, 0x24, 0x02, 0x02              ;   ACM: SET/GET_LINE_CODING, SET_CONTROL_LINE_STATE
    db 5, 0x24, 0x06, 0, 1              ;   union: interface 0 controls interface 1
    db 7, 5, 0x81, 3, 8, 0, 16          ;   ENDPOINT 1 IN, interrupt, 8 bytes, every 16 ms
    db 9, 4, 1, 0, 2, 0x0a, 0, 0, 0     ; INTERFACE 1: 2 endpoints, CDC data
    db 7, 5, 0x02, 2, 64, 0, 0          ;   ENDPOINT 2 OUT, bulk, 64 bytes
    db 7, 5, 0x82, 2, 64, 0, 0          ;   ENDPOINT 2 IN, bulk, 64 bytes

    align 4
u_desc_lang:
    db 4, 3, 0x09, 0x04                 ; the languages: 0x0409 English (US)

    align 4
u_desc_maker:
    db 18, 3, 'A', 0, 's', 0, 'm', 0, 'o', 0, 'n', 0, 'i', 0, 't', 0, 'e', 0

    align 4
u_desc_product:
    db 34, 3, 'A', 0, 's', 0, 'm', 0, 'o', 0, 'n', 0, 'i', 0, 't', 0, 'e', 0
    db ' ', 0, 'c', 0, 'o', 0, 'n', 0, 's', 0, 'o', 0, 'l', 0, 'e', 0

    align 4
; (the serial number is made by u_make_serial in USB_SERIAL)

; ---------- the data (EP2) ----------

; EP2 OUT ready for the next packet
u_ep2_arm_out:
    push {lr}
    movs r1, #64
    ldr  r0, [r6, #U_OUT_PID]
    cmp  r0, #0
    beq  uao_pid0
    movs r2, #1
    lsls r2, r2, #13                ; DATA1
    orrs r1, r2
uao_pid0:
    movs r2, #1
    eors r0, r2
    str  r0, [r6, #U_OUT_PID]
    movs r0, #USB_BC_EP2_OUT
    bl   u_arm
    pop  {pc}

; a packet has come on EP2 OUT: into the ring (when it has room), EP2 OUT ready again
u_ep2_out_done:
    push {lr}
    ldr  r0, [r7, #USB_BC_EP2_OUT]
    movs r1, #1
    lsls r1, r1, #10
    subs r1, r1, #1                 ; 0x3ff: the length
    ands r0, r1
    str  r0, [r6, #U_RX_LEN]
    movs r0, #1
    str  r0, [r6, #U_RX_HOLD]
    bl   u_rx_take
    pop  {pc}

; the packet in the EP2 OUT buffer (U_RX_HOLD, U_RX_LEN) into the ring when it has room for all of it, then EP2 OUT
; ready for the next one. A Ctrl+C while a program runs does not go into the ring: U_CC (usb_irq stops the program)
u_rx_take:
    push {r4, lr}
    ldr  r0, [r6, #U_RX_HOLD]
    cmp  r0, #0
    beq  urt_end
    ldr  r1, [r6, #U_RX_HEAD]
    ldr  r2, [r6, #U_RX_TAIL]
    subs r3, r1, r2
    uxtb r3, r3                     ; the bytes in the ring
    ldr  r0, [r6, #U_RX_LEN]
    adds r3, r3, r0
    cmp  r3, #255
    bhi  urt_end                    ; no room yet (usb_getc tries again)
    ldr  r2, urt_lit_rxb
    ldr  r3, urt_lit_buf
urt_loop:
    cmp  r0, #0
    beq  urt_done
    ldrb r4, [r3]
    cmp  r4, #3
    bne  urt_put
    push {r0}
    ldr  r0, urt_lit_run
    ldr  r0, [r0]
    cmp  r0, #1                     ; (2: the program stands under the debug monitor, the byte is for its packets)
    pop  {r0}                       ; (pop leaves the flags)
    bne  urt_put
    str  r4, [r6, #U_CC]            ; a Ctrl+C for the program
    b    urt_next
urt_put:
    strb r4, [r2, r1]
    adds r1, #1
    uxtb r1, r1
urt_next:
    adds r3, #1
    subs r0, #1
    b    urt_loop
urt_done:
    str  r1, [r6, #U_RX_HEAD]
    movs r0, #0
    str  r0, [r6, #U_RX_HOLD]
    bl   u_ep2_arm_out
urt_end:
    pop  {r4, pc}

    align 4
urt_lit_rxb:    dd USB_RXB
urt_lit_buf:    dd USB_EP2_OUT_BUF
urt_lit_run:    dd VARS + V_RUN

; the next packet out of EP2 IN, from the ring: when the host is ready (configured, no packet on its way) and
; something waits
u_kick:
    push {r4, lr}
    ldr  r0, [r6, #U_CONFIG]
    cmp  r0, #0
    beq  uk_end
    ldr  r0, [r6, #U_IN_BUSY]
    cmp  r0, #0
    bne  uk_end
    ldr  r1, [r6, #U_TX_TAIL]
    ldr  r2, [r6, #U_TX_HEAD]
    cmp  r1, r2
    beq  uk_end
    ldr  r3, uk_lit_txb
    ldr  r4, uk_lit_buf
    movs r0, #0                     ; the bytes of the packet
uk_loop:
    ldr  r2, [r6, #U_TX_HEAD]
    cmp  r1, r2
    beq  uk_send
    cmp  r0, #64
    beq  uk_send
    ldrb r2, [r3, r1]
    strb r2, [r4, r0]
    adds r1, #1
    uxtb r1, r1
    adds r0, #1
    b    uk_loop
uk_send:
    str  r1, [r6, #U_TX_TAIL]
    mov  r1, r0
    bl   u_in_send
uk_end:
    pop  {r4, pc}

    align 4
uk_lit_txb:     dd USB_TXB
uk_lit_buf:     dd USB_EP2_IN_BUF

; the r1 bytes in the EP2 IN buffer out (0 .. 64)
u_in_send:
    push {r4, lr}
    mov  r4, r1
    str  r1, [r6, #U_IN_LEN]
    movs r1, #1
    lsls r1, r1, #15                ; FULL
    orrs r1, r4
    ldr  r0, [r6, #U_IN_PID]
    cmp  r0, #0
    beq  uis_pid0
    movs r2, #1
    lsls r2, r2, #13                ; DATA1
    orrs r1, r2
uis_pid0:
    movs r2, #1
    eors r0, r2
    str  r0, [r6, #U_IN_PID]
    movs r0, #1
    str  r0, [r6, #U_IN_BUSY]
    movs r0, #USB_BC_EP2_IN
    bl   u_arm
    pop  {r4, pc}

; EP2 IN has gone: a packet of 0 bytes after a full one with nothing behind it, else the next part of the ring
u_ep2_in_done:
    push {lr}
    movs r0, #0
    str  r0, [r6, #U_IN_BUSY]
    ldr  r0, [r6, #U_IN_LEN]
    cmp  r0, #64
    bne  uei2_kick
    ldr  r0, [r6, #U_TX_HEAD]
    ldr  r1, [r6, #U_TX_TAIL]
    cmp  r0, r1
    bne  uei2_kick
    movs r1, #0
    bl   u_in_send
    pop  {pc}
uei2_kick:
    bl   u_kick
    pop  {pc}

; the buffers that are done (BUFF_STATUS: bit 2n EPn IN, bit 2n+1 EPn OUT)
u_buffers:
    push {r4, lr}
    ldr  r4, [r5, #USB_BUFF_STATUS]
    str  r4, [r5, #USB_BUFF_STATUS] ; cleared (a 1 clears a bit)
    movs r0, #0x01
    tst  r4, r0
    beq  ub_1
    bl   u_ep0_in_done
ub_1:
    movs r0, #0x02
    tst  r4, r0
    beq  ub_2
    bl   u_ep0_out_done
ub_2:
    movs r0, #0x10
    tst  r4, r0
    beq  ub_3
    bl   u_ep2_in_done
ub_3:
    movs r0, #0x20
    tst  r4, r0
    beq  ub_4
    bl   u_ep2_out_done
ub_4:
    pop  {r4, pc}
