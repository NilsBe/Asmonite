; The debug monitor of the console of the Pico (RP2040, Cortex-M0+; included by console.asm): a program from the PC
; runs under the debugger over the console (packet T), over USB or the UART, without the debug probe. Thumb-1.
;
; The Cortex-M0+ has no exception DebugMonitor (boards\pico2\console_mon.asm takes it on the Pico 2): without a
; debugger over SWD a BKPT is a HardFault. So the breakpoints are BKPT instructions that Asmonite writes into the
; program (CmMonLink: only while it runs; a step is a BKPT at each place where the instruction can go on). The
; HardFault of a BKPT of a program under the monitor (fault: mon_fault) sets PendSV pending and returns: the core
; takes PendSV at once, with the frame of the program, and PendSV is the monitor (mon_handler). Its priority is the
; lowest (0xC0), under the interrupts of USB and UART0: so USB keeps going while the program stands, and the monitor
; reads its packets through the ring (V_RUN 2 while it stands). A Ctrl+C while the program runs sets PendSV too.
;
; T entry         -> k  the program that R put into the RAM starts under the monitor (it stops at its first BKPT:
;                       Asmonite puts one at the entry)
; then, while it stands:
;   h reason pc   <-    the monitor: the program stands (reason 1 a BKPT, 3 Ctrl+C)
;   r             -> d  r0 .. r12, sp, lr, pc, xpsr (17 words)
;   w 17 words    -> k  the registers (not sp)
;   m addr count  -> d  count bytes (up to 1024) of the memory at addr (whole words when both are multiples of 4)
;   v addr bytes  -> k  bytes into the memory (as m); m and v give e where nothing is
;   c             -> k  the program goes on (behind a BKPT that is still there: one of the program)
;   k             -> k  the program stops ("Program stopped", then x -1)
;   P             -> k  the version, as at the prompt
;   b, u, s       -> e  (the Pico has no breakpoints of its own for the monitor: Asmonite writes them)
; When the program ends (bx lr, exit, a fault, k) the console sends x and its code (a word) after its text.

MON_ICSR        equ 0xe000ed04          ; bit 28 PENDSVSET, bit 27 PENDSVCLR
MON_SHPR3       equ 0xe000ed20          ; bits 23 .. 16 the priority of PendSV (only word access)
MON_RAM_HI      equ 0x20042000          ; behind the RAM

; MONV to 0, PendSV (14) in the vector table to the monitor (main, T)
mon_init:
    ldr  r0, mon_init_monv
    movs r1, #0
    movs r2, #0
