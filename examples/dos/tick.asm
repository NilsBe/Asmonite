; tick.asm - counts in EDX:EBX (64 bits) as fast as it can; the timer interrupt prints both once a second.
; DOS .COM program (runs in QEMU with FreeDOS: F9 in Asmonite).
;
; The timer chip raises IRQ 0 about 18.2 times a second and the CPU calls the handler of interrupt 08h.
; This program puts its own handler there. The CPU changes no register when it enters an interrupt
; (flags, cs and ip go to the stack), so the handler sees EDX:EBX as the counting loop left them. It prints
; them every 18th call (about one second) and then goes on to the old BIOS handler, which counts the
; time and ends the interrupt. The vector 1Ch ("user timer tick") is no good for this: the BIOS
; handler of 08h has used the registers before it calls 1Ch.
; Printing uses the BIOS (INT 10h, teletype), not DOS: DOS must not be entered from an interrupt.

.format binary
.output tick.com
.arch x86_real

section 0x100

start:
    xor  ax, ax
    mov  es, ax                 ; es = 0: the interrupt vector table
    cli
    mov  ax, [es:0x20]          ; vector 08h is at 0000:0020 (4 * 8): offset, then segment
    mov  [old_ofs], ax
    mov  ax, [es:0x22]
    mov  [old_seg], ax
    mov  word [es:0x20], handler
    mov  [es:0x22], cs
    sti

    xor  ebx, ebx               ; EDX:EBX is the counter: EBX the low half, EDX the high half
    xor  edx, edx
count:
    inc  ebx                    ; as often as possible; inc leaves the carry flag alone, but ZF shows the wrap
    jnz  short count_on
    inc  edx                    ; the high half: only when EBX has wrapped around to 0
count_on:
    cmp  byte [done], 0
    je   count

    cli                         ; put the old vector back
    mov  ax, [old_ofs]
    mov  [es:0x20], ax
    mov  ax, [old_seg]
    mov  [es:0x22], ax
    sti
    mov  ax, 0x4C00             ; end the program
    int  0x21

; the interrupt handler: every 18th call (about one second) it prints EDX and EBX as 16 hex digits
handler:
    push eax
    push ebx                    ; INT 10h may change bx: the counter is saved
    push ecx
    push edx
    push esi
    push ds
    push cs
    pop  ds                     ; ds = the segment of the program
    inc  word [ticks]
    cmp  word [ticks], 18
    jb   h_leave
    mov  word [ticks], 0

    mov  esi, ebx               ; the low half is kept here, the high half is in edx
    call print32                ; edx
    mov  edx, esi
    call print32                ; ebx
    mov  ax, 0x0E0D             ; CR LF
    int  0x10
    mov  ax, 0x0E0A
    int  0x10

    inc  byte [seconds]
    cmp  byte [seconds], 5      ; after five prints the loop in main ends
    jb   h_leave
    mov  byte [done], 1
h_leave:
    pop  ds
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    push word [cs:old_seg]      ; on to the BIOS handler with a far return: it counts the time
    push word [cs:old_ofs]      ; and ends the interrupt (iret) for us
    retf

; prints edx as 8 hex digits (changes eax, bx, cx and edx)
print32:
    mov  cx, 8
p_digit:
    rol  edx, 4                 ; the next nibble to the bottom
    mov  al, dl
    and  al, 0x0F
    add  al, '0'
    cmp  al, '9'
    jbe  p_put
    add  al, 7                  ; 'A' to 'F'
p_put:
    push edx
    push ecx
    mov  ah, 0x0E               ; BIOS teletype: the character in al
    xor  bx, bx                 ; page 0
    int  0x10
    pop  ecx
    pop  edx
    loop p_digit
    ret

ticks:   dw 0
seconds: db 0
done:    db 0
old_ofs: dw 0
old_seg: dw 0
