; ESP32-S31: a program for the tests of the console (boards\esp32s31\console.asm; the one of the C3 with the addresses of the S31): it shows its arguments through the
; functions of the console for programs (CON_API) and ends as they say:
;   (none)  "contest: args <>", returns 42 (Program ended (code 42).)
;   e       exit(7) from a function two calls deep
;   x       an illegal instruction: the console stops it (exception 2)
;   l       a loop for ever: Ctrl+C stops it
;   v       shows version(), millis() > 0, file_size("help.txt"), then returns 0 (nothing more is said)
; It touches no pin.
.target esp32s31
.arch riscv32
.imagebase 0x2F000000

CON_API     equ 0x2F060200
API_EXIT    equ CON_API + 0
API_VERSION equ CON_API + 4
API_PRINT   equ CON_API + 20
API_MILLIS  equ CON_API + 24
API_FSIZE   equ CON_API + 28

_start:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    mv   s0, a0                         ; the text of its arguments
    la   a0, s_args
    call print
    mv   a0, s0
    call print
    la   a0, s_end
    call print
    lbu  t0, 0(s0)
    li   t1, 'e'
    beq  t0, t1, do_exit
    li   t1, 'x'
    beq  t0, t1, do_fault
    li   t1, 'l'
    beq  t0, t1, do_loop
    li   t1, 'v'
    beq  t0, t1, do_version
    li   a0, 42
back:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret
do_exit:
    call deep1
    li   a0, 99                         ; (not reached)
    j    back
do_fault:
    j    illegal                        ; (an illegal instruction, as on the C3)
do_loop:
    j    do_loop
do_version:
    li   t0, API_VERSION
    jalr ra, 0(t0)
    call show_num
    li   t0, API_MILLIS
    jalr ra, 0(t0)
    snez a0, a0
    call show_num
    la   a0, s_help
    li   t0, API_FSIZE
    jalr ra, 0(t0)
    call show_num
    li   a0, 0
    j    back

deep1:
    addi sp, sp, -16
    sw   ra, 12(sp)
    call deep2
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret
deep2:
    li   a0, 7
    li   t0, API_EXIT
    jr   t0

; the text a0 through print of the console
print:
    li   t0, API_PRINT
    jr   t0

; a0 as a decimal number (also -1), then a line end
show_num:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    addi s0, sp, 20                     ; the digits from the end back
    sb   zero, 0(s0)
    mv   t0, a0
    bgez t0, sn_digit
    neg  t0, t0
sn_digit:
    li   t1, 10
    remu t2, t0, t1
    divu t0, t0, t1
    addi t2, t2, '0'
    addi s0, s0, -1
    sb   t2, 0(s0)
    bnez t0, sn_digit
    bgez a0, sn_print
    addi s0, s0, -1
    li   t2, '-'
    sb   t2, 0(s0)
sn_print:
    la   a0, s_num
    call print
    mv   a0, s0
    call print
    la   a0, s_crlf
    call print
    lw   s0, 24(sp)
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

  align 4
illegal: dd 0                           ; an illegal instruction: the console stops the program (exception 2)
s_args:  db 'contest: args <', 0
s_end:   db '>', 13, 10, 0
s_num:   db 'contest: ', 0
s_crlf:  db 13, 10, 0
s_help:  db 'help.txt', 0