mi_clear:
    str  r1, [r0, r2]
    adds r2, #4
    cmp  r2, #64
    blt  mi_clear
    ldr  r0, mon_init_vtab
    ldr  r1, mon_init_handler
    str  r1, [r0, #14 * 4]
    bx   lr

    align 4
mon_init_monv:      dd MONV
mon_init_vtab:      dd VTAB
mon_init_handler:   dd mon_handler + RUN_OFFSET + 1

; T entry: the program that R put into the RAM starts under the monitor (k first); r0 2 (a program ran), or 0
pk_debug:
    push {r4, lr}
    bl   pk_len
    cmp  r0, #4
    bne  pt_bad
    ldr  r0, pk_debug_pkt
    ldr  r4, [r0, #4]
    ldr  r1, pk_debug_lo
    cmp  r4, r1
    blo  pt_bad
    ldr  r1, pk_debug_hi
    cmp  r4, r1
    bhs  pt_bad
    bl   send_ok
    bl   mon_init
    ldr  r0, pk_debug_monv
    movs r1, #1
    str  r1, [r0, #M_ON]
    ldr  r0, pk_debug_shpr3
    ldr  r1, [r0]
    ldr  r2, pk_debug_mask
    bics r1, r2
    ldr  r2, pk_debug_low
    orrs r1, r2
    str  r1, [r0]                   ; PendSV: the lowest priority
    ldr  r1, pk_debug_vars
    movs r0, #0
    str  r0, [r1, #V_QUIET]
    adds r1, #V_EMPTY
    mov  r0, r4
    bl   run_entry
    movs r0, #2
    pop  {r4, pc}
pt_bad:
    bl   send_err_inline
    db   'T: the entry, in the RAM of the programs', 0
    align 2
    movs r0, #0
    pop  {r4, pc}

    align 4
pk_debug_pkt:   dd PKT
pk_debug_lo:    dd PROG_LO
pk_debug_hi:    dd PROG_HI
pk_debug_monv:  dd MONV
pk_debug_shpr3: dd MON_SHPR3
pk_debug_mask:  dd 0xff << 16
pk_debug_low:   dd 0xc0 << 16
pk_debug_vars:  dd VARS

; the end of a program (prog_finish, prog_abort), r0 its code: after a T the monitor off and x with the code
mon_end:
    push {r4, lr}
    mov  r4, r0
    ldr  r0, mon_end_monv
    ldr  r1, [r0, #M_ON]
    cmp  r1, #0
    beq  me_done
    movs r1, #0
    str  r1, [r0, #M_ON]
    ldr  r0, mon_end_icsr
    ldr  r1, mon_end_clr
    str  r1, [r0]                   ; no PendSV that waits
    push {r4}
    movs r0, #'x'
    mov  r1, sp
    movs r2, #4
    bl   send_packet
    add  sp, #4
me_done:
    pop  {r4, pc}

    align 4
mon_end_monv:   dd MONV
mon_end_icsr:   dd MON_ICSR
mon_end_clr:    dd 1 << 27

; a Ctrl+C while a program runs (con_ctrl_c, uart_irq): under the monitor it stands (PendSV), r0 1; else r0 0
mon_ctrl_c:
    ldr  r0, mcc_monv
    ldr  r1, [r0, #M_ON]
    cmp  r1, #0
    beq  mcc_no
    movs r1, #1
    str  r1, [r0, #M_REQ]
    ldr  r0, mcc_icsr
    ldr  r1, mcc_set
    str  r1, [r0]
    movs r0, #1
    bx   lr
mcc_no:
    movs r0, #0
    bx   lr

    align 4
mcc_monv:       dd MONV
mcc_icsr:       dd MON_ICSR
mcc_set:        dd 1 << 28

; a fault (fault; r1 its frame, r7 its EXC_RETURN): r0 1 and back to the frame when it is one of the monitor:
;   - a read or write of m or v where nothing is (M_PROBE): to the place M_PROBE says
;   - a BKPT (0xBExx at the pc) of the program under the monitor, in thread mode: PendSV pending, the core takes it
;     when the fault returns (the monitor, with the frame of the program)
; else r0 0
mon_fault:
    ldr  r0, mf_monv
    ldr  r2, [r0, #M_PROBE]
    cmp  r2, #0
    beq  mf_bkpt
    movs r3, #0
    str  r3, [r0, #M_PROBE]
    str  r2, [r1, #24]
    movs r0, #1
    bx   lr
mf_bkpt:
    ldr  r2, [r0, #M_ON]
    cmp  r2, #0
    beq  mf_no
    ldr  r2, mf_vars
    ldr  r2, [r2, #V_RUN]
    cmp  r2, #1
    bne  mf_no
    mov  r2, r7
    lsls r2, r2, #28                ; EXC_RETURN bit 3: back to thread mode
    bpl  mf_no
    ldr  r2, [r1, #24]
    ldr  r3, mf_ram_lo
    cmp  r2, r3
    blo  mf_no
    ldr  r3, mf_ram_hi
    cmp  r2, r3
    bhs  mf_no
    ldrh r2, [r2]
    lsrs r2, r2, #8
    cmp  r2, #0xbe
    bne  mf_no
    ldr  r0, mf_icsr
    ldr  r2, mf_set
    str  r2, [r0]
    movs r0, #1
    bx   lr
mf_no:
    movs r0, #0
    bx   lr

    align 4
mf_monv:        dd MONV
mf_vars:        dd VARS
mf_ram_lo:      dd PROG_LO
mf_ram_hi:      dd MON_RAM_HI
mf_icsr:        dd MON_ICSR
mf_set:         dd 1 << 28

; PendSV: the frame (MSP or PSP, EXC_RETURN bit 2) and r4 .. r11 into MONV, the monitor, then the registers back
; (w may have changed them) and the program goes on
mon_handler:
    mov  r0, lr
    lsls r0, r0, #29
    bmi  mh_psp
    mrs  r0, msp
    b    mh_have
mh_psp:
    mrs  r0, psp
mh_have:
    ldr  r1, mh_monv
    str  r0, [r1, #M_FRAME]
    mov  r2, lr
    str  r2, [r1, #M_EXCRET]
    str  r4, [r1, #M_REGS]
    str  r5, [r1, #M_REGS + 4]
    str  r6, [r1, #M_REGS + 8]
    str  r7, [r1, #M_REGS + 12]
    mov  r2, r8
    str  r2, [r1, #M_REGS + 16]
    mov  r2, r9
    str  r2, [r1, #M_REGS + 20]
    mov  r2, r10
    str  r2, [r1, #M_REGS + 24]
    mov  r2, r11
    str  r2, [r1, #M_REGS + 28]
    bl   mon_stop
    ldr  r1, mh_monv2
    ldr  r2, [r1, #M_REGS + 16]
    mov  r8, r2
    ldr  r2, [r1, #M_REGS + 20]
    mov  r9, r2
    ldr  r2, [r1, #M_REGS + 24]
    mov  r10, r2
    ldr  r2, [r1, #M_REGS + 28]
    mov  r11, r2
    ldr  r4, [r1, #M_REGS]
    ldr  r5, [r1, #M_REGS + 4]
    ldr  r6, [r1, #M_REGS + 8]
    ldr  r7, [r1, #M_REGS + 12]
    ldr  r0, [r1, #M_EXCRET]
    bx   r0

    align 4
mh_monv:        dd MONV
mh_monv2:       dd MONV

; the program stands: why (M_REQ), h, then the packets until c or k
mon_stop:
    push {r4, lr}
    ldr  r4, ms_monv
    ldr  r0, ms_vars
    movs r1, #2
    str  r1, [r0, #V_RUN]           ; the bytes into the rings (the packets), a Ctrl+C too
    bl   irq_off                    ; UART0: its bytes for the packets, not for the ring of the program
    movs r0, #1                     ; a BKPT
    ldr  r1, [r4, #M_REQ]
    cmp  r1, #0
    beq  ms_send
    movs r1, #0
    str  r1, [r4, #M_REQ]
    movs r0, #3                     ; Ctrl+C
ms_send:
    bl   mon_send_stop
ms_loop:
    movs r0, #0
    bl   read_packet
    cmp  r0, #1
    beq  ms_loop                    ; a second without a packet: it waits on
    cmp  r0, #0
    beq  ms_do
    bl   send_err_inline
    db   'The packet was damaged.', 0
    align 2
    b    ms_loop
ms_do:
    bl   mon_packet
    cmp  r0, #0
    beq  ms_loop
    ldr  r0, ms_vars2
    movs r1, #1
    str  r1, [r0, #V_RUN]
    bl   irq_on
    pop  {r4, pc}

    align 4
ms_monv:        dd MONV
ms_vars:        dd VARS
ms_vars2:       dd VARS

; h: the reason r0 and the pc
mon_send_stop:
    push {lr}
    ldr  r1, mss_pagebuf
    str  r0, [r1]
    ldr  r2, mss_monv
    ldr  r2, [r2, #M_FRAME]
    ldr  r2, [r2, #24]
    str  r2, [r1, #4]
    movs r0, #'h'
    movs r2, #8
    bl   send_packet
    pop  {pc}

    align 4
mss_pagebuf:    dd PAGEBUF
mss_monv:       dd MONV

; the packet in PKT while the program stands; r0 1 when it goes on (c, k), else 0
mon_packet:
    push {r4, lr}
    ldr  r4, mp_pkt
    ldrb r0, [r4, #1]
    cmp  r0, #'r'
    beq  mp_r
    cmp  r0, #'w'
    beq  mp_w
    cmp  r0, #'m'
    beq  mp_m
    cmp  r0, #'v'
    beq  mp_v
    cmp  r0, #'c'
    beq  mp_c
    cmp  r0, #'k'
    beq  mp_k
    cmp  r0, #'P'
    beq  mp_p
    cmp  r0, #'b'
    beq  mp_none
    cmp  r0, #'u'
    beq  mp_none
    cmp  r0, #'s'
    beq  mp_none
    bl   send_err_inline
    db   'Unknown packet.', 0
    align 2
    b    mp_stay
mp_none:
    bl   send_err_inline
    db   'not on the Pico: Asmonite writes the breakpoints and the steps (BKPT)', 0
    align 2
    b    mp_stay
mp_r:
    bl   mon_regs
    b    mp_stay
mp_w:
    bl   mon_set_regs
    b    mp_stay
mp_m:
    bl   mon_read
    b    mp_stay
mp_v:
    bl   mon_write
    b    mp_stay
mp_p:
    bl   pk_ping
    b    mp_stay
mp_c:
    bl   send_ok
    bl   mon_skip_bkpt
    b    mp_go
mp_k:
    bl   send_ok
    bl   print_inline
    db   13, 10, 'Program stopped.', 13, 10, 0
    align 2
    ldr  r0, mp_monv
    ldr  r1, [r0, #M_FRAME]
    ldr  r0, mp_abort
    str  r0, [r1, #24]
    movs r0, #1
    lsls r0, r0, #24                ; xPSR: only the Thumb bit
    str  r0, [r1, #28]
mp_go:
    movs r0, #1
    pop  {r4, pc}
mp_stay:
    movs r0, #0
    pop  {r4, pc}

    align 4
mp_pkt:         dd PKT
mp_monv:        dd MONV
mp_abort:       dd prog_abort + RUN_OFFSET

; the program stands on a BKPT (0xBExx; one of its own: Asmonite takes its own out at each stop): its pc behind it
mon_skip_bkpt:
    ldr  r0, msb_monv
    ldr  r0, [r0, #M_FRAME]
    ldr  r1, [r0, #24]
    ldrh r2, [r1]
    lsrs r2, r2, #8
    cmp  r2, #0xbe
    bne  msb_end
    adds r1, #2
    str  r1, [r0, #24]
msb_end:
    bx   lr

    align 4
msb_monv:       dd MONV

; the size of the frame in r0: 32 bytes, 4 more when the core aligned the stack (bit 9 of the xPSR in the frame)
mon_frame_size:
    ldr  r1, mfs_monv
    ldr  r1, [r1, #M_FRAME]
    ldr  r1, [r1, #28]
    movs r0, #32
    lsls r1, r1, #22                ; bit 9 into N
    bpl  mfs_end
    adds r0, #4
mfs_end:
    bx   lr

    align 4
mfs_monv:       dd MONV

; r: d with r0 .. r12, sp, lr, pc, xpsr
mon_regs:
    push {r4, r5, r6, lr}
    ldr  r4, mr_monv
    ldr  r5, [r4, #M_FRAME]
    ldr  r6, mr_pagebuf
    movs r2, #0
mr_low:
    ldr  r0, [r5, r2]
    str  r0, [r6, r2]               ; r0 .. r3
    adds r2, #4
    cmp  r2, #16
    blt  mr_low
    movs r2, #0
mr_high:
    adds r0, r4, r2
    ldr  r0, [r0, #M_REGS]
    adds r1, r6, r2
    str  r0, [r1, #16]              ; r4 .. r11
    adds r2, #4
    cmp  r2, #32
    blt  mr_high
    ldr  r0, [r5, #16]
    str  r0, [r6, #48]              ; r12
    bl   mon_frame_size
    adds r0, r0, r5
    str  r0, [r6, #52]              ; sp: above the frame
    ldr  r0, [r5, #20]
    str  r0, [r6, #56]              ; lr
    ldr  r0, [r5, #24]
    str  r0, [r6, #60]              ; pc
    ldr  r0, [r5, #28]
    str  r0, [r6, #64]              ; xpsr
    movs r0, #'d'
    mov  r1, r6
    movs r2, #68
    bl   send_packet
    pop  {r4, r5, r6, pc}

    align 4
mr_monv:        dd MONV
mr_pagebuf:     dd PAGEBUF

; w: the registers (17 words as r gives them; sp stays)
mon_set_regs:
    push {r4, r5, r6, lr}
    bl   pk_len
    cmp  r0, #68
    bne  msr_bad
    ldr  r4, msr_monv
    ldr  r5, [r4, #M_FRAME]
    ldr  r6, msr_pkt
    adds r6, #4
    movs r2, #0
msr_low:
    ldr  r0, [r6, r2]
    str  r0, [r5, r2]
    adds r2, #4
    cmp  r2, #16
    blt  msr_low
    movs r2, #0
msr_high:
    adds r0, r6, r2
    ldr  r0, [r0, #16]
    adds r1, r4, r2
    str  r0, [r1, #M_REGS]
    adds r2, #4
    cmp  r2, #32
    blt  msr_high
    ldr  r0, [r6, #48]
    str  r0, [r5, #16]              ; r12
    ldr  r0, [r6, #56]
    str  r0, [r5, #20]              ; lr
    ldr  r0, [r6, #60]
    movs r1, #1
    bics r0, r1
    str  r0, [r5, #24]              ; pc
    ldr  r0, [r6, #64]
    lsls r1, r1, #24
    orrs r0, r1
    str  r0, [r5, #28]              ; xpsr, with the Thumb bit
    bl   send_ok
    pop  {r4, r5, r6, pc}
msr_bad:
    bl   send_err_inline
    db   'w: 17 words', 0
    align 2
    pop  {r4, r5, r6, pc}

    align 4
msr_monv:       dd MONV
msr_pkt:        dd PKT

; m addr count: d with the bytes
mon_read:
    push {r4, r5, r6, lr}
    bl   pk_len
    cmp  r0, #8
    bne  mrd_bad
    ldr  r0, mrd_pkt
    ldr  r4, [r0, #4]               ; the address
    ldr  r5, [r0, #8]               ; the count
    ldr  r1, mrd_max
    cmp  r5, r1
    bhi  mrd_bad
    ldr  r6, mrd_pagebuf
    ldr  r0, mrd_monv
    adr  r1, mrd_fault
    str  r1, [r0, #M_PROBE]
    movs r2, #0
    mov  r0, r4
    orrs r0, r5
    lsls r0, r0, #30                ; both multiples of 4?
    bne  mrd_bytes
mrd_word:
    cmp  r2, r5
    bhs  mrd_done
    ldr  r0, [r4, r2]
    str  r0, [r6, r2]
    adds r2, #4
    b    mrd_word
mrd_bytes:
    cmp  r2, r5
    bhs  mrd_done
    ldrb r0, [r4, r2]
    strb r0, [r6, r2]
    adds r2, #1
    b    mrd_bytes
mrd_done:
    dsb
    ldr  r0, mrd_monv
    movs r1, #0
    str  r1, [r0, #M_PROBE]
    movs r0, #'d'
    mov  r1, r6
    mov  r2, r5
    bl   send_packet
    pop  {r4, r5, r6, pc}
mrd_bad:
    bl   send_err_inline
    db   'm: an address and a count up to 1024', 0
    align 2
    pop  {r4, r5, r6, pc}
    align 4
mrd_fault:
    bl   send_err_inline
    db   'no memory at this address', 0
    align 2
    pop  {r4, r5, r6, pc}

    align 4
mrd_pkt:        dd PKT
mrd_max:        dd 1024
mrd_pagebuf:    dd PAGEBUF
mrd_monv:       dd MONV

; v addr bytes: into the memory
mon_write:
    push {r4, r5, r6, lr}
    bl   pk_len
    subs r5, r0, #4                 ; the bytes
    blt  mwr_bad
    ldr  r1, mwr_max
    cmp  r5, r1
    bhi  mwr_bad
    ldr  r6, mwr_pkt
    ldr  r4, [r6, #4]               ; the address
    adds r6, #8
    ldr  r0, mwr_monv
    adr  r1, mwr_fault
    str  r1, [r0, #M_PROBE]
    movs r2, #0
    mov  r0, r4
    orrs r0, r5
    lsls r0, r0, #30
    bne  mwr_bytes
mwr_word:
    cmp  r2, r5
    bhs  mwr_done
    ldr  r0, [r6, r2]
    str  r0, [r4, r2]
    adds r2, #4
    b    mwr_word
mwr_bytes:
    cmp  r2, r5
    bhs  mwr_done
    ldrb r0, [r6, r2]
    strb r0, [r4, r2]
    adds r2, #1
    b    mwr_bytes
mwr_done:
    dsb                             ; a fault of the writes comes before M_PROBE is 0
    isb
    ldr  r0, mwr_monv
    movs r1, #0
    str  r1, [r0, #M_PROBE]
    bl   send_ok
    pop  {r4, r5, r6, pc}
mwr_bad:
    bl   send_err_inline
    db   'v: an address and up to 1024 bytes', 0
    align 2
    pop  {r4, r5, r6, pc}
    align 4
mwr_fault:
    bl   send_err_inline
    db   'no memory at this address', 0
    align 2
    pop  {r4, r5, r6, pc}

    align 4
mwr_pkt:        dd PKT
mwr_max:        dd 1024
mwr_monv:       dd MONV
