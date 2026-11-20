; The console of the ESP32-C3: the programs (stage K4), for the line .include "console_run.asm" of console.asm.
;
; A program is a file as Asmonite writes it into the flash (the image of the boot ROM: 0xE9, the number of segments,
; the entry, then each segment with its address and length). The console checks the CRC-32 of the file and the
; addresses of the segments, copies them to their place and calls the entry as a function (RISC-V: its arguments, the
; text of the rest of the line, in a0; the stack of its own from PSTACK, the top of the room of the programs; the
; interrupts on). The program ends
;   - with ret: "Program ended (code n)", n its a0;
;   - with exit(code) from any depth: the first of the functions of the console for programs (CON_API, each 4 bytes
;     after the one before: exit, version, put_char, get_char, poll_char, print, millis, file_size, file_read,
;     file_write, flash_read, args; the order of the ESP32);
;   - by an exception (also ebreak): "Program stopped: exception c at pc p, address v" (c its mcause, v its mtval);
;   - by Ctrl+C from the terminal (Stop in the tab Serial of Asmonite): "Program stopped (Ctrl+C)": while it runs, a
;     packet over the USB port raises the interrupt of the USB Serial/JTAG (source 26 to the interrupt KEY_INT of the
;     core); its bytes go into the ring of get_char, Ctrl+C is not passed on. A program with the interrupts off is not
;     stopped so (the C3 has no NMI); during a function of the ROM for the flash the stop waits for its end.
; Then the console goes on (its stack and its registers as before; the peripherals as the program leaves them).
;
; The trap vector of the console (mtvec, in the vectored mode the C3 has): each exception comes to exc_entry (of a
; program: it ends; of the console itself: a message and the prompt again), each interrupt to irq_entry, which calls
; the handler that ets_isr_attach of the ROM put into its table for that interrupt (the ROM's dispatcher at
; 0x40052932: its table at 0x3FCDEF60, 8 bytes per interrupt), as the vector of the ROM does: the WiFi and a program
; that uses ets_isr_attach work as before.
;
; The rooms: a program 0x40380000 .. 0x403A7FFF, the same RAM as 0x3FC80000 .. 0x3FCA7FFF (its data); load takes the
; room above too, up to the console (0x403CBFFF / 0x3FCCBFFF: the WiFi service, wlan.rom, the heap of the WiFi); the
; segments for the flash (0x42000000 .., 0x3C000000 ..) load leaves out.

PSTACK       equ 0x3FCA7FF0             ; the top of the stack of a program
KEY_INT      equ 20                     ; the interrupt of the core for the USB port (Ctrl+C while a program runs)
USB_SOURCE   equ 26                     ; ETS_USB_SERIAL_JTAG_INTR_SOURCE
INT_MATRIX   equ 0x600C2000             ; INTERRUPT_CORE0: the map of a source +4 * source, CPU_INT_ENABLE +0x104,
                                        ; CPU_INT_TYPE +0x108, CPU_INT_CLEAR +0x10C, CPU_INT_PRI_n +0x114 + 4 * n
ROM_INT_DISPATCH equ 0x40052932         ; the ROM: the handler of the interrupt a0 with its argument
KEYRING      equ 0x3FCD8000             ; the bytes that came while a program runs (256)
SVC_BUSY     equ 0x3FCBDB80             ; svc_busy of the WiFi service (wlan/wlanos_c3.asm OS_VARS2 = WLAN_RAM + 0x1B80):
                                        ; not 0 while it runs (an entry, a round of its tick); 0 from con_start on
SVC_HOOK     equ SVC_BUSY + 20          ; ... the function it calls when it leaves an entry (version 6): key_hook
ROM_UDIVDI3  equ 0x400008AC             ; __udivdi3 of the ROM (64 bits by 64 bits)

; ---------- the trap vector (at 0x403CC100: mtvec in the vectored mode takes 256 bytes alignment) ----------

trap_init:
    la   t0, trap_vector
    ori  t0, t0, 1                      ; vectored
    csrw mtvec, t0
    ret

