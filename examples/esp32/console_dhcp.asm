; The DHCP part of the consoles of the ESP32 and the ESP32-S3 (examples/esp32/console.asm and
; examples/esp32s3/console.asm include it; not a program of its own). Each console gives the differences:
;   NETTX, NETRX       the buffers of the frames (equ)
;   NETNAME            32 bytes that stay: the name of the board in use (equ)
;   lit_svchead        the table of the WiFi service where its version is read (the S3: the bus of the data)
;   lit_svccall        the same table for the calls of its entries (the S3: the bus of the instructions)
;   CON_S3             defined on the S3
; and the words of vars from +224 (see net_tick); the texts are in console_dhcp_data.asm. The name of the board (name,
; mDNS) is here too, after the DHCP part.

; ---------- the address of the board: DHCP in the console (the WiFi service from version 10) ----------
; While the console waits at its prompt, net_tick looks at the WiFi now and then (lit_netgap): when the station is
; connected and the board has no address yet, the console asks for one by DHCP (DISCOVER to all, the OFFER, REQUEST,
; the ACK; each again after 2 s, four times, then again after 30 s) and gives it to the WiFi service (wifi_set_ip): from
; then on the service answers ARP and ping for it on core 1, also while a program runs. The console says "WiFi:
; connected, address a.b.c.d (name.local)" (again when the address changes) and "WiFi: no connection." when it is gone,
; each on a line of its own, then the prompt and what was typed again. At half the time of the lease it asks again (the
; address stays meanwhile). A new connection (one in the background after a loss, or one of a program) clears the
; address in the service: the console asks again. Its name for the router (option 12) is the name of the board
; (net_name_make). With an address the console reads the frames that come while it waits and answers mDNS for
; name.local (net_listen). The words in vars from +224; the frames in NETTX and NETRX.

; the milliseconds of the WiFi service (its timer: right also after a program)
  align 4
net_now:
  entry a1, 32
  l32r  a3, lit_svccall
  addi  a8, a3, 64                   ; wifi_millis
  callx8 a8
  mov   a2, a10
  retw

; the a4 bytes at a3 to a2
  align 4
net_copy:
  entry a1, 32
  beqz  a4, nwy_done
nwy_next:
  l8ui  a5, a3, 0
  s8i   a5, a2, 0
  addi  a2, a2, 1
  addi  a3, a3, 1
  addi  a4, a4, -1
  bnez  a4, nwy_next
nwy_done:
  retw

; the byte a2 as two hex digits (small letters) to a3
  align 4
net_hex:
  entry a1, 32
  movi  a6, 2
  extui a4, a2, 4, 4
nwx_digit:
  addi  a5, a4, 48
  movi  a7, 10
  bltu  a4, a7, nwx_put
  addi  a5, a4, 87                   ; 'a' - 10
nwx_put:
  s8i   a5, a3, 0
  addi  a3, a3, 1
  extui a4, a2, 0, 4
  addi  a6, a6, -1
  bnez  a6, nwx_digit
  retw

; the address at a2 (4 bytes) as a.b.c.d
  align 4
net_print_ip:
  entry a1, 32
  movi  a3, 0
nwp_next:
  add   a4, a2, a3
  l8ui  a10, a4, 0
  call8 print_dec
  addi  a3, a3, 1
  movi  a4, 4
  beq   a3, a4, nwp_done
  movi  a10, 46                      ; '.'
  call8 put_char
  j     nwp_next
nwp_done:
  retw

; a message on a line of its own: the text a2, the address at a3 (0: none); then the prompt and the line again
  align 4
net_say:
  entry a1, 32
  l32r  a10, lit_s_crlf
  call8 print
  mov   a10, a2
  call8 print
  beqz  a3, nws_line
  mov   a10, a3
  call8 net_print_ip
  l32r  a10, lit_s_netin             ; " (name.local)"
  call8 print
  l32r  a10, lit_netnamebuf
  call8 print
  l32r  a10, lit_s_netlocal
  call8 print
nws_line:
  l32r  a10, lit_s_crlf
  call8 print
  l32r  a10, lit_s_prompt
  call8 print
  l32r  a10, lit_line
  call8 print
  retw

; the checksum of the IPv4 header at a2 (20 bytes, its checksum 0 so far) into its place
  align 4
net_ipsum:
  entry a1, 32
  movi  a3, 0
  movi  a4, 10
nwc_next:
  l8ui  a5, a2, 0
  l8ui  a6, a2, 1
  slli  a5, a5, 8
  or    a5, a5, a6
  add   a3, a3, a5
  addi  a2, a2, 2
  addi  a4, a4, -1
  bnez  a4, nwc_next
  extui a5, a3, 16, 16               ; the carries back in, twice
  extui a3, a3, 0, 16
  add   a3, a3, a5
  extui a5, a3, 16, 16
  extui a3, a3, 0, 16
  add   a3, a3, a5
  movi  a5, -1
  xor   a3, a3, a5
  addi  a2, a2, -20
  s8i   a3, a2, 11
  srli  a3, a3, 8
  s8i   a3, a2, 10
  retw

; a DHCP message to all: a2 1 DISCOVER, 2 REQUEST (the address offered, the server)
  align 4
net_send:
  entry a1, 32
  l32r  a4, lit_nettx
  mov   a5, a4                       ; all 344 bytes 0
  movi  a6, 86
  movi  a7, 0
nwd_clear:
  s32i  a7, a5, 0
  addi  a5, a5, 4
  addi  a6, a6, -1
  bnez  a6, nwd_clear
  movi  a7, 255                      ; to all: the MAC and the address
  s8i   a7, a4, 0
  s8i   a7, a4, 1
  s8i   a7, a4, 2
  s8i   a7, a4, 3
  s8i   a7, a4, 4
  s8i   a7, a4, 5
  s8i   a7, a4, 30
  s8i   a7, a4, 31
  s8i   a7, a4, 32
  s8i   a7, a4, 33
  l32r  a5, lit_nethead              ; the fixed bytes
