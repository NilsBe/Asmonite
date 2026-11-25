; hello_exe.asm - "Hello, World!" as a DOS .EXE program
;
; An .EXE file starts with a header (here 32 bytes, 2 paragraphs) that tells DOS
; how to load it: how big the file is, how much memory it needs, where the
; program starts (CS:IP) and where its stack is (SS:SP). That is what a .COM
; file does not have: an .EXE may be larger than 64 KB and may have several
; segments. DOS puts the image (the file behind the header) into a segment
; and, unlike with .COM, at its offset 0; DS and ES point at the PSP, so the
; program has to set DS itself.
;
; This one is as simple as it gets: one segment for code, data and stack, and
; no relocations. The header is written with dw; "section 0" says that the
; first byte behind the header (file offset 0x20) has the address 0, so the
; labels are counted from the start of the image. The file is padded to 512
; bytes (one page), so the sizes in the header are constants.
;
; Asmonite: F9 runs it in QEMU with FreeDOS. The output file is hello_asm.exe
; (named by ".output"; without it ".format binary" with the 'MZ' signature gets the
; extension .exe of the source name).

.format binary
.output hello_asm.exe
.arch x86_real

; ---- header ------------------------------------------------------------
    dw   0x5A4D             ; 'MZ'
    dw   0                  ; bytes in the last page (0: the page is full)
    dw   1                  ; pages of 512 bytes in the file
    dw   0                  ; number of relocations
    dw   2                  ; header size in paragraphs (16 bytes)
    dw   0x10               ; paragraphs needed beyond the image: the stack
    dw   0xFFFF             ; paragraphs wanted at most
    dw   0                  ; SS at the start (relative to the image)
    dw   0x2E0              ; SP: end of the image (0x1E0) + the 0x100 bytes above
    dw   0                  ; checksum
    dw   0                  ; IP at the start
    dw   0                  ; CS at the start (relative to the image)
    dw   0x1C               ; offset of the relocation table
    dw   0                  ; overlay number
    dw   0, 0               ; fills the header up to 32 bytes

; ---- the image ---------------------------------------------------------
section 0

start:
    mov  ax, cs
    mov  ds, ax             ; DS = this segment: it is the PSP at the start

    mov  ah, 0x09           ; DOS function 09h: write the text at ds:dx up to "$"
    mov  dx, msg
    int  0x21

    mov  ax, 0x4C00         ; DOS function 4Ch: end the program, return code 0
    int  0x21

msg:
    db   'Hello, World!', 13, 10, '$'

    align 512               ; the file is one page long (see the header)
