; The texts of the DHCP part of the consoles (console_dhcp.asm), in their .data

s_netup:  db 'WiFi: connected, address ', 0
s_netgone: db 'WiFi: no connection.', 0
s_netfail: db 'WiFi: no address by DHCP (again in 30 s).', 0
.if defined(CON_S3)
net_name: db 'esp32s3-', 0            ; the name of the board without name set: this and
.else                                    ; the last two bytes of the MAC
net_name: db 'esp32-', 0
.endif
s_netin:  db ' (', 0
s_netlocal: db '.local)', 0
c_name:   db 'name', 0
s_nmis:   db 'The name of the board: ', 0
s_nmmac:  db 'It comes from the MAC; name set <name> gives the board another one.', 13, 10, 0
s_nmuse:  db 'name, name set <name>, name clear', 13, 10, 0
s_nmbad:  db 'A name has 1 to 31 letters, digits or -, for example: name set esp32-keller', 13, 10, 0
          ; the fixed bytes of a DHCP message (net_send): pairs of the place and the byte, then 0
net_head: db 12, 0x08, 14, 0x45, 16, 0x01, 17, 0x48, 22, 64, 23, 17, 35, 68, 37, 67, 38, 0x01, 39, 0x34
          db 42, 1, 43, 1, 44, 6, 52, 0x80, 0
c_passwd: db 'passwd', 0
s_pwask:  db 'Password for telnet (not shown, 8 to 63 characters): ', 0
s_pwbad:  db 'A password for telnet has 8 to 63 characters: nothing changed.', 13, 10, 0
s_pwset:  db 'telnet asks for a password (passwd clear: none).', 13, 10, 0
s_pwnone: db 'No password: telnet lets everyone in (passwd set gives one).', 13, 10, 0
s_pwdone: db 'The password for telnet is set.', 13, 10, 0
s_pwuse:  db 'passwd, passwd set, passwd clear', 13, 10, 0
