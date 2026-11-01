; hello_com.asm - "Hello, World!" as a DOS .COM program
;
; A .COM file is the simplest DOS program: no header at all, just the code.
; DOS loads the file at offset 0x100 of a free 64 KB segment (the 256 bytes
; before it are the PSP, the "program segment prefix") and sets CS = DS = ES =
; SS to that segment: code, data and stack share these 64 KB, and the program
; starts at its first byte. Hence "section 0x100": the labels get addresses
; counted from 0x100, not from the start of the file.
;
; Asmonite: F9 runs it in QEMU with FreeDOS (the output file is
; hello_asm.com, named by ".output"). DOS programs run only in QEMU.

.format binary
.output hello_asm.com
.arch x86_real

section 0x100

start:
    mov  ah, 0x09           ; DOS function 09h: write the text at ds:dx up to "$"
    mov  dx, msg            ; ds is already the segment of the program
    int  0x21

    mov  ax, 0x4C00         ; DOS function 4Ch: end the program, return code 0
    int  0x21

msg:
    db   'Hello, World!', 13, 10, '$'
