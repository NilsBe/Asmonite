; The console of the ESP32-C3: the network at its prompt (stage K5), for the line .include "console_net.asm" of
; console.asm (after console_wifi.asm).
;
; The network itself is in the WiFi service (version 4, wlan\wlannet_c3.asm): it answers ARP and ping, gets the
; address by DHCP and keeps the connection that wifi_begin began, whatever runs (its tick: also while a program
; computes). The console only says what changed: net_tick (from get_char when net_keep is set, and from wait_byte
; between the packets of a program on the PC) lets the tasks of the WiFi run a millisecond (wifi_wait), drops the
; frames of the ring (they are for programs; a program that comes later wants new ones) and looks at the address
; (wifi_get_ip): "WiFi: connected, address a.b.c.d (esp32c3-xxxx.local)" when there is a new one, "WiFi: no connection."
; when it is gone, each on a line of its own, then the prompt and the line typed so far again (net_say).

SVC_WAIT     equ SVC + 0x18
SVC_RECV     equ SVC + 0x28
SVC_BEGIN    equ SVC + 0x40
SVC_GETIP    equ SVC + 0x48
SVC_NAME     equ SVC + 0x4C
NETRX        equ 0x3FCD9400             ; a frame that came (1600 bytes)
NET_RXMAX    equ 1600

; net_tick(): see the head of the file. s0 frames left
net_tick:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    li   a0, 1
    li   t0, SVC_WAIT
    jalr ra, 0(t0)
    li   s0, 8
ntk_frame:
    li   a0, NETRX
    li   a1, NET_RXMAX
    li   a2, 0
    li   t0, SVC_RECV
    jalr ra, 0(t0)
    beqz a0, ntk_ip
    addi s0, s0, -1
    bnez s0, ntk_frame
ntk_ip:
    li   a0, 0                          ; the address now
    li   t0, SVC_GETIP
    jalr ra, 0(t0)
    la   t0, net_ip
    lw   t1, 0(t0)
    beq  a0, t1, ntk_end
    sw   a0, 0(t0)
    beqz a0, ntk_lost
    la   a0, s_ntconn
    la   a1, net_ip
    call net_say
    j    ntk_end
ntk_lost:
    la   a0, s_ntlost
    li   a1, 0
    call net_say
ntk_end:
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; net_start(): the console watches a connection begun anew (wl_start; the service keeps it): no address yet
net_start:
    la   t0, net_ip
    sw   zero, 0(t0)
    la   t0, net_keep
    li   t1, 1
    sw   t1, 0(t0)
    ret

; net_stop(): the console no longer watches the connection; no address
net_stop:
    la   t0, net_keep
    sw   zero, 0(t0)
    la   t0, net_ip
    sw   zero, 0(t0)
    ret

; net_say(text, ip): a note on a line of its own: the text, the address at ip (0: none) with the name of the board in
; brackets and a full stop; then the prompt and the line typed so far again (only at the prompt)
net_say:
    la   t0, pk_mode                    ; between packets (wait_byte): no text into them
    lw   t0, 0(t0)
    beqz t0, nts_go
    ret
nts_go:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   a0, 8(sp)
    sw   a1, 4(sp)
    la   a0, s_crlf
    call print
    lw   a0, 8(sp)
    lw   a1, 4(sp)
    call net_say_plain
    la   t0, at_prompt
    lw   t0, 0(t0)
    beqz t0, nts_ret
    la   a0, s_prompt
    call print
    la   a0, line
    call print
nts_ret:
    call flush
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; net_say_plain(text, ip): the text, the address at ip (0: none) with the name of the board in brackets (wifi_name), a
; full stop and the end of the line
net_say_plain:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    mv   s0, a1
    call print
    beqz s0, ntq_end
    mv   a0, s0
    call net_print_ip
    li   t0, SVC_NAME
    jalr ra, 0(t0)
    beqz a0, ntq_end
    sw   a0, 4(sp)
    la   a0, s_ntname1
    call print
    lw   a0, 4(sp)
    call print
    la   a0, s_ntname2
    call print
ntq_end:
    la   a0, s_dotcrlf
    call print
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret

; the 4 bytes at a0 as a.b.c.d. s0 the address, s1 the byte
net_print_ip:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    mv   s0, a0
    li   s1, 0
ntp_next:
    add  t0, s0, s1
    lbu  a0, 0(t0)
    call print_dec
    addi s1, s1, 1
    li   t0, 4
    beq  s1, t0, ntp_done
    li   a0, '.'
    call put_char
    j    ntp_next
ntp_done:
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret
