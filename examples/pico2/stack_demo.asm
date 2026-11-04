; Raspberry Pi Pico 2 (RP2350, RISC-V core Hazard3): a program that changes the stack and the memory.
;
; blink_ram.asm only writes to the peripherals, so the Stack and Memory views stay the same while you
; step through it. This program writes to the stack and to a table in the RAM, so you can watch both:
;   - Stack view (rows from sp): the call of sum_table saves ra and s0 on the stack and takes them back
;   - Memory view: set the address to "table" (Bytes) and see the words appear; with "pc" and the
;     switch on Code you see the instructions with => at the next one
; Start with F7 (Step into) and keep pressing F7 (F8 steps over the call of sum_table).
.target pico2
.arch riscv32
.imagebase 0x20000000

SRAM_END    equ 0x20082000
COUNT       equ 8

_start:
    li   sp, SRAM_END
    la   a0, table              ; a0 = address of the table
    li   a1, COUNT              ; a1 = number of words

    ; fill the table with the squares 1, 4, 9, ...
    li   t0, 1                  ; t0 = i
    mv   t1, a0                 ; t1 = where the next word goes
fill:
    mul  t2, t0, t0
    sw   t2, 0(t1)              ; the memory changes here
    addi t1, t1, 4
    addi t0, t0, 1
    ble  t0, a1, fill

    call sum_table              ; a0 = sum of the words (204)
    la   t0, result
    sw   a0, 0(t0)              ; and the sum goes into the memory as well

done:
    j    done                   ; stay here: look at the registers and the memory

; a0 = address of the table, a1 = number of words; returns the sum in a0
sum_table:
    addi sp, sp, -16            ; make room: the stack grows downwards
    sw   ra, 12(sp)             ; save the return address
    sw   s0, 8(sp)              ; save s0, which this function uses
    li   s0, 0                  ; s0 = sum
sum_loop:
    lw   t0, 0(a0)
    add  s0, s0, t0
    addi a0, a0, 4
    addi a1, a1, -1
    bnez a1, sum_loop
    mv   a0, s0
    lw   s0, 8(sp)              ; take them back
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

align 4
table:
    dd 0, 0, 0, 0, 0, 0, 0, 0
result:
    dd 0
