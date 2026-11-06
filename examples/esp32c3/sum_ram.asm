; ESP32-C3: the sum of 1 to 100 (5050) in a0, worked out by a function, without any pin: for every C3 board,
; also one where the pins of the C3 go to another chip (LilyGO T-PicoC3).
;
;   1. plug the board in at the USB port of the C3 (USB JTAG, 303A:1001; once for each board: Debug > Debug
;      targets > ESP32-C3 > "Set up the USB JTAG")
;   2. press F7: the program goes into the IRAM, the debugger stops at _start. F7 steps into sum, F8 steps
;      over it; the registers show t0 counting down and a0 growing
;   3. or F9: the program runs into the loop at done; Debug > Pause stops it there (Ctrl+F2 ends the session)
; The flash is not touched: the program of the board runs again after a reset.
.target esp32c3
.arch riscv32
.imagebase 0x40380000

_start:
  li   a0, 100            ; up to which number
  jal  ra, sum            ; a0 = 1 + 2 + ... + 100
  mv   a1, a0             ; a1: the result once more
done:
  j    done               ; wait here (pause shows a0 = 5050)

; sum: a0 = 1 + 2 + ... + a0 (a0 > 0); uses t0
sum:
  mv   t0, a0             ; the next number to add
  li   a0, 0              ; the sum
loop:
  add  a0, a0, t0
  addi t0, t0, -1
  bnez t0, loop
  ret