nwd_head:
  l8ui  a6, a5, 0
  beqz  a6, nwd_mac
  l8ui  a7, a5, 1
  add   a6, a4, a6
  s8i   a7, a6, 0
  addi  a5, a5, 2
  j     nwd_head
nwd_mac:
  addi  a10, a4, 6                   ; from the MAC of the station, also in chaddr
  l32r  a3, lit_svccall
  addi  a8, a3, 52                   ; wifi_mac
  callx8 a8
  addi  a10, a4, 70
  addi  a11, a4, 6
  movi  a12, 6
  call8 net_copy
  l32r  a5, lit_vars                 ; the xid
  addmi a11, a5, 256
  addi  a11, a11, -16
  addi  a10, a4, 46
  movi  a12, 4
  call8 net_copy
  addmi a7, a4, 256                  ; the magic cookie at 278, the options from 282
  movi  a6, 0x63
  s8i   a6, a7, 22
  movi  a6, 0x82
  s8i   a6, a7, 23
  movi  a6, 0x53
  s8i   a6, a7, 24
  movi  a6, 0x63
  s8i   a6, a7, 25
  addi  a6, a7, 26
  movi  a7, 53                       ; 53: the type, 1 DISCOVER or 3 REQUEST
  s8i   a7, a6, 0
  movi  a7, 1
  s8i   a7, a6, 1
  slli  a7, a2, 1
  addi  a7, a7, -1
  s8i   a7, a6, 2
  addi  a6, a6, 3
  bnei  a2, 2, nwd_name
  movi  a7, 50                       ; 50: the address asked for, 54: the server
  s8i   a7, a6, 0
  movi  a7, 4
  s8i   a7, a6, 1
  s8i   a7, a6, 7
  movi  a7, 54
  s8i   a7, a6, 6
  addi  a10, a6, 2
  addmi a11, a5, 256
  addi  a11, a11, -12
  movi  a12, 4
  call8 net_copy
  addi  a10, a6, 8
  addmi a11, a5, 256
  addi  a11, a11, -8
  movi  a12, 4
  call8 net_copy
  addi  a6, a6, 12
nwd_name:
  movi  a7, 12                       ; 12: the name of the board (NETNAME, net_name_make)
  s8i   a7, a6, 0
  l32r  a10, lit_netnamebuf
  call8 strlen
  s8i   a10, a6, 1
  mov   a7, a10
  addi  a10, a6, 2
  l32r  a11, lit_netnamebuf
  mov   a12, a7
  call8 net_copy
  add   a6, a6, a7
  movi  a7, 255                      ; the end
  s8i   a7, a6, 2
  addi  a10, a4, 14
  call8 net_ipsum
  mov   a10, a4                      ; 342 bytes: the BOOTP message 300 long, as servers want it
  movi  a11, 342
  l32r  a3, lit_svccall
  addi  a8, a3, 44                   ; wifi_send
  callx8 a8
  retw

; the option a2 of the DHCP message in NETRX (a3 bytes long): the address of its data, 0 if it has none
  align 4
net_opt:
  entry a1, 32
  l32r  a4, lit_netrx
  add   a5, a4, a3
  addmi a4, a4, 256
  addi  a4, a4, 26
nwo_next:
  bgeu  a4, a5, nwo_none
  l8ui  a6, a4, 0
  movi  a7, 255
  beq   a6, a7, nwo_none
  bnez  a6, nwo_opt
  addi  a4, a4, 1                    ; 0: a pad
  j     nwo_next
nwo_opt:
  beq   a6, a2, nwo_found
  l8ui  a7, a4, 1
  addi  a7, a7, 2
  add   a4, a4, a7
  j     nwo_next
nwo_found:
  addi  a2, a4, 2
  retw
nwo_none:
  movi  a2, 0
  retw

; the frame in NETRX (a2 bytes long): an answer of a DHCP server to our message? The OFFER (state 1): the REQUEST;
; the ACK (state 2): the address to the WiFi service; a NAK: from the start
  align 4
net_frame:
  entry a1, 32
  j     nwf_go
nwf_out:
  retw
nwf_go:
  l32r  a3, lit_netrx
  movi  a5, 300
  blt   a2, a5, nwf_out
  l8ui  a5, a3, 12                   ; IPv4
  bnei  a5, 8, nwf_out
  l8ui  a5, a3, 13
  bnez  a5, nwf_out
  l8ui  a5, a3, 14
  movi  a6, 0x45
  bne   a5, a6, nwf_out
  l8ui  a5, a3, 23                   ; UDP
  movi  a6, 17
  bne   a5, a6, nwf_out
  l8ui  a5, a3, 36                   ; to port 68
  bnez  a5, nwf_out
  l8ui  a5, a3, 37
  movi  a6, 68
  bne   a5, a6, nwf_out
  l8ui  a5, a3, 42                   ; a BOOTP reply
  bnei  a5, 2, nwf_out
  l32r  a4, lit_vars                 ; to our xid (its bytes as net_send put them)
  addmi a4, a4, 256
  addi  a4, a4, -16                  ; +240
  movi  a6, 0
