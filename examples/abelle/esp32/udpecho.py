"""Sends lines to the UDP echo server of udpecho.abel on the board and shows what comes back:

    python udpecho.py <address of the board> [port]

The PC has to be in the same network as the board (the network of inc/network.abel). Each line you type goes
to the board; the board sends it back. An empty line ends it."""
import socket
import sys

if len(sys.argv) < 2:
    sys.exit(__doc__)
addr = (sys.argv[1], int(sys.argv[2]) if len(sys.argv) > 2 else 7777)
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.settimeout(2.0)
print('to %s:%d (an empty line ends it)' % addr)
while True:
    line = input('> ')
    if not line:
        break
    s.sendto(line.encode('utf-8'), addr)
    try:
        data, who = s.recvfrom(1500)
        print('%s:%d says: %s' % (who[0], who[1], data.decode('utf-8', 'replace')))
    except socket.timeout:
        print('no answer in 2 seconds')
