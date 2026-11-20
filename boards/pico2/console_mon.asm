; The debug monitor of the console of the Pico 2 (included by console.asm): a program from the PC runs under the
; debugger over the console (packet T), over USB or the UART, without the debug probe.
;
; The Cortex-M33 has the exception DebugMonitor (12) for a debugger in the chip itself: while no debugger halts the
; core over SWD (DHCSR.C_DEBUGEN 0), DEMCR.MON_EN sends the breakpoints of the FPB (8 comparators, any address) and
; the steps (DEMCR.MON_STEP: one instruction, then the exception again) there. Its priority is 0x80, under the
; interrupts of UART0 and USB (0): so USB keeps going while the program stands, and the monitor reads its packets
; through the ring as at the prompt (V_RUN 2 while it stands: the bytes go into the ring, a Ctrl+C too).
;
; T entry         -> k  the program that R put into the RAM starts under the monitor; it stands at its entry
;                       (FP_COMP7), the monitor says h. e while a debugger holds the core over SWD (the probe)
; then, while it stands:
;   h reason pc   <-    the monitor: the program stands (reason 1 a breakpoint, 2 a step, 3 Ctrl+C)
;   r             -> d  r0 .. r12, sp, lr, pc, xpsr (17 words)
;   w 17 words    -> k  the registers (not sp)
;   m addr count  -> d  count bytes (up to 1024) of the memory at addr (whole words when both are multiples of 4)
;   v addr bytes  -> k  bytes into the memory (as m); m and v give e where nothing is
;   b addr        -> k  a breakpoint (FP_COMP0 .. 6: e when all 7 are in use)
;   u addr        -> k  the breakpoint off
;   c             -> k  the program goes on (from a breakpoint: one step without the breakpoints first)
;   s             -> k  one instruction, then h
;   k             -> k  the program stops ("Program stopped", then x -1)
;   P             -> k  the version, as at the prompt
; While it runs, Ctrl+C (0x03) stops it at the next instruction (h, reason 3) instead of ending it. When it ends (bx
; lr, exit, a fault, k) the console sends x and its code (a word) after its text, then the prompt.
;
; A step in which an interrupt came first does not move the program: the monitor steps again (up to 16 times).
; A BKPT instruction stops the program too (reason 1); c and s go on behind it.

MON_DHCSR       equ 0xe000edf0          ; bit 0 C_DEBUGEN: a debugger over SWD has the core (then no monitor)
MON_DFSR        equ 0xe000ed30
MON_DEMCR       equ 0xe000edfc
MON_SHPR3       equ 0xe000ed20          ; its byte 0: the priority of DebugMonitor
MON_FPB         equ 0xe0002000          ; FP_CTRL; +8 FP_COMP0 .. +0x24 FP_COMP7 (the address | 1)
MON_BPS         equ 7                   ; FP_COMP0 .. 6 for the breakpoints of the PC, FP_COMP7 for the entry

; MONV to 0 (main)
mon_init:
    movw r0, #(MONV & 0xffff)
    movt r0, #(MONV >> 16)
    movs r1, #0
    movs r2, #0
mi_clear:
    str  r1, [r0, r2]
    adds r2, r2, #4
    cmp  r2, #64
    blt  mi_clear
    bx   lr

; all comparators off, the FPB off (KEY)
mon_fpb_clear:
    movw r0, #(MON_FPB & 0xffff)
    movt r0, #(MON_FPB >> 16)
    movs r1, #0
    movs r2, #8
mfc_next:
    str  r1, [r0, r2]
    adds r2, r2, #4
    cmp  r2, #0x28
    blt  mfc_next
    movs r1, #2
    str  r1, [r0]
    bx   lr

; T entry: the program that R put into the RAM starts under the monitor (k first); r0 2 (a program ran), or 0
pk_debug:
    push {r4, lr}
    bl   pk_len
    cmp  r0, #4
    bne  pt_bad
    movw r0, #((PKT + 4) & 0xffff)
    movt r0, #((PKT + 4) >> 16)
    ldr  r4, [r0]
    movw r1, #(PROG_LO & 0xffff)
    movt r1, #(PROG_LO >> 16)
    cmp  r4, r1
    blo  pt_bad
    movw r1, #(PROG_HI & 0xffff)
    movt r1, #(PROG_HI >> 16)
    cmp  r4, r1
    bhs  pt_bad
    movw r0, #(MON_DHCSR & 0xffff)
    movt r0, #(MON_DHCSR >> 16)
    ldr  r0, [r0]
    tst  r0, #1                     ; C_DEBUGEN: a debugger over SWD would halt the core at the breakpoints
    bne  pt_held
    bl   send_ok
    bl   mon_init
    movw r0, #(MONV & 0xffff)
    movt r0, #(MONV >> 16)
    movs r1, #1
    str  r1, [r0, #M_ON]
    bl   mon_fpb_clear
    movw r0, #(MON_FPB & 0xffff)
    movt r0, #(MON_FPB >> 16)
    orr  r1, r4, #1
    str  r1, [r0, #0x24]            ; FP_COMP7: the entry
    movs r1, #3
    str  r1, [r0]                   ; KEY, ENABLE
    movw r0, #(MON_SHPR3 & 0xffff)
    movt r0, #(MON_SHPR3 >> 16)
    movs r1, #0x80
    strb r1, [r0]
    movw r0, #(MON_DEMCR & 0xffff)
    movt r0, #(MON_DEMCR >> 16)
    ldr  r1, [r0]
    movw r2, #0
    movt r2, #1                     ; MON_EN
    orrs r1, r2
    str  r1, [r0]
    dsb
    isb
    movw r1, #(VARS & 0xffff)
    movt r1, #(VARS >> 16)
    movs r0, #0
    str  r0, [r1, #V_QUIET]
    add  r1, r1, #V_EMPTY
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
pt_held:
    bl   send_err_inline
    db   'a debugger holds the core over SWD (DHCSR.C_DEBUGEN): no monitor then', 0
    align 2
    movs r0, #0
    pop  {r4, pc}

; the end of a program (prog_finish, prog_abort), r0 its code: after a T the monitor off and x with the code
mon_end:
    push {r4, lr}
    mov  r4, r0
    movw r0, #(MONV & 0xffff)
    movt r0, #(MONV >> 16)
    ldr  r1, [r0, #M_ON]
    cmp  r1, #0
    beq  me_done
    movs r1, #0
    str  r1, [r0, #M_ON]
    movw r0, #(MON_DEMCR & 0xffff)
    movt r0, #(MON_DEMCR >> 16)
    ldr  r1, [r0]
    movw r2, #0
    movt r2, #7                     ; MON_EN, MON_PEND, MON_STEP
    bics r1, r2
    str  r1, [r0]
    bl   mon_fpb_clear
    push {r4}
    movs r0, #'x'
    mov  r1, sp
    movs r2, #4
    bl   send_packet
    add  sp, sp, #4
me_done:
    pop  {r4, pc}

; a Ctrl+C while a program runs (con_ctrl_c, uart_irq): under the monitor it stops at its next instruction (MON_PEND),
; r0 1; else r0 0 (the program ends)
mon_ctrl_c:
    movw r0, #(MONV & 0xffff)
    movt r0, #(MONV >> 16)
    ldr  r1, [r0, #M_ON]
    cmp  r1, #0
    beq  mcc_no
    movs r1, #1
    str  r1, [r0, #M_REQ]
    movw r0, #(MON_DEMCR & 0xffff)
    movt r0, #(MON_DEMCR >> 16)
    ldr  r1, [r0]
    movw r2, #0
    movt r2, #2                     ; MON_PEND
    orrs r1, r2
    str  r1, [r0]
    movs r0, #1
    bx   lr
mcc_no:
    movs r0, #0
    bx   lr

; a fault (fault): in a read or write of m or v (M_PROBE) it returns to the place M_PROBE says; r0 1 then, else 0.
; r1 the frame of the fault
mon_fault:
    movw r0, #(MONV & 0xffff)
    movt r0, #(MONV >> 16)
    ldr  r2, [r0, #M_PROBE]
    cmp  r2, #0
    beq  mf_no
    movs r3, #0
    str  r3, [r0, #M_PROBE]
    str  r2, [r1, #24]
    movw r0, #(SCB_CFSR & 0xffff)
    movt r0, #(SCB_CFSR >> 16)
    ldr  r3, [r0]
    str  r3, [r0]
    movs r0, #1
    bx   lr
mf_no:
    movs r0, #0
    bx   lr

; the exception DebugMonitor: the frame (MSP or PSP, EXC_RETURN bit 2) and r4 .. r11 into MONV, the monitor, then
; the registers back (w may have changed them) and the program goes on
mon_handler:
    mov  r0, lr
    lsls r0, r0, #29
    bmi  mh_psp
    mrs  r0, msp
    b    mh_have
mh_psp:
    mrs  r0, psp
mh_have:
    movw r1, #(MONV & 0xffff)
    movt r1, #(MONV >> 16)
    str  r0, [r1, #M_FRAME]
    str  lr, [r1, #M_EXCRET]
    str  r4, [r1, #M_REGS]
    str  r5, [r1, #M_REGS + 4]
    str  r6, [r1, #M_REGS + 8]
    str  r7, [r1, #M_REGS + 12]
    str  r8, [r1, #M_REGS + 16]
    str  r9, [r1, #M_REGS + 20]
    str  r10, [r1, #M_REGS + 24]
    str  r11, [r1, #M_REGS + 28]
    bl   mon_stop
    movw r1, #(MONV & 0xffff)
    movt r1, #(MONV >> 16)
    ldr  r4, [r1, #M_REGS]
    ldr  r5, [r1, #M_REGS + 4]
    ldr  r6, [r1, #M_REGS + 8]
    ldr  r7, [r1, #M_REGS + 12]
    ldr  r8, [r1, #M_REGS + 16]
    ldr  r9, [r1, #M_REGS + 20]
    ldr  r10, [r1, #M_REGS + 24]
    ldr  r11, [r1, #M_REGS + 28]
    ldr  r0, [r1, #M_EXCRET]
    bx   r0

; the program stands: why (DFSR, M_REQ, a step of ours), h, then the packets until c, s or k
mon_stop:
    push {r4, r5, r6, r7, lr}
    movw r4, #(MONV & 0xffff)
    movt r4, #(MONV >> 16)
    ldr  r5, [r4, #M_FRAME]
    movw r0, #(VARS & 0xffff)
    movt r0, #(VARS >> 16)
    movs r1, #2
    str  r1, [r0, #V_RUN]           ; the bytes into the rings (the packets), a Ctrl+C too
    bl   irq_off                    ; UART0: its bytes for the packets, not for the ring of the program
    movw r0, #(MON_DFSR & 0xffff)
    movt r0, #(MON_DFSR >> 16)
    ldr  r6, [r0]
    str  r6, [r0]                   ; its bits cleared (write 1)
    movw r0, #(MON_DEMCR & 0xffff)
    movt r0, #(MON_DEMCR >> 16)
    ldr  r1, [r0]
    movw r2, #0
    movt r2, #6                     ; MON_PEND, MON_STEP
    bics r1, r2
    str  r1, [r0]
    movw r0, #(MON_FPB & 0xffff)
    movt r0, #(MON_FPB >> 16)
    movs r1, #0
    str  r1, [r0, #0x24]            ; FP_COMP7 (the entry) off
    movs r1, #3
    str  r1, [r0]                   ; the breakpoints on again (a step had them off)
    ldr  r7, [r4, #M_RESUME]
    movs r0, #0
    str  r0, [r4, #M_RESUME]
    ldr  r0, [r4, #M_REQ]
    cmp  r0, #0
    bne  ms_req
    cmp  r7, #0
    beq  ms_reason
    ; after a step of ours: did the program move? (an interrupt may have come first)
    ldr  r0, [r5, #24]
    ldr  r1, [r4, #M_LASTPC]
    cmp  r0, r1
    bne  ms_moved
    ldr  r1, [r4, #M_STEPS]
    adds r1, r1, #1
    str  r1, [r4, #M_STEPS]
    cmp  r1, #16
    bhs  ms_moved
    mov  r0, r7
    bl   mon_step_on
    b    ms_go
ms_moved:
    cmp  r7, #1
    beq  ms_go                      ; over the breakpoint: the program goes on
    movs r0, #2
    b    ms_send
ms_reason:
    movs r0, #1                     ; a breakpoint (FPB or BKPT)
    tst  r6, #2
    bne  ms_send
    movs r0, #2
    b    ms_send
ms_req:
    movs r0, #0
    str  r0, [r4, #M_REQ]
    movs r0, #3
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
ms_go:
    movw r0, #(VARS & 0xffff)
    movt r0, #(VARS >> 16)
    movs r1, #1
    str  r1, [r0, #V_RUN]
    bl   irq_on
    pop  {r4, r5, r6, r7, pc}

; one step (r0: M_RESUME, 1 over a breakpoint and on, 2 for the PC): the breakpoints off, MON_STEP
mon_step_on:
    movw r1, #(MONV & 0xffff)
    movt r1, #(MONV >> 16)
    str  r0, [r1, #M_RESUME]
    movw r1, #(MON_FPB & 0xffff)
    movt r1, #(MON_FPB >> 16)
    movs r0, #2
    str  r0, [r1]
    movw r1, #(MON_DEMCR & 0xffff)
    movt r1, #(MON_DEMCR >> 16)
    ldr  r0, [r1]
    movw r2, #0
    movt r2, #4                     ; MON_STEP
    orrs r0, r2
    str  r0, [r1]
    bx   lr

; h: the reason r0 and the pc
mon_send_stop:
    push {lr}
    movw r1, #(PAGEBUF & 0xffff)
    movt r1, #(PAGEBUF >> 16)
    str  r0, [r1]
    movw r2, #(MONV & 0xffff)
    movt r2, #(MONV >> 16)
    ldr  r2, [r2, #M_FRAME]
    ldr  r2, [r2, #24]
    str  r2, [r1, #4]
    movs r0, #'h'
    movs r2, #8
    bl   send_packet
    pop  {pc}

; the packet in PKT while the program stands; r0 1 when it goes on (c, s, k), else 0
mon_packet:
    push {r4, lr}
    movw r4, #(PKT & 0xffff)
    movt r4, #(PKT >> 16)
    ldrb r0, [r4, #1]
    cmp  r0, #'r'
    beq  mp_r
    cmp  r0, #'w'
    beq  mp_w
    cmp  r0, #'m'
    beq  mp_m
    cmp  r0, #'v'
    beq  mp_v
    cmp  r0, #'b'
    beq  mp_b
    cmp  r0, #'u'
    beq  mp_u
    cmp  r0, #'c'
    beq  mp_c
    cmp  r0, #'s'
    beq  mp_s
    cmp  r0, #'k'
    beq  mp_k
    cmp  r0, #'P'
    beq  mp_p
    bl   send_err_inline
    db   'Unknown packet.', 0
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
mp_b:
    bl   mon_bp_set
    b    mp_stay
mp_u:
    bl   mon_bp_clear
    b    mp_stay
mp_p:
    bl   pk_ping
    b    mp_stay
mp_c:
    bl   send_ok
    bl   mon_skip_bkpt
    bl   mon_frame_pc
    bl   mon_bp_at
    cmp  r0, #0
    beq  mp_go
    bl   mon_frame_pc
    bl   mon_last_pc
    movs r0, #1
    bl   mon_step_on
    b    mp_go
mp_s:
    bl   send_ok
    bl   mon_skip_bkpt
    bl   mon_frame_pc
    bl   mon_last_pc
    movs r0, #2
    bl   mon_step_on
    b    mp_go
mp_k:
    bl   send_ok
    bl   print_inline
    db   13, 10, 'Program stopped.', 13, 10, 0
    align 2
    movw r0, #(MONV & 0xffff)
    movt r0, #(MONV >> 16)
    ldr  r1, [r0, #M_FRAME]
    ldr  r0, mp_lit_abort
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
mp_lit_abort:   dd prog_abort + RUN_OFFSET

; the pc of the frame in r0
mon_frame_pc:
    movw r0, #(MONV & 0xffff)
    movt r0, #(MONV >> 16)
    ldr  r0, [r0, #M_FRAME]
    ldr  r0, [r0, #24]
    bx   lr

; r0 as the pc before a step (M_LASTPC), M_STEPS 0
mon_last_pc:
    movw r1, #(MONV & 0xffff)
    movt r1, #(MONV >> 16)
    str  r0, [r1, #M_LASTPC]
    movs r0, #0
    str  r0, [r1, #M_STEPS]
    bx   lr

; the program stands on a BKPT (0xBExx): its pc behind it
mon_skip_bkpt:
    movw r0, #(MONV & 0xffff)
    movt r0, #(MONV >> 16)
    ldr  r0, [r0, #M_FRAME]
    ldr  r1, [r0, #24]
    ldrh r2, [r1]
    lsrs r2, r2, #8
    cmp  r2, #0xbe
    bne  msb_end
    adds r1, r1, #2
    str  r1, [r0, #24]
msb_end:
    bx   lr

; r0 1 when a breakpoint (FP_COMP0 .. 6) is at the address r0, else 0
mon_bp_at:
    orr  r1, r0, #1
    movw r2, #(MON_FPB & 0xffff)
    movt r2, #(MON_FPB >> 16)
    movs r3, #0
mba_next:
    lsls r0, r3, #2
    add  r0, r0, r2
    ldr  r0, [r0, #8]
    cmp  r0, r1
    beq  mba_yes
    adds r3, r3, #1
    cmp  r3, #MON_BPS
    blt  mba_next
    movs r0, #0
    bx   lr
mba_yes:
    movs r0, #1
    bx   lr

; the size of the frame in r0: 32 bytes, 104 with the registers of the FPU (EXC_RETURN bit 4 0), 4 more when the core
; aligned the stack (bit 9 of the xPSR in the frame)
mon_frame_size:
    movw r2, #(MONV & 0xffff)
    movt r2, #(MONV >> 16)
    movs r0, #32
    ldr  r1, [r2, #M_EXCRET]
    tst  r1, #0x10
    bne  mfs_basic
    movs r0, #104
mfs_basic:
    ldr  r1, [r2, #M_FRAME]
    ldr  r1, [r1, #28]
    tst  r1, #0x200
    beq  mfs_end
    adds r0, r0, #4
mfs_end:
    bx   lr

; r: d with r0 .. r12, sp, lr, pc, xpsr
mon_regs:
    push {r4, r5, r6, lr}
    movw r4, #(MONV & 0xffff)
    movt r4, #(MONV >> 16)
    ldr  r5, [r4, #M_FRAME]
    movw r6, #(PAGEBUF & 0xffff)
    movt r6, #(PAGEBUF >> 16)
    movs r2, #0
mr_low:
    ldr  r0, [r5, r2]
    str  r0, [r6, r2]               ; r0 .. r3
    adds r2, r2, #4
    cmp  r2, #16
    blt  mr_low
    movs r2, #0
mr_high:
    add  r0, r4, r2
    ldr  r0, [r0, #M_REGS]
    add  r1, r6, r2
    str  r0, [r1, #16]              ; r4 .. r11
    adds r2, r2, #4
    cmp  r2, #32
    blt  mr_high
    ldr  r0, [r5, #16]
    str  r0, [r6, #48]              ; r12
    bl   mon_frame_size
    add  r0, r0, r5
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

; w: the registers (17 words as r gives them; sp stays)
mon_set_regs:
    push {r4, r5, r6, lr}
    bl   pk_len
    cmp  r0, #68
    bne  msr_bad
    movw r4, #(MONV & 0xffff)
    movt r4, #(MONV >> 16)
    ldr  r5, [r4, #M_FRAME]
    movw r6, #((PKT + 4) & 0xffff)
    movt r6, #((PKT + 4) >> 16)
    movs r2, #0
msr_low:
    ldr  r0, [r6, r2]
    str  r0, [r5, r2]
    adds r2, r2, #4
    cmp  r2, #16
    blt  msr_low
    movs r2, #0
msr_high:
    add  r0, r6, r2
    ldr  r0, [r0, #16]
    add  r1, r4, r2
    str  r0, [r1, #M_REGS]
    adds r2, r2, #4
    cmp  r2, #32
    blt  msr_high
    ldr  r0, [r6, #48]
    str  r0, [r5, #16]              ; r12
    ldr  r0, [r6, #56]
    str  r0, [r5, #20]              ; lr
    ldr  r0, [r6, #60]
    bic  r0, r0, #1
    str  r0, [r5, #24]              ; pc
    ldr  r0, [r6, #64]
    orr  r0, r0, #0x1000000
    str  r0, [r5, #28]              ; xpsr, with the Thumb bit
    bl   send_ok
    pop  {r4, r5, r6, pc}
msr_bad:
    bl   send_err_inline
    db   'w: 17 words', 0
    align 2
    pop  {r4, r5, r6, pc}

; m addr count: d with the bytes
mon_read:
    push {r4, r5, r6, lr}
    bl   pk_len
    cmp  r0, #8
    bne  mrd_bad
    movw r0, #((PKT + 4) & 0xffff)
    movt r0, #((PKT + 4) >> 16)
    ldr  r4, [r0]                   ; the address
    ldr  r5, [r0, #4]               ; the count
    movw r1, #1024
    cmp  r5, r1
    bhi  mrd_bad
    movw r6, #(PAGEBUF & 0xffff)
    movt r6, #(PAGEBUF >> 16)
    movw r0, #(MONV & 0xffff)
    movt r0, #(MONV >> 16)
    adr  r1, mrd_fault
    str  r1, [r0, #M_PROBE]
    orr  r0, r4, r5
    movs r2, #0
    tst  r0, #3
    bne  mrd_bytes
mrd_word:
    cmp  r2, r5
    bhs  mrd_done
    ldr  r0, [r4, r2]
    str  r0, [r6, r2]
    adds r2, r2, #4
    b    mrd_word
mrd_bytes:
    cmp  r2, r5
    bhs  mrd_done
    ldrb r0, [r4, r2]
    strb r0, [r6, r2]
    adds r2, r2, #1
    b    mrd_bytes
mrd_done:
    dsb
    movw r0, #(MONV & 0xffff)
    movt r0, #(MONV >> 16)
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

; v addr bytes: into the memory
mon_write:
    push {r4, r5, r6, lr}
    bl   pk_len
    subs r5, r0, #4                 ; the bytes
    blt  mwr_bad
    movw r1, #1024
    cmp  r5, r1
    bhi  mwr_bad
    movw r6, #((PKT + 4) & 0xffff)
    movt r6, #((PKT + 4) >> 16)
    ldr  r4, [r6]                   ; the address
    adds r6, r6, #4
    movw r0, #(MONV & 0xffff)
    movt r0, #(MONV >> 16)
    adr  r1, mwr_fault
    str  r1, [r0, #M_PROBE]
    orr  r0, r4, r5
    movs r2, #0
    tst  r0, #3
    bne  mwr_bytes
mwr_word:
    cmp  r2, r5
    bhs  mwr_done
    ldr  r0, [r6, r2]
    str  r0, [r4, r2]
    adds r2, r2, #4
    b    mwr_word
mwr_bytes:
    cmp  r2, r5
    bhs  mwr_done
    ldrb r0, [r6, r2]
    strb r0, [r4, r2]
    adds r2, r2, #1
    b    mwr_bytes
mwr_done:
    dsb                             ; a fault of the writes comes before M_PROBE is 0
    isb
    movw r0, #(MONV & 0xffff)
    movt r0, #(MONV >> 16)
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

; the address of b or u in r0 (with the Thumb bit: the value of FP_COMP), r1 FP_COMP0; r2 0 when the packet is bad
mon_bp_arg:
    push {lr}
    bl   pk_len
    movs r2, #0
    cmp  r0, #4
    bne  mbg_end
    movw r0, #((PKT + 4) & 0xffff)
    movt r0, #((PKT + 4) >> 16)
    ldr  r0, [r0]
    orr  r0, r0, #1
    movw r1, #((MON_FPB + 8) & 0xffff)
    movt r1, #((MON_FPB + 8) >> 16)
    movs r2, #1
mbg_end:
    pop  {pc}

; b addr: the breakpoint into a free comparator (or k when it is there already)
mon_bp_set:
    push {lr}
    bl   mon_bp_arg
    cmp  r2, #0
    beq  mbs_bad
    movs r2, #0
mbs_same:
    ldr  r3, [r1, r2]
    cmp  r3, r0
    beq  mbs_ok
    adds r2, r2, #4
    cmp  r2, #MON_BPS * 4
    blt  mbs_same
    movs r2, #0
mbs_free:
    ldr  r3, [r1, r2]
    cmp  r3, #0
    beq  mbs_put
    adds r2, r2, #4
    cmp  r2, #MON_BPS * 4
    blt  mbs_free
    bl   send_err_inline
    db   'no breakpoint free (the FPB has 7 for them)', 0
    align 2
    pop  {pc}
mbs_put:
    str  r0, [r1, r2]
mbs_ok:
    bl   send_ok
    pop  {pc}
mbs_bad:
    bl   send_err_inline
    db   'b: an address', 0
    align 2
    pop  {pc}

; u addr: the breakpoint off
mon_bp_clear:
    push {lr}
    bl   mon_bp_arg
    cmp  r2, #0
    beq  mbc_bad
    movs r2, #0
mbc_next:
    ldr  r3, [r1, r2]
    cmp  r3, r0
    bne  mbc_skip
    movs r3, #0
    str  r3, [r1, r2]
mbc_skip:
    adds r2, r2, #4
    cmp  r2, #MON_BPS * 4
    blt  mbc_next
    bl   send_ok
    pop  {pc}
mbc_bad:
    bl   send_err_inline
    db   'u: an address', 0
    align 2
    pop  {pc}