nwf_xid:
  add   a7, a3, a6
  l8ui  a5, a7, 46
  add   a7, a4, a6
  l8ui  a7, a7, 0
  bne   a5, a7, nwf_out
  addi  a6, a6, 1
  bltui a6, 4, nwf_xid
  movi  a10, 53
  mov   a11, a2
  call8 net_opt
  beqz  a10, nwf_no
  l8ui  a6, a10, 0                   ; its type
  l32r  a4, lit_vars
  l32i  a7, a4, 228
  bnei  a6, 2, nwf_ack
  bnei  a7, 1, nwf_no
  addmi a10, a4, 256
  addi  a10, a10, -12                 ; the OFFER: its address and server
  addi  a11, a3, 58
  movi  a12, 4
  call8 net_copy
  movi  a10, 54
  mov   a11, a2
  call8 net_opt
  beqz  a10, nwf_no
  mov   a11, a10
  addmi a10, a4, 256
  addi  a10, a10, -8
  movi  a12, 4
  call8 net_copy
  movi  a6, 2
  s32i  a6, a4, 228
  movi  a6, 0
  s32i  a6, a4, 236
  call8 net_now
  s32i  a10, a4, 232
  movi  a10, 2
  call8 net_send
nwf_no:
  retw
nwf_ack:
  bnei  a7, 2, nwf_no
  bnei  a6, 6, nwf_isack
  movi  a6, 0                        ; a NAK: from the start
  s32i  a6, a4, 228
  retw
nwf_isack:
  bnei  a6, 5, nwf_no
  addi  a10, a3, 58                  ; the ACK: the address to the service
  l32r  a5, lit_svccall
  addi  a8, a5, 96                   ; wifi_set_ip
  callx8 a8
  movi  a10, 51                      ; the lease: half of it, at most a day
  mov   a11, a2
  call8 net_opt
  l32r  a6, lit_netday
  beqz  a10, nwf_lease
  l8ui  a5, a10, 0
  l8ui  a7, a10, 1
  slli  a5, a5, 8
  or    a5, a5, a7
  l8ui  a7, a10, 2
  slli  a5, a5, 8
  or    a5, a5, a7
  l8ui  a7, a10, 3
  slli  a5, a5, 8
  or    a5, a5, a7
  beqz  a5, nwf_lease
  bgeu  a5, a6, nwf_lease
  mov   a6, a5
nwf_lease:
  movi  a5, 500
  mull  a6, a6, a5
  call8 net_now
  add   a6, a10, a6
  s32i  a6, a4, 252
  movi  a6, 3
  s32i  a6, a4, 228
  l8ui  a5, a3, 61                   ; the address as a word (its bytes in their order)
  l8ui  a6, a3, 60
  slli  a5, a5, 8
  or    a5, a5, a6
  l8ui  a6, a3, 59
  slli  a5, a5, 8
  or    a5, a5, a6
  l8ui  a6, a3, 58
  slli  a5, a5, 8
  or    a5, a5, a6
  l32i  a6, a4, 256
  beq   a5, a6, nwf_done              ; said already
  s32i  a5, a4, 256
  l32r  a10, lit_s_netup
  addmi a11, a4, 256
  addi  a11, a11, 0
  call8 net_say
  movi  a10, 0                       ; mDNS: the name told to all
  call8 net_answer
nwf_done:
  retw

; at the prompt, from get_char: the WiFi now and then (see above)
  align 4
net_tick:
  entry a1, 32
  l32r  a4, lit_vars
  rsr   a6, ccount
  l32i  a7, a4, 260
  sub   a7, a6, a7
  l32r  a8, lit_netgap
  bgeu  a7, a8, nwt_look
  j     nwt_ret
nwt_look:
  s32i  a6, a4, 260
  call8 svc_runs
  beqz  a10, nwt_gone
  l32r  a3, lit_svchead
  l32i  a5, a3, 32
  movi  a6, 10
  bgeu  a5, a6, nwt_new              ; an older service: no wifi_set_ip
  j     nwt_ret
nwt_new:
.if defined(CON_S3)
  l32r  a3, lit_svccall              ; (the entries on the bus of the instructions)
.endif
  addi  a8, a3, 40                   ; wifi_status: bit 0 connected
  callx8 a8
  bbsi  a10, 0, nwt_conn
  j     nwt_gone
nwt_conn:
  l32r  a4, lit_vars
  l32i  a5, a4, 228
  beqz  a5, nwt_start
  bnei  a5, 3, nwt_not3
  call8 net_listen                   ; an address: mDNS
  l32r  a10, lit_netrx               ; is it still in the service, is it time to ask again?
  l32r  a3, lit_svccall
  addi  a8, a3, 100                  ; wifi_get_ip
  callx8 a8
  beqz  a10, nwt_start                ; a new connection cleared it
  call8 net_now
  l32i  a7, a4, 252
  sub   a7, a10, a7
  bltz  a7, nwt_ret
  j     nwt_start                     ; ask again (the address stays meanwhile)
nwt_not3:
  bnei  a5, 4, nwt_wait
  call8 net_now                      ; no answer before: again after 30 s
  l32i  a7, a4, 232
  sub   a7, a10, a7
  l32r  a8, lit_net30s
  bltu  a7, a8, nwt_ret
  j     nwt_start
nwt_wait:
  movi  a7, 8                        ; 1, 2: what came (up to 8 frames), then the time
nwt_frame:
  l32r  a10, lit_netrx
  movi  a11, 1600
  movi  a12, 0
  l32r  a3, lit_svccall
  addi  a8, a3, 48                   ; wifi_recv
  callx8 a8
  beqz  a10, nwt_time
  call8 net_frame
  addi  a7, a7, -1
  bnez  a7, nwt_frame
nwt_time:
  l32i  a5, a4, 228
  movi  a6, 3
  bgeu  a5, a6, nwt_ret
  call8 net_now
  l32i  a7, a4, 232
  sub   a7, a10, a7
  movi  a8, 2000
  bltu  a7, a8, nwt_ret
  s32i  a10, a4, 232
  l32i  a7, a4, 236
  addi  a7, a7, 1
  s32i  a7, a4, 236
  bltui a7, 4, nwt_again
  movi  a7, 4                        ; no answer: again after 30 s
  s32i  a7, a4, 228
  l32r  a10, lit_s_netfail
  movi  a11, 0
  call8 net_say
  retw
nwt_again:
  mov   a10, a5                      ; the message again
  call8 net_send
  retw
nwt_start:
  call8 net_name_make                ; the name for the router and mDNS (a name set may have changed it)
  rsr   a7, ccount                   ; a new xid
  s32i  a7, a4, 240
  movi  a7, 0
  s32i  a7, a4, 236
  movi  a7, 1
  s32i  a7, a4, 228
  call8 net_now
  s32i  a10, a4, 232
  movi  a10, 1
  call8 net_send
nwt_ret:
  retw
nwt_gone:
  l32r  a4, lit_vars
  movi  a5, 0
  s32i  a5, a4, 228
  l32i  a6, a4, 256
  beqz  a6, nwt_ret
  s32i  a5, a4, 256
  l32r  a10, lit_s_netgone
  movi  a11, 0
  call8 net_say
  retw

; ---------- the name of the board: name, DHCP (option 12), mDNS (name.local) ----------
; The record of the WiFi network (cred_load, cred_save of the console) keeps it at +80: up to 31 characters and a 0
; (0 at +80: none); a record without a network (its length at +12 is 0) keeps only the name, and wlan set and wlan clear
; leave the name as it is. Without one the board is net_name (the chip: "esp32-", "esp32s3-") and the last two bytes of
; its MAC in hex, as inc/net.abel names it. NETNAME holds the name in use, vars+264 the MAC (6 bytes, from wifi_mac once
; the WiFi runs; zeros: not known yet).

; 1 if the board keeps a network (a record with one; cred_load), else 0
  align 4
cred_net:
  entry a1, 32
  call8 cred_load
  movi  a2, 0
  beqz  a10, nmc_done
  l32r  a3, lit_credbuf
  l32i  a3, a3, 12
  beqz  a3, nmc_done
  movi  a2, 1
nmc_done:
  retw

; wlan clear with a name or a password for telnet kept: the record without its network (they stay); 1 if done
; so, 0 if the board keeps neither (then both sectors are erased, as before)
  align 4
cred_clear_net:
  entry a1, 32
  movi  a2, 0
  call8 cred_load
  beqz  a10, nmz_done
  l32r  a3, lit_credbuf
  l8ui  a4, a3, 80
  bnez  a4, nmz_keep
  call8 pw_is_set                    ; no name: a password for telnet?
  beqz  a10, nmz_done
nmz_keep:
  movi  a4, 0                        ; +8 .. +79: the flags, the network, its key
  movi  a5, 8
nmz_zero:
  add   a6, a3, a5
  s32i  a4, a6, 0
  addi  a5, a5, 4
  movi  a6, 80
  bne   a5, a6, nmz_zero
  call8 cred_save
  movi  a2, 1
  beqz  a10, nmz_done
  l32r  a10, lit_s_flasherr
  call8 print
nmz_done:
  retw

; the MAC into vars+264 when it is not known yet and the WiFi service runs
  align 4
net_mac:
  entry a1, 32
  l32r  a2, lit_vars
  addmi a2, a2, 256
  addi  a2, a2, 8                    ; +264
  l32i  a3, a2, 0
  l32i  a4, a2, 4
  or    a3, a3, a4
  bnez  a3, nmm_done
  call8 svc_runs
  beqz  a10, nmm_done
  mov   a10, a2
  l32r  a3, lit_svccall
  addi  a8, a3, 52                   ; wifi_mac
  callx8 a8
nmm_done:
  retw

; the name in use into NETNAME (with its 0): the one of name set, else the one of the MAC ("????" while the MAC is not
; known: the WiFi has not run yet); 1 if it is one of name set, else 0
  align 4
net_name_make:
  entry a1, 32
  call8 net_mac
  call8 net_name_put
  mov   a2, a10
  retw

; the same without asking the WiFi service for the MAC (net_name_put: the one in vars+264, "????" while it is not
; known): for the packet N, which must not wait for core 1 (wifi_mac waits while the WiFi starts: 3 s)
  align 4
net_name_put:
  entry a1, 32
  l32r  a4, lit_netnamebuf
  call8 cred_load
  beqz  a10, nmk_mac
  l32r  a3, lit_credbuf
  l8ui  a5, a3, 80
  beqz  a5, nmk_mac
  mov   a10, a4
  addi  a11, a3, 80
  movi  a12, 32
  call8 net_copy
  movi  a5, 0
  s8i   a5, a4, 31
  movi  a2, 1
  retw
nmk_mac:
  l32r  a3, lit_netname              ; the prefix of the chip
nmk_pre:
  l8ui  a5, a3, 0
  beqz  a5, nmk_hex
  s8i   a5, a4, 0
  addi  a3, a3, 1
  addi  a4, a4, 1
  j     nmk_pre
nmk_hex:
  l32r  a3, lit_vars
  addmi a3, a3, 256
  l32i  a5, a3, 8                    ; the MAC known?
  l32i  a6, a3, 12
  or    a5, a5, a6
  bnez  a5, nmk_known
  movi  a5, 63                       ; '?'
  s8i   a5, a4, 0
  s8i   a5, a4, 1
  s8i   a5, a4, 2
  s8i   a5, a4, 3
  j     nmk_end
nmk_known:
  l8ui  a10, a3, 12                  ; +268, +269: the last two bytes of the MAC
  mov   a11, a4
  call8 net_hex
  l8ui  a10, a3, 13
  addi  a11, a4, 2
  call8 net_hex
nmk_end:
  movi  a5, 0
  s8i   a5, a4, 4
  movi  a2, 0
  retw

; NETNAME.local as the labels of DNS at a2: the place behind them in a2
  align 4
net_put_name:
  entry a1, 32
  l32r  a10, lit_netnamebuf
  call8 strlen
  mov   a4, a10
  s8i   a4, a2, 0
  addi  a10, a2, 1
  l32r  a11, lit_netnamebuf
  mov   a12, a4
  call8 net_copy
  add   a2, a2, a4
  movi  a5, 5
  s8i   a5, a2, 1
  addi  a10, a2, 2
  l32r  a11, lit_s_netlocal
  addi  a11, a11, 1                  ; "local" of ".local)"
  movi  a12, 5
  call8 net_copy
  movi  a5, 0
  s8i   a5, a2, 7
  addi  a2, a2, 8
  retw

; the bytes a3 .. a3 + a4 - 1 are the text a2 (small letters; big ones of the frame taken as small): 1, else 0
  align 4
net_same:
  entry a1, 32
  movi  a7, 0
nms_next:
  beq   a7, a4, nms_yes
  add   a5, a3, a7
  l8ui  a5, a5, 0
  addi  a6, a5, -65                  ; 'A' .. 'Z': small
  movi  a8, 26
  bgeu  a6, a8, nms_cmp
  addi  a5, a5, 32
nms_cmp:
  add   a6, a2, a7
  l8ui  a6, a6, 0
  bne   a5, a6, nms_no
  addi  a7, a7, 1
  j     nms_next
nms_yes:
  movi  a2, 1
  retw
nms_no:
  movi  a2, 0
  retw

; the A record of NETNAME.local (the address said last, vars+256) in an answer of mDNS: a2 0: to all (224.0.0.251:5353,
; its class with the bit "flush the cache", 120 s); else to a resolver that asked from another port than 5353 (the
; question in NETRX: its id and its question again, 10 s, as RFC 6762 wants it). Built in NETTX
  align 4
net_answer:
  entry a1, 32
  l32r  a4, lit_nettx
  l32r  a3, lit_netrx
  movi  a5, 0                        ; the head of DNS: 12 bytes
  s32i  a5, a4, 44
  s32i  a5, a4, 48
  s32i  a5, a4, 52
  movi  a5, 0x84                     ; an answer, authoritative
  s8i   a5, a4, 44
  movi  a5, 1                        ; one record
  s8i   a5, a4, 49
  beqz  a2, nma_multi
  l8ui  a5, a3, 42                   ; the id of the question
  s8i   a5, a4, 42
  l8ui  a5, a3, 43
  s8i   a5, a4, 43
  movi  a5, 1                        ; the question again
  s8i   a5, a4, 47
  addi  a10, a4, 54
  call8 net_put_name
  mov   a6, a10
  movi  a5, 0                        ; its type as it asked, class IN
  s8i   a5, a6, 2
  l32r  a7, lit_netrx                ; (the type: behind the name of the question)
  l32r  a10, lit_netnamebuf
  call8 strlen
  add   a7, a7, a10
  l8ui  a5, a7, 62                   ; 54 + name + 1 + 6 + 1: the type
  s8i   a5, a6, 0
  l8ui  a5, a7, 63
  s8i   a5, a6, 1
  movi  a5, 1
  s8i   a5, a6, 3
  addi  a10, a6, 4
  j     nma_record
nma_multi:
  movi  a5, 0                        ; the id 0
  s8i   a5, a4, 42
  s8i   a5, a4, 43
  addi  a10, a4, 54
nma_record:
  call8 net_put_name
  mov   a6, a10
  movi  a5, 0
  s8i   a5, a6, 0                    ; type A
  movi  a5, 1
  s8i   a5, a6, 1
  s8i   a5, a6, 3                    ; class IN
  movi  a5, 0
  s8i   a5, a6, 2
  s8i   a5, a6, 4                    ; the time to live
  s8i   a5, a6, 5
  s8i   a5, a6, 6
  s8i   a5, a6, 8                    ; the length of the data: 4
  movi  a5, 10
  s8i   a5, a6, 7
  bnez  a2, nma_data
  movi  a5, 0x80                     ; to all: flush the cache, 120 s
  s8i   a5, a6, 2
  movi  a5, 120
  s8i   a5, a6, 7
nma_data:
  movi  a5, 4
  s8i   a5, a6, 9
  l32r  a7, lit_vars                 ; the address
  addmi a7, a7, 256
  l8ui  a5, a7, 0
  s8i   a5, a6, 10
  l8ui  a5, a7, 1
  s8i   a5, a6, 11
  l8ui  a5, a7, 2
  s8i   a5, a6, 12
  l8ui  a5, a7, 3
  s8i   a5, a6, 13
  addi  a6, a6, 14
  sub   a6, a6, a4                   ; the length of the frame
  addi  a7, a6, -14                  ; of the packet of IPv4
  ; the head of Ethernet: to all (01:00:5E:00:00:FB) or to the one who asked; from our MAC (vars+264)
  movi  a5, 0x01
  s8i   a5, a4, 0
  movi  a5, 0
  s8i   a5, a4, 1
  s8i   a5, a4, 3
  s8i   a5, a4, 4
  movi  a5, 0x5E
  s8i   a5, a4, 2
  movi  a5, 0xFB
  s8i   a5, a4, 5
  beqz  a2, nma_from
  mov   a10, a4
  addi  a11, a3, 6
  movi  a12, 6
  call8 net_copy