; an exception: of a program it ends (re_exc with its mcause, mepc, mtval); of the console: con_fault
exc_entry:
    csrw mscratch, t0
    la   t0, prog_running
    lw   t0, 0(t0)
    beqz t0, exc_console
    la   t0, prog_cause
    csrr t1, mcause                     ; (t1, t2 are the program's no more: it ends)
    sw   t1, 0(t0)
    csrr t1, mepc
    sw   t1, 4(t0)
    csrr t1, mtval
    sw   t1, 8(t0)
    la   t0, re_exc
    j    exc_out
exc_console:
    la   t0, prog_cause
    csrr t1, mcause
    sw   t1, 0(t0)
    csrr t1, mepc
    sw   t1, 4(t0)
    csrr t1, mtval
    sw   t1, 8(t0)
    la   t0, con_fault
exc_out:
    csrw mepc, t0                       ; on there in the machine mode, the interrupts off
    li   t0, 0x80                       ; MPIE 0
    csrc mstatus, t0
    li   t0, 0x1800                     ; MPP 3
    csrs mstatus, t0
    csrr t0, mscratch
    mret

; an interrupt: the registers a handler may change onto the stack, the handler of its number (the key of the USB port
; here, else the one of the ROM's table), back
irq_entry:
    addi sp, sp, -80
    sw   ra, 0(sp)
    sw   t0, 4(sp)
    sw   t1, 8(sp)
    sw   t2, 12(sp)
    sw   t3, 16(sp)
    sw   t4, 20(sp)
    sw   t5, 24(sp)
    sw   t6, 28(sp)
    sw   a0, 32(sp)
    sw   a1, 36(sp)
    sw   a2, 40(sp)
    sw   a3, 44(sp)
    sw   a4, 48(sp)
    sw   a5, 52(sp)
    sw   a6, 56(sp)
    sw   a7, 60(sp)
    csrr t0, mepc
    sw   t0, 64(sp)
    csrr t0, mstatus
    sw   t0, 68(sp)
    csrr a0, mcause
    andi a0, a0, 31
    li   t0, KEY_INT
    beq  a0, t0, irq_key
    li   t0, ROM_INT_DISPATCH
    jalr ra, 0(t0)
    j    irq_back
irq_key:
    call key_isr
    beqz a0, irq_back
    la   t0, re_key                     ; Ctrl+C: the program ends there
    sw   t0, 64(sp)
    lw   t0, 68(sp)
    andi t0, t0, -129                   ; MPIE 0: the console goes on with the interrupts off
    sw   t0, 68(sp)
irq_back:
    la   t0, key_stop                   ; a Ctrl+C that waited (key_isr): the program ends now, when it is neither in a
    lw   t0, 0(t0)                      ; function of the flash nor in the WiFi service
    beqz t0, irq_out
    la   t0, prog_running
    lw   t0, 0(t0)
    beqz t0, irq_out
    la   t0, flash_busy
    lw   t0, 0(t0)
    bnez t0, irq_out
    li   t0, SVC_BUSY
    lw   t0, 0(t0)
    bnez t0, irq_out
    la   t0, key_stop
    sw   zero, 0(t0)
    la   t0, svc_loaded                 ; (key_hook not needed now: out of the service's table)
    lw   t0, 0(t0)
    li   t1, 1
    bne  t0, t1, irq_stop
    li   t0, SVC_HOOK
    sw   zero, 0(t0)
irq_stop:
    la   t0, re_key
    sw   t0, 64(sp)
    lw   t0, 68(sp)
    andi t0, t0, -129                   ; MPIE 0: the console goes on with the interrupts off
    sw   t0, 68(sp)
irq_out:
    lw   t0, 64(sp)
    csrw mepc, t0
    lw   t0, 68(sp)
    csrw mstatus, t0
    lw   ra, 0(sp)
    lw   t0, 4(sp)
    lw   t1, 8(sp)
    lw   t2, 12(sp)
    lw   t3, 16(sp)
    lw   t4, 20(sp)
    lw   t5, 24(sp)
    lw   t6, 28(sp)
    lw   a0, 32(sp)
    lw   a1, 36(sp)
    lw   a2, 40(sp)
    lw   a3, 44(sp)
    lw   a4, 48(sp)
    lw   a5, 52(sp)
    lw   a6, 56(sp)
    lw   a7, 60(sp)
    addi sp, sp, 80
    mret

; the key interrupt: the bytes of the USB port into KEYRING (a full ring leaves them in the port); 1 when a Ctrl+C
; came and the program may stop now (not in a function of the ROM for the flash: then later, fl_done), else 0
key_isr:
    li   t0, USB_SERIAL
    li   t1, 4                          ; SERIAL_OUT_RECV_PKT cleared
    sw   t1, 0x14(t0)
    li   a0, 0
ki_next:
    lw   t1, 4(t0)
    andi t1, t1, 4
    beqz t1, ki_done
    la   t2, key_head
    lw   t3, 0(t2)                      ; head
    lw   t4, 4(t2)                      ; tail
    addi t5, t3, 1
    andi t5, t5, 255
    beq  t5, t4, ki_done                ; full
    lbu  t1, 0(t0)
    li   t6, 3
    beq  t1, t6, ki_ctrlc
    li   t6, KEYRING
    add  t6, t6, t3
    sb   t1, 0(t6)
    sw   t5, 0(t2)
    j    ki_next
ki_ctrlc:
    li   a0, 1
    j    ki_next
ki_done:
    beqz a0, ki_ret
    la   t0, flash_busy                 ; in a function of the flash: the stop waits for its end
    lw   t1, 0(t0)
    bnez t1, ki_later
    li   t0, SVC_BUSY                   ; in the WiFi service (an entry, or a round of its tick): the stop waits too
    lw   t1, 0(t0)                      ; (irq_back stops the program once it is out)
    beqz t1, ki_ret
ki_later:
    la   t0, key_stop
    li   t1, 1
    sw   t1, 0(t0)
    la   t0, svc_loaded                 ; the service in the RAM: it calls key_hook when it leaves its entry (a
    lw   t0, 0(t0)                      ; program that waits in wifi_recv nearly all the time, as pingled)
    li   t1, 1
    bne  t0, t1, ki_zero
    li   t0, SVC_HOOK
    la   t1, key_hook
    sw   t1, 0(t0)
ki_zero:
    li   a0, 0
ki_ret:
    ret

; key_hook (SVC_HOOK: the WiFi service calls it when it leaves an entry): a Ctrl+C that waited ends the program now,
; as irq_back does (not in a function of the flash); else back to the service
key_hook:
    la   t0, key_stop
    lw   t0, 0(t0)
    beqz t0, kh_ret
    la   t0, prog_running
    lw   t0, 0(t0)
    beqz t0, kh_ret
    la   t0, flash_busy
    lw   t0, 0(t0)
    bnez t0, kh_ret
    la   t0, key_stop
    sw   zero, 0(t0)
    li   t0, SVC_HOOK
    sw   zero, 0(t0)
    csrci mstatus, 8                    ; the interrupts off, as after irq_key: re_key goes on so
    j    re_key
kh_ret:
    ret

; the USB port to the key interrupt while a program runs (its source to KEY_INT, level, priority 1, on), the ring
; empty; key_off: as before
key_on:
    la   t0, key_head
    sw   zero, 0(t0)
    sw   zero, 4(t0)
    la   t0, key_stop
    sw   zero, 0(t0)
    la   t0, svc_loaded                 ; no key_hook of an earlier program in the service
    lw   t0, 0(t0)
    li   t1, 1
    bne  t0, t1, kon_int
    li   t0, SVC_HOOK
    sw   zero, 0(t0)
kon_int:
    li   t0, INT_MATRIX
    li   t1, KEY_INT
    sw   t1, USB_SOURCE * 4(t0)         ; the source to the interrupt of the core
    li   t1, 1
    sw   t1, 0x114 + KEY_INT * 4(t0)    ; priority 1
    lw   t1, 0x108(t0)                  ; level
    li   t2, 1 << KEY_INT
    not  t3, t2
    and  t1, t1, t3
    sw   t1, 0x108(t0)
    lw   t1, 0x104(t0)                  ; on
    or   t1, t1, t2
    sw   t1, 0x104(t0)
    li   t0, USB_SERIAL
    li   t1, -1
    sw   t1, 0x14(t0)                   ; INT_CLR
    li   t1, 4
    sw   t1, 0x10(t0)                   ; INT_ENA: SERIAL_OUT_RECV_PKT
    ret
key_off:
    li   t0, USB_SERIAL
    sw   zero, 0x10(t0)
    li   t1, -1
    sw   t1, 0x14(t0)
    li   t0, INT_MATRIX
    lw   t1, 0x104(t0)
    li   t2, 1 << KEY_INT
    not  t2, t2
    and  t1, t1, t2
    sw   t1, 0x104(t0)
    sw   zero, USB_SOURCE * 4(t0)       ; the source to no interrupt
    ret

; the console itself had an exception: what it was, then the prompt again (a new stack)
con_fault:
    li   sp, CON_STACK
    la   a0, s_confault
    call print
    call print_cause
    j    main_loop

; "0x... at pc 0x..., address 0x...." and a line end, of prog_cause
print_cause:
    addi sp, sp, -16
    sw   ra, 12(sp)
    la   t0, prog_cause
    lw   a0, 0(t0)
    call print_hex
    la   a0, s_at
    call print
    la   t0, prog_cause
    lw   a0, 4(t0)
    call print_hex
    la   a0, s_addr
    call print
    la   t0, prog_cause
    lw   a0, 8(t0)
    call print_hex
    la   a0, s_dotcrlf
    call print
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; ---------- the functions of the console for programs (CON_API: each a jump of 4 bytes) ----------

; exit(code): the program ends from any depth
api_exit:
    li   a1, 1
    j    re_after

; version(): which functions the table has (5: exit .. args, dbg_run and wifi_up; 3: without wifi_up; 2: without
; dbg_run; 4 is the S31 with rgb, which the C3 has not); the packet V gives it too (the Board Manager shows it)
CON_VERSION equ 5
api_version:
    li   a0, CON_VERSION
    ret

; dbg_run(entry): the debugger of Asmonite (F9, F7, F8 of an aBelle program over the USB JTAG) puts the pc here and the
; start of the program into a0, wherever the console was: the program runs as run starts one (run_entry: on PSTACK,
; Ctrl+C, exit, an exception, "Program ended (code n)"), from a fresh stack of the console; then the ebreak at dbg_end
; (CON_API + 52: the debugger sees the end there and lets the core go on behind it) and the prompt. Not for programs:
; without the debugger the ebreak is an exception
api_dbg_run:
    li   sp, CON_STACK
    la   t0, prog_entry
    sw   a0, 0(t0)
    la   a0, s_empty
    li   a1, 1
    call run_entry
    j    dbg_end

; put_char(c), print(text): at once to the host
api_put_char:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call put_char
    call flush
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret
api_print:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call print
    call flush
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; poll_char(): the next byte that came in, -1 if none
api_poll_char:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call flush
    call key_take
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; get_char(): the next byte (it waits)
api_get_char:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call flush
agc_wait:
    call key_take
    bltz a0, agc_wait
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; a byte of the ring of a program, else of the USB port; -1 if none. It calls nothing. The interrupts are off
; meanwhile: else the key interrupt could take the byte between the look at the port and its read (then the read
; got nothing: a byte was lost; found on the ESP32-S31 with two keys at once)
key_take:
    csrrci a1, mstatus, 8
    la   t0, key_head
    lw   t1, 0(t0)
    lw   t2, 4(t0)
    beq  t1, t2, kt_port
    li   t3, KEYRING
    add  t3, t3, t2
    lbu  a0, 0(t3)
    addi t2, t2, 1
    andi t2, t2, 255
    sw   t2, 4(t0)
    j    kt_ret
kt_port:
    li   t0, USB_SERIAL                 ; (the interrupt of the key takes them while a program runs with the
    lw   t1, 4(t0)                      ; interrupts on; with them off they wait here)
    andi t1, t1, 4
    li   a0, -1
    beqz t1, kt_ret
    lbu  a0, 0(t0)
kt_ret:
    andi a1, a1, 8
    csrs mstatus, a1                    ; the interrupts as they were
    ret

; millis(): the milliseconds of timer 0 (it counts from the start of the console)
api_millis:
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   t0, TIMG0
    li   t1, 0x80000000
    sw   t1, 0x0C(t0)
am_wait:
    lw   t1, 0x0C(t0)
    bltz t1, am_wait
    lw   a0, 0x04(t0)
    lw   a1, 0x08(t0)
    li   a2, 1000
    li   a3, 0
    li   t0, ROM_UDIVDI3
    jalr ra, 0(t0)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; the entry of the file a0 (its address in DIRBUF), 0 if there is none or no file system
file_entry:
    la   t0, fs_ok
    lw   t0, 0(t0)
    beqz t0, fn_none
    addi sp, sp, -16
    sw   ra, 12(sp)
    call find_entry
    bltz a0, fn_no
    call entry_at
    j    fn_end
fn_no:
    li   a0, 0
fn_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret
fn_none:
    li   a0, 0
    ret

; file_size(name): the length of the file, -1 if there is none
api_file_size:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call file_entry
    beqz a0, afz_none
    lw   a0, 24(a0)
    j    afz_end
afz_none:
    li   a0, -1
afz_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; file_read(name, buffer, offset, count): up to count bytes of the file from offset on into buffer; how many (0 from
; its end on), -1 if there is no such file or the flash cannot be read. s0 buffer, s1 offset, s2 count
api_file_read:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    sw   s2, 0(sp)
    mv   s0, a1
    mv   s1, a2
    mv   s2, a3
    call file_entry
    beqz a0, afr_none
    lw   t1, 24(a0)                     ; the length
    lw   t2, 20(a0)                     ; the first sector
    bgeu s1, t1, afr_zero               ; from its end on: nothing
    sub  t1, t1, s1
    bgeu t1, s2, afr_count
    mv   s2, t1
afr_count:
    slli a0, t2, 12
    add  a0, a0, s1
    mv   a1, s0
    mv   a2, s2
    call flash_bytes
    bnez a0, afr_none
    mv   a0, s2
    j    afr_end
afr_zero:
    li   a0, 0
    j    afr_end
afr_none:
    li   a0, -1
afr_end:
    lw   s2, 0(sp)
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; file_write(name, buffer, count): a file with the count bytes at buffer (a new one, or a new text for one); 0 done,
; -1 the directory is full, -2 not enough room in the flash, -3 the flash cannot be written, -4 not a valid name, -5
; no file system
api_file_write:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    sw   s2, 0(sp)
    mv   s0, a0
    mv   s1, a1
    mv   s2, a2
    la   t0, fs_ok
    lw   t0, 0(t0)
    li   a0, -5
    beqz t0, afw_end
    mv   a0, s0
    call name_problem
    mv   t0, a0
    li   a0, -4
    bnez t0, afw_end
    li   a0, -2
    bltz s2, afw_end
    mv   a0, s0
    mv   a1, s1
    mv   a2, s2
    call store_file
afw_end:
    lw   s2, 0(sp)
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; flash_read(address, buffer, count) = flash_bytes: count bytes of the flash from address on (any address, any
; count) to buffer, in pieces through SMALL; 0 done, -1 the flash cannot be read there. s0 address, s1 buffer, s2
; count, s3 the bytes before the piece in its word, s4 the piece
flash_bytes:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    sw   s3, 12(sp)
    sw   s4, 8(sp)
    mv   s0, a0
    mv   s1, a1
    mv   s2, a2
fb_part:
    beqz s2, fb_ok
    andi s3, s0, 3                      ; the bytes before it in its word
    li   s4, 252                        ; the piece: at most 252 bytes (with s3 at most 256 to read)
    bgeu s2, s4, fb_read
    mv   s4, s2
fb_read:
    sub  a0, s0, s3
    li   a1, SMALL
    add  a2, s3, s4
    addi a2, a2, 3
    andi a2, a2, -4
    call fl_read
    bnez a0, fb_bad
    mv   a0, s1
    li   a1, SMALL
    add  a1, a1, s3
    mv   a2, s4
    call copy_bytes
    add  s0, s0, s4
    add  s1, s1, s4
    sub  s2, s2, s4
    j    fb_part
fb_ok:
    li   a0, 0
    j    fb_end
fb_bad:
    li   a0, -1
fb_end:
    lw   s4, 8(sp)
    lw   s3, 12(sp)
    lw   s2, 16(sp)
    lw   s1, 20(sp)
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

; args(): the text of its arguments (the rest of the line of a command; empty for run)
api_args:
    la   t0, prog_args
    lw   a0, 0(t0)
    ret

; ---------- the commands ----------

; run name: the program starts
cmd_run:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    mv   s0, a0
    call need_fs
    beqz a0, cr_end
    mv   a0, s0
    call check_name
    beqz a0, cr_end
    mv   a0, s0
    li   a1, 0
    li   a2, 0
    call run_file
    beqz a0, cr_end                     ; it ran and ended
    call print                          ; it did not start: why
    la   a0, s_crlf
    call print
cr_end:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret


; boot name: the program after every reset; boot alone: which one. s0 the name
cmd_boot:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    mv   s0, a0
    call need_fs
    beqz a0, cb_end
    lbu  t0, 0(s0)
    beqz t0, cb_show
    mv   a0, s0
    call check_name
    beqz a0, cb_end
    mv   a0, s0
    call find_entry
    bgez a0, cb_found
    mv   a0, s0
    call say_nofile
    j    cb_end
cb_found:
    addi a0, a0, 1
    li   t0, DIRBUF
    sw   a0, 12(t0)
    call dir_save
    bnez a0, cb_show
    la   a0, s_flasherr
    call print
    j    cb_end
cb_show:
    call show_boot
cb_end:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; noboot: no program after a reset
cmd_noboot:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call need_fs
    beqz a0, nb_end
    li   t0, DIRBUF
    sw   zero, 12(t0)
    call dir_save
    bnez a0, nb_show
    la   a0, s_flasherr
    call print
    j    nb_end
nb_show:
    call show_boot
nb_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; "Autostart: name" or "No autostart."
show_boot:
    addi sp, sp, -16
    sw   ra, 12(sp)
    li   t0, DIRBUF
    lw   t0, 12(t0)
    bnez t0, sb_one
    la   a0, s_noboot
    call print
    j    sb_end
sb_one:
    sw   t0, 8(sp)
    la   a0, s_boot
    call print
    lw   a0, 8(sp)
    addi a0, a0, -1
    call entry_at
    call print
    la   a0, s_crlf
    call print
sb_end:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; after the start: the program for boot, unless a key comes within 3 seconds (the USB port comes back after a reset
; first). (The ESP32 and the S3 also stay for their key BOOT; GPIO 9 of the C3 is left alone: on some boards it goes
; to another chip.) s0 the entry, s1 the start
autostart:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    la   t0, fs_ok
    lw   t0, 0(t0)
    beqz t0, as_end
    li   t0, DIRBUF
    lw   t0, 12(t0)
    beqz t0, as_end
    addi a0, t0, -1
    call entry_at
    mv   s0, a0
    lbu  t0, 0(s0)
    beqz t0, as_end
    la   a0, s_auto
    call print
    mv   a0, s0
    call print
    la   a0, s_auto2
    call print
    call flush
    call micros
    mv   s1, a0
as_wait:
    li   t0, USB_SERIAL
    lw   t1, 4(t0)
    andi t1, t1, 4
    bnez t1, as_stay                    ; a key (it is read as a command then)
    call micros
    sub  t0, a0, s1
    li   t1, 3000000
    bltu t0, t1, as_wait
    mv   a0, s0
    li   a1, 0
    li   a2, 0
    call run_file
    beqz a0, as_end                     ; it ran and ended
    call print                          ; it did not start: why
    la   a0, s_crlf
    call print
    j    as_end
as_stay:
    la   a0, s_stay
    call print
as_end:
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; cmd_file(name, args): a command the console does not know: the program of the file name, else of name + ".bin" (as
; Upload This Program names it), with the rest of the line as its arguments (args(), its a0), started as a command
; (nothing before it, nothing after it when it ends with the code 0). 1 if there is such a file (it ran, or why not
; is said), 0 if not. s0 the name, s1 the arguments
cmd_file:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    mv   s0, a0
    mv   s1, a1
    la   t0, fs_ok
    lw   t0, 0(t0)
    beqz t0, cfl_no                     ; no file system
    mv   a0, s0
    call find_entry
    bgez a0, cfl_run
    mv   t0, s0                         ; the length of the name
    li   t1, 0
cfl_len:
    lbu  t2, 0(t0)
    beqz t2, cfl_ext
    addi t0, t0, 1
    addi t1, t1, 1
    j    cfl_len
cfl_ext:
    li   t2, 15
    bltu t2, t1, cfl_no                 ; the name with .bin would be longer than 19 characters
    li   a0, CHUNK                      ; the name with .bin into CHUNK (free while no program runs)
    mv   a1, s0
    mv   a2, t1
    sw   t1, 0(sp)
    call copy_bytes
    li   t0, CHUNK
    lw   t1, 0(sp)
    add  t0, t0, t1
    la   a1, s_bin
    mv   a0, t0
    li   a2, 5
    call copy_bytes
    li   a0, CHUNK
    call find_entry
    bltz a0, cfl_no
    li   s0, CHUNK
cfl_run:
    mv   a0, s0
    li   a1, 2
    mv   a2, s1
    call run_file
    beqz a0, cfl_yes                    ; it ran and ended
    call print                          ; it did not start: why
    la   a0, s_crlf
    call print
cfl_yes:
    li   a0, 1
    j    cfl_end
cfl_no:
    li   a0, 0
cfl_end:
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; ---------- running ----------

; run_file(name, how, args): the program in the file into its place, then its entry; how 0: "Running name" before,
; 1: k before (packets), 2: a command (nothing before, and nothing after when it ends with the code 0); args the text
; of its arguments (0: none). 0 when it ran (and ended), else the text that says why it did not start. s0 the name,
; s1 how, s2 args, s3 the entry
run_file:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    sw   s3, 12(sp)
    mv   s0, a0
    mv   s1, a1
    mv   s2, a2
    bnez s2, rf_args
    la   s2, s_empty
rf_args:
    la   t0, fs_ok
    lw   t0, 0(t0)
    bnez t0, rf_fs
    la   a0, s_nofs
    j    rf_end
rf_fs:
    mv   a0, s0
    call find_entry
    bgez a0, rf_found
    la   a0, e_nofile
    j    rf_end
rf_found:
    call entry_at
    mv   s3, a0
    lw   a0, 20(s3)
    lw   a1, 24(s3)
    call file_crc
    lw   t0, 28(s3)
    beq  a0, t0, rf_whole
    la   a0, e_damaged
    j    rf_end
rf_whole:
    mv   a0, s3
    li   a1, 0
    call segments                       ; first only checked
    bnez a0, rf_end
    li   t0, 2
    beq  s1, t0, rf_go                  ; a command: at once
    bnez s1, rf_k
    la   a0, s_running
    call print
    mv   a0, s0
    call print
    la   a0, s_crlf
    call print
    j    rf_go
rf_k:
    call send_ok
rf_go:
    mv   a0, s3
    li   a1, 1
    call segments                       ; now into their place
    mv   a0, s2
    mv   a1, s1
    call run_entry
    li   a0, 0
rf_end:
    lw   s3, 12(sp)
    lw   s2, 16(sp)
    lw   s1, 20(sp)
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

; run_entry(args, how): the program at prog_entry runs (its segments are in their place) and ends (re_after says how):
; the registers of the console onto its stack, its sp into prog_sp; the program on PSTACK with the interrupts on
run_entry:
    addi sp, sp, -64
    sw   ra, 60(sp)
    sw   s0, 56(sp)
    sw   s1, 52(sp)
    sw   s2, 48(sp)
    sw   s3, 44(sp)
    sw   s4, 40(sp)
    sw   s5, 36(sp)
    sw   s6, 32(sp)
    sw   s7, 28(sp)
    sw   s8, 24(sp)
    sw   s9, 20(sp)
    sw   s10, 16(sp)
    sw   s11, 12(sp)
    la   t0, prog_args
    sw   a0, 0(t0)
    la   t0, prog_how
    sw   a1, 0(t0)
    li   t1, 1
    bne  a1, t1, ren_k
    la   t0, pk_ran                     ; started by a packet: read_line shows the prompt after its end
    sw   t1, 0(t0)
ren_k:
    csrr t0, mstatus                    ; the interrupts as they are now come back after the program (re_back: with
    andi t0, t0, 8                      ; the WiFi on they are on; before, the console stayed with them off, and the
    la   t1, prog_mie                   ; WiFi lost its connection at the prompt again and again)
    sw   t0, 0(t1)
    la   t0, prog_sp
    sw   sp, 0(t0)
    call flush
    call key_on
    la   t0, prog_running
    li   t1, 1
    sw   t1, 0(t0)
    la   t0, prog_entry
    lw   t0, 0(t0)
    la   t1, prog_args
    lw   a0, 0(t1)
    li   sp, PSTACK
    csrsi mstatus, 8                    ; the interrupts on
    jalr ra, 0(t0)                      ; the program
    li   a1, 1                          ; it returned: a0 its code
    ; (on into re_after)

; re_after(code, how): the end of a program from any depth (1 ended or exit, 2 Ctrl+C, 3 an exception): the
; interrupts off, the stack and the registers of the console, the USB port as before, then what happened
re_after:
    csrci mstatus, 8
    la   t0, prog_sp
    lw   sp, 0(t0)
    la   t0, prog_running
    sw   zero, 0(t0)
    la   t0, prog_code
    sw   a0, 0(t0)
    sw   a1, 4(t0)
    call key_off
    call flush
    la   t0, prog_code
    lw   t1, 4(t0)
    li   t2, 3
    beq  t1, t2, re_stopped
    li   t2, 2
    bne  t1, t2, re_ended
    la   a0, s_keystop                  ; Program stopped (Ctrl+C).
    call print
    j    re_back
re_ended:
    la   t1, prog_how
    lw   t1, 0(t1)
    li   t2, 2
    bne  t1, t2, re_say
    lw   t1, 0(t0)
    beqz t1, re_back                    ; a command that ended well: nothing to say
re_say:
    la   a0, s_ended                    ; Program ended (code n).
    call print
    la   t0, prog_code
    lw   a0, 0(t0)
    call print_dec
    la   a0, s_ended2
    call print
    j    re_back
re_stopped:                             ; Program stopped: exception c at pc 0x..., address 0x...
    la   a0, s_stopped
    call print
    call print_cause
re_back:
    la   t0, prog_mie                   ; the interrupts as before the program
    lw   t0, 0(t0)
    csrs mstatus, t0
    lw   s11, 12(sp)
    lw   s10, 16(sp)
    lw   s9, 20(sp)
    lw   s8, 24(sp)
    lw   s7, 28(sp)
    lw   s6, 32(sp)
    lw   s5, 36(sp)
    lw   s4, 40(sp)
    lw   s3, 44(sp)
    lw   s2, 48(sp)
    lw   s1, 52(sp)
    lw   s0, 56(sp)
    lw   ra, 60(sp)
    addi sp, sp, 64
    ret

; the program stopped by an exception or by Ctrl+C (from exc_entry, irq_entry)
re_exc:
    li   a0, 0
    li   a1, 3
    j    re_after
re_key:
    li   a0, 0
    li   a1, 2
    j    re_after

; ---------- the segments ----------

; segments(entry, mode): the segments of the program in the file of the entry (its address in DIRBUF): mode bit 0 = 0
; checked, 1 copied into their place; bit 1 = 1 as for the former command load (the room between the programs and the
; console too, the segments for the flash left out and counted in seg_flash; no caller sets it now); 0 or the text of the problem. The entry of the program
; into prog_entry. s0 the address of the file in the flash, s1 its length, s2 mode, s3 the segments left, s4 the place
; in the file, s5 the address of a segment, s6 its length
segments:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    sw   s3, 12(sp)
    sw   s4, 8(sp)
    sw   s5, 4(sp)
    sw   s6, 0(sp)
    mv   s2, a1
    la   t0, seg_flash
    sw   zero, 0(t0)
    lw   s1, 24(a0)                     ; the length of the file
    lw   s0, 20(a0)
    slli s0, s0, 12                     ; its address in the flash
    li   t0, 24
    bltu s1, t0, sg_noprog
    mv   a0, s0
    li   a1, SMALL
    li   a2, 24
    call fl_read
    li   t0, SMALL
    lbu  t1, 0(t0)
    li   t2, 0xE9
    bne  t1, t2, sg_noprog
    lw   t1, 4(t0)
    la   t2, prog_entry
    sw   t1, 0(t2)                      ; the entry
    lbu  s3, 1(t0)                      ; the segments
    beqz s3, sg_noprog
    li   t1, 16
    bltu t1, s3, sg_noprog
    li   s4, 24                         ; the place in the file
sg_next:
    beqz s3, sg_done
    addi t0, s4, 8
    bltu s1, t0, sg_noprog
    add  a0, s0, s4
    li   a1, SMALL
    li   a2, 8
    call fl_read
    addi s4, s4, 8
    li   t0, SMALL
    lw   s5, 0(t0)                      ; its address
    lw   s6, 4(t0)                      ; its length
    andi t0, s6, 3
    bnez t0, sg_noprog
    add  t0, s4, s6
    bltu s1, t0, sg_noprog
    mv   a0, s5
    mv   a1, s6
    srli a2, s2, 1                      ; load?
    andi a2, a2, 1
    call segment_fits
    beqz a0, sg_where
    li   t0, 2
    bne  a0, t0, sg_ram
    la   t0, seg_flash                  ; a segment for the flash: left out, counted
    lw   t1, 0(t0)
    addi t1, t1, 1
    sw   t1, 0(t0)
    j    sg_skip
sg_ram:
    andi t0, s2, 1
    beqz t0, sg_skip
    add  a0, s0, s4
    mv   a1, s5
    mv   a2, s6
    call copy_in
sg_skip:
    add  s4, s4, s6
    addi s3, s3, -1
    j    sg_next
sg_done:
    li   a0, 0
    j    sg_end
sg_noprog:
    la   a0, e_noprog
    j    sg_end
sg_where:
    la   a0, e_where
sg_end:
    lw   s6, 0(sp)
    lw   s5, 4(sp)
    lw   s4, 8(sp)
    lw   s3, 12(sp)
    lw   s2, 16(sp)
    lw   s1, 20(sp)
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

; segment_fits(address, n, load): 1 if the n bytes lie in the room of a program (on the bus of the instructions or of
; the data); with load = 1 also in the room between the programs and the console, and 2 for a segment for the flash;
; else 0. It calls nothing.
segment_fits:
    add  a1, a1, a0                     ; behind it
    bltu a1, a0, sf_no                  ; over the end of the addresses
    la   t0, rooms
sf_next:
    lw   t1, 0(t0)
    lw   t2, 4(t0)
    lw   t3, 8(t0)                      ; the kind: 1 a program, 3 load only, 2 the flash
    beqz t3, sf_no
    addi t0, t0, 12
    bltu a0, t1, sf_next
    bltu t2, a1, sf_next
    li   t4, 3
    bne  t3, t4, sf_kind
    beqz a2, sf_next                    ; the room above the programs: load only
    li   a0, 1
    ret
sf_kind:
    li   t4, 2
    bne  t3, t4, sf_yes
    beqz a2, sf_no                      ; a segment for the flash: load only (run and R: not a program for the RAM)
sf_yes:
    mv   a0, t3
    ret
sf_no:
    li   a0, 0
    ret

; copy_in(flash, ram, n): n bytes (whole words) from the flash to the RAM, a word at a time. s0 .. s2 the
; arguments, s3 a piece
copy_in:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    sw   s3, 12(sp)
    mv   s0, a0
    mv   s1, a1
    mv   s2, a2
ci_part:
    beqz s2, ci_done
    li   s3, 256
    bgeu s2, s3, ci_read
    mv   s3, s2
ci_read:
    mv   a0, s0
    li   a1, SMALL
    mv   a2, s3
    call fl_read
    mv   a0, s1
    li   a1, SMALL
    mv   a2, s3
    call copy_words
    add  s0, s0, s3
    add  s1, s1, s3
    sub  s2, s2, s3
    j    ci_part
ci_done:
    lw   s3, 12(sp)
    lw   s2, 16(sp)
    lw   s1, 20(sp)
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

; copy_words(to, from, n): n bytes (whole words), a word at a time. It calls nothing.
copy_words:
    beqz a2, cw_done
    lw   t0, 0(a1)
    sw   t0, 0(a0)
    addi a0, a0, 4
    addi a1, a1, 4
    addi a2, a2, -4
    j    copy_words
cw_done:
    ret

; file_crc(sector, n): the CRC-32 of n bytes of the file from the sector on
file_crc:
    slli a0, a0, 12
    ; (on into flash_crc)

; flash_crc(address, n): the CRC-32 of n bytes of the flash from the address (a multiple of 4) on, in pieces of 256
; through SMALL. s0 the address, s1 the bytes left, s2 the CRC, s3 a piece
flash_crc:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    sw   s3, 12(sp)
    mv   s0, a0
    mv   s1, a1
    li   s2, 0
fc_part:
    beqz s1, fc_done
    li   s3, 256
    bgeu s1, s3, fc_read
    mv   s3, s1
fc_read:
    mv   a0, s0
    li   a1, SMALL
    addi a2, s3, 3
    andi a2, a2, -4
    call fl_read
    mv   a0, s2
    li   a1, SMALL
    mv   a2, s3
    call crc32
    mv   s2, a0
    add  s0, s0, s3
    sub  s1, s1, s3
    j    fc_part
fc_done:
    mv   a0, s2
    lw   s3, 12(sp)
    lw   s2, 16(sp)
    lw   s1, 20(sp)
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret
