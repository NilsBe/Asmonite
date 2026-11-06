; MangoPi MQ-Pro (Allwinner D1, one T-Head C906 core, RV64): the sum of 1 to 100, returned in a0.
;
;   1. take the SD card out and plug the board in at its USB port OTG: the boot ROM of the D1 waits in its FEL
;      mode (USB 1F3A:EFE8; Windows needs the driver "WinUsb Device" once, see Debug > Debug targets)
;   2. press F7 to stop at _start and step through the loop (the registers show 64 bits), or F9 to run it: the
;      program returns with ret, and the output window shows a0 (5050) and a1
; A running program cannot be paused over FEL: set a breakpoint (F5) before it runs into a loop. The board needs
; no new plugging between two starts as long as the programs stop or return.
;
; RV64: the registers have 64 bits; ret goes back to the address in ra, which the debugger has set (its end mark).
; sp starts at 0x27800; before ret it must be the one of the start.
.target d1
.arch riscv64
.imagebase 0x20000

_start:
  li   a0, 0              ; the sum
  li   t0, 100            ; the next number to add
loop:
  add  a0, a0, t0
  addi t0, t0, -1
  bnez t0, loop
  li   a1, 100            ; a1: how many numbers
  ret