nma_from:
  addi  a10, a4, 6
  l32r  a11, lit_vars
  addmi a11, a11, 256
  addi  a11, a11, 8
  movi  a12, 6
  call8 net_copy
  movi  a5, 0x08
  s8i   a5, a4, 12
  movi  a5, 0
  s8i   a5, a4, 13
  ; IPv4: 45 00, its length, 0, 0, the time to live 255 (mDNS: from this network), UDP, the checksum later
  movi  a5, 0x45
  s8i   a5, a4, 14
  movi  a5, 0
  s8i   a5, a4, 15
  s8i   a5, a4, 18
  s8i   a5, a4, 19
  s8i   a5, a4, 20
  s8i   a5, a4, 21
  s8i   a5, a4, 24
  s8i   a5, a4, 25
  srli  a5, a7, 8
  s8i   a5, a4, 16
  s8i   a7, a4, 17
  movi  a5, 255
  s8i   a5, a4, 22
  movi  a5, 17
  s8i   a5, a4, 23
  addi  a10, a4, 26                  ; from our address
  l32r  a11, lit_vars
  addmi a11, a11, 256
  movi  a12, 4
  call8 net_copy
  movi  a5, 224                      ; to 224.0.0.251, or to the one who asked
  s8i   a5, a4, 30
  movi  a5, 0
  s8i   a5, a4, 31
  s8i   a5, a4, 32
  movi  a5, 251
  s8i   a5, a4, 33
  beqz  a2, nma_udp
  addi  a10, a4, 30
  addi  a11, a3, 26
  movi  a12, 4
  call8 net_copy
nma_udp:
  movi  a5, 0x14                     ; UDP: from 5353, to 5353 or the port that asked
  s8i   a5, a4, 34
  s8i   a5, a4, 36
  movi  a5, 0xE9
  s8i   a5, a4, 35
  s8i   a5, a4, 37
  beqz  a2, nma_len
  l8ui  a5, a3, 34
  s8i   a5, a4, 36
  l8ui  a5, a3, 35
  s8i   a5, a4, 37
nma_len:
  addi  a5, a7, -20                  ; its length; no checksum
  srli  a8, a5, 8
  s8i   a8, a4, 38
  s8i   a5, a4, 39
  movi  a5, 0
  s8i   a5, a4, 40
  s8i   a5, a4, 41
  addi  a10, a4, 14
  call8 net_ipsum
  mov   a10, a4
  mov   a11, a6
  l32r  a3, lit_svccall
  addi  a8, a3, 44                   ; wifi_send
  callx8 a8
  retw

; the frame in NETRX (a2 bytes long): its first question one of mDNS for NETNAME.local (type A or ANY, class IN)?
; Then the answer (net_answer). Later questions of a message are not looked at.
  align 4
net_mdns:
  entry a1, 32
  j     nmq_go
nmq_out:
  retw
nmq_go:
  l32r  a3, lit_netrx
  movi  a5, 60
  blt   a2, a5, nmq_out
  l8ui  a5, a3, 12                   ; IPv4
  bnei  a5, 8, nmq_out
  l8ui  a5, a3, 13
  bnez  a5, nmq_out
  l8ui  a5, a3, 14
  movi  a6, 0x45
  bne   a5, a6, nmq_out
  l8ui  a5, a3, 23                   ; UDP
  movi  a6, 17
  bne   a5, a6, nmq_out
  l8ui  a5, a3, 36                   ; to port 5353
  movi  a6, 0x14
  bne   a5, a6, nmq_out
  l8ui  a5, a3, 37
  movi  a6, 0xE9
  bne   a5, a6, nmq_out
  l8ui  a5, a3, 44                   ; a question, not an answer
  bbsi  a5, 7, nmq_out
  l8ui  a5, a3, 46
  l8ui  a6, a3, 47
  or    a5, a5, a6
  beqz  a5, nmq_out
  l32r  a10, lit_netnamebuf          ; the first label: NETNAME
  call8 strlen
  mov   a4, a10
  l8ui  a5, a3, 54
  bne   a5, a4, nmq_out
  add   a7, a4, a3                   ; behind it, at 55 + its length (in a7 + 55): "local"
  l32r  a10, lit_netnamebuf
  addi  a11, a3, 55
  mov   a12, a4
  call8 net_same
  beqz  a10, nmq_out
  l8ui  a5, a7, 55
  bnei  a5, 5, nmq_out
  l32r  a10, lit_s_netlocal
  addi  a10, a10, 1
  addi  a11, a7, 56
  movi  a12, 5
  call8 net_same
  beqz  a10, nmq_out
  l8ui  a5, a7, 61                   ; the end of the name
  bnez  a5, nmq_out
  l8ui  a5, a7, 62                   ; type A (1) or ANY (255)
  bnez  a5, nmq_out
  l8ui  a5, a7, 63
  beqi  a5, 1, nmq_class
  movi  a6, 255
  beq   a5, a6, nmq_class
  j     nmq_out
nmq_class:
  l8ui  a5, a7, 64                   ; class IN (the bit "unicast answer" left out)
  extui a5, a5, 0, 7
  bnez  a5, nmq_out
  l8ui  a5, a7, 65
  beqi  a5, 1, nmq_ours
  j     nmq_out
nmq_ours:
  l8ui  a5, a3, 34                   ; from port 5353 (0x14E9): an answer to all; else to the one who asked
  movi  a6, 0x14
  xor   a5, a5, a6
  l8ui  a6, a3, 35
  movi  a8, 0xE9
  xor   a6, a6, a8
  or    a10, a5, a6
  call8 net_answer
  retw

; at the prompt with an address: the frames that came (up to 8 a turn), a question of mDNS for NETNAME.local answered
  align 4
net_listen:
  entry a1, 32
  movi  a7, 8
nml_next:
  l32r  a10, lit_netrx
  movi  a11, 1600
  movi  a12, 0
  l32r  a3, lit_svccall
  addi  a8, a3, 48                   ; wifi_recv
  callx8 a8
  beqz  a10, nml_done
  call8 net_mdns
  addi  a7, a7, -1
  bnez  a7, nml_next
nml_done:
  retw

; name: the name of the board (a2 the rest of the line): name shows it, name set <name> gives it another one (letters,
; digits and '-', up to 31; kept in the record of the network), name clear: the one of the MAC again. A new name: the
; console asks for its address again (DHCP), so that the router learns it, and says it with the name
  align 4
cmd_name:
  entry a1, 32
  l8ui  a3, a2, 0
  beqz  a3, nmn_show
  mov   a10, a2
  l32r  a11, lit_c_clear
  call8 streq
  bnez  a10, nmn_clear
  l8ui  a3, a2, 0                    ; "set " and the name
  movi  a4, 115
  bne   a3, a4, nmn_use
  l8ui  a3, a2, 1
  movi  a4, 101
  bne   a3, a4, nmn_use
  l8ui  a3, a2, 2
  movi  a4, 116
  bne   a3, a4, nmn_use
  l8ui  a3, a2, 3
  movi  a4, 32
  bne   a3, a4, nmn_use
  addi  a2, a2, 4
  mov   a10, a2                      ; the name: 1 .. 31 of a-z, 0-9, '-' (big letters made small)
  call8 strlen
  beqz  a10, nmn_bad
  movi  a4, 32
  bgeu  a10, a4, nmn_bad
  movi  a3, 0
nmn_char:
  add   a4, a2, a3
  l8ui  a5, a4, 0
  beqz  a5, nmn_set
  addi  a6, a5, -65                  ; 'A' .. 'Z': small
  movi  a7, 26
  bgeu  a6, a7, nmn_small
  addi  a5, a5, 32
  s8i   a5, a4, 0
nmn_small:
  addi  a6, a5, -97                  ; 'a' .. 'z'
  movi  a7, 26
  bltu  a6, a7, nmn_ok
  addi  a6, a5, -48                  ; '0' .. '9'
  bltui a6, 10, nmn_ok
  movi  a6, 45                       ; '-'
  bne   a5, a6, nmn_bad
nmn_ok:
  addi  a3, a3, 1
  j     nmn_char
nmn_use:
  l32r  a10, lit_s_nmuse
  call8 print
  retw
nmn_bad:
  l32r  a10, lit_s_nmbad
  call8 print
  retw
nmn_set:
  call8 cred_load                    ; the record of the network (or a new one without a network)
  l32r  a3, lit_credbuf
  bnez  a10, nmn_put
  movi  a4, 0
  movi  a5, 0
nmn_zero:
  add   a6, a3, a5
  s32i  a4, a6, 0
  addi  a5, a5, 4
  movi  a6, 128
  bne   a5, a6, nmn_zero
nmn_put:
  addi  a10, a3, 80                  ; the name at +80, zeros behind it
  movi  a4, 0
  s32i  a4, a10, 28
  s32i  a4, a10, 24
  s32i  a4, a10, 20
  s32i  a4, a10, 16
  s32i  a4, a10, 12
  s32i  a4, a10, 8
  s32i  a4, a10, 4
  s32i  a4, a10, 0
  mov   a10, a2
  call8 strlen
  mov   a12, a10                     ; (a11 after the call: call8 takes a8 .. a15)
  mov   a11, a2
  addi  a10, a3, 80
  call8 net_copy
  j     nmn_save
nmn_clear:
  call8 cred_load
  beqz  a10, nmn_show
  l32r  a3, lit_credbuf
  movi  a4, 0
  s32i  a4, a3, 80
nmn_save:
  call8 cred_save
  beqz  a10, nmn_new
  l32r  a10, lit_s_flasherr
  call8 print
  retw
nmn_new:
  l32r  a4, lit_vars                 ; ask for the address again: the router learns the name, the console says it
  movi  a5, 0
  s32i  a5, a4, 228
  addmi a4, a4, 256
  s32i  a5, a4, 0
nmn_show:
  call8 net_name_make
  mov   a2, a10
  l32r  a10, lit_s_nmis              ; "The name of the board: name (name.local)"
  call8 print
  l32r  a10, lit_netnamebuf
  call8 print
  l32r  a10, lit_s_netin
  call8 print
  l32r  a10, lit_netnamebuf
  call8 print
  l32r  a10, lit_s_netlocal
  call8 print
  l32r  a10, lit_s_crlf
  call8 print
  bnez  a2, nmn_done
  l32r  a10, lit_s_nmmac             ; the one of the MAC: how to give another one
  call8 print
nmn_done:
  retw

; ---------- the password for telnet: passwd ----------
; passwd set asks for it without echo (8 to 63 characters, as WPA2 takes them) and keeps 12 bytes of its key at +112 of
; the record of the network: PBKDF2-SHA1 of the password with the MAC of the board as its salt (wifi_pmk of the WiFi
; service, about 2 s), not the password; LINE and the ring are cleared at once (forget). telnetd of the examples asks
; for it (inc/wifi.abel: wifi_login_check makes the same key). Zeros there: no password, telnetd lets everyone in.

; 1 if the record in CRED (cred_load) keeps a password for telnet, else 0
  align 4
pw_is_set:
  entry a1, 32
  l32r  a3, lit_credbuf
  l32i  a4, a3, 112
  l32i  a5, a3, 116
  or    a4, a4, a5
  l32i  a5, a3, 120
  or    a4, a4, a5
  movi  a2, 0
  beqz  a4, pwi_done
  movi  a2, 1
pwi_done:
  retw

; passwd (a2 the rest of the line): passwd says whether there is one, passwd set gives one, passwd clear takes it away
  align 4
cmd_passwd:
  entry a1, 32
  l8ui  a3, a2, 0
  beqz  a3, pwc_show
  mov   a10, a2
  l32r  a11, lit_c_set
  call8 streq
  bnez  a10, pwc_set
  mov   a10, a2
  l32r  a11, lit_c_clear
  call8 streq
  bnez  a10, pwc_clear
  l32r  a10, lit_s_pwuse
  call8 print
  retw
pwc_show:
  call8 cred_load
  l32r  a2, lit_s_pwnone
  beqz  a10, pwc_say
  call8 pw_is_set
  beqz  a10, pwc_say
  l32r  a2, lit_s_pwset
pwc_say:
  mov   a10, a2
  call8 print
  retw
pwc_clear:
  call8 cred_load
  l32r  a2, lit_s_pwnone
  beqz  a10, pwc_say
  l32r  a3, lit_credbuf
  movi  a4, 0
  s32i  a4, a3, 112
  s32i  a4, a3, 116
  s32i  a4, a3, 120
  call8 cred_save
  l32r  a2, lit_s_pwnone
  beqz  a10, pwc_say
  l32r  a2, lit_s_flasherr
  j     pwc_say
pwc_set:
  call8 svc_ready                    ; the WiFi service (its wifi_pmk) and the MAC of the board
  beqz  a10, pwc_ready
  call8 print
  l32r  a10, lit_s_crlf
  call8 print
  retw
pwc_ready:
  call8 net_mac
  l32r  a10, lit_s_pwask
  call8 print
  l32r  a3, lit_vars
  l32i  a4, a3, 4                    ; the ring: where the password starts
  movi  a5, 1
  s32i  a5, a3, 212                  ; read_line without echo
  l32r  a10, lit_line
  movi  a11, 64
  call8 read_line
  movi  a5, 0
  s32i  a5, a3, 212
  bltz  a10, pwc_forget              ; Ctrl+C
  movi  a5, 8                        ; 8 .. 63 characters
  blt   a10, a5, pwc_bad
  movi  a5, 64
  bge   a10, a5, pwc_bad
  l32r  a10, lit_s_wnkey             ; "computing the key ..."
  call8 print
  l32r  a10, lit_line                ; its key into CHUNK: the salt the MAC (vars+264)
  l32r  a11, lit_vars
  addmi a11, a11, 256
  addi  a11, a11, 8
  movi  a12, 6
  l32r  a13, lit_chunk
  l32r  a8, lit_svcpmk
  callx8 a8
  mov   a7, a10
  mov   a10, a4
  call8 forget
  bnez  a7, pwc_badkey
  call8 cred_load                    ; into the record (a new one without a network if there is none)
  l32r  a3, lit_credbuf
  bnez  a10, pwc_put
  movi  a4, 0
  movi  a5, 0
pwc_zero:
  add   a6, a3, a5
  s32i  a4, a6, 0
  addi  a5, a5, 4
  movi  a6, 128
  bne   a5, a6, pwc_zero
pwc_put:
  addi  a10, a3, 112
  l32r  a11, lit_chunk
  movi  a12, 12
  call8 net_copy
  call8 cred_save
  l32r  a2, lit_s_pwdone
  beqz  a10, pwc_say
  l32r  a2, lit_s_flasherr
  j     pwc_say
pwc_bad:
  mov   a10, a4
  call8 forget
pwc_badkey:
  l32r  a2, lit_s_pwbad
  j     pwc_say
pwc_forget:
  mov   a10, a4
  call8 forget
  retw

; ---------- N: the network of the board for the Board Manager ----------
; k with 48 bytes (in CHUNK): +0 the state as wlan says it (0 the WiFi does not run, 1 on and not connected, 2 it
; connects in the background, 3 connected, 4 off: wlan off), +4 the address the WiFi service answers for (zeros: none
; yet, or a service older than version 10), +8 the MAC (6 bytes; zeros while the console does not know it yet: it asks
; the service at its prompt), +16 the name of the board in use (32 bytes with its 0). It never waits for core 1: an
; answer later than the 1.5 s of TEspConsole would be taken for the answer to the next packet
  align 4
pk_net:
  entry a1, 32
  l32r  a2, lit_chunk
  movi  a3, 0
  movi  a4, 0
pkn_zero:
  add   a5, a2, a4
  s32i  a3, a5, 0
  addi  a4, a4, 4
  movi  a5, 48
  bne   a4, a5, pkn_zero
  call8 net_name_put                 ; the name in use (with the MAC the console knows, vars+264)
  addi  a10, a2, 16
  l32r  a11, lit_netnamebuf
  movi  a12, 32
  call8 net_copy
  addi  a10, a2, 8
  l32r  a11, lit_vars
  addmi a11, a11, 256
  addi  a11, a11, 8                  ; +264
  movi  a12, 6
  call8 net_copy
  movi  a4, 4                        ; wlan off (kept in the record of a network)?
  call8 cred_net
  beqz  a10, pkn_state
  l32r  a3, lit_credbuf
  l32i  a3, a3, 8
  bbsi  a3, 1, pkn_put
pkn_state:
  movi  a4, 0
  call8 svc_runs
  beqz  a10, pkn_put
  l32r  a8, lit_svcstat              ; wifi_status, as wlan_show
  callx8 a8
  movi  a4, 3
  bbsi  a10, 0, pkn_ip
  movi  a4, 2
  bbsi  a10, 24, pkn_put
  movi  a4, 1
  j     pkn_put
pkn_ip:
  l32r  a3, lit_svchead
  l32i  a5, a3, 32                   ; the version of the service
  movi  a6, 10
  bltu  a5, a6, pkn_put
.if defined(CON_S3)
  l32r  a3, lit_svccall              ; (the entries on the bus of the instructions)
.endif
  addi  a10, a2, 4
  addi  a8, a3, 100                  ; wifi_get_ip
  callx8 a8
pkn_put:
  s32i  a4, a2, 0
  movi  a10, 107                     ; 'k'
  mov   a11, a2
  movi  a12, 48
  call8 send_packet
  retw
