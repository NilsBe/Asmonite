# Der ESP32-C3 mit Asmonite

Der ESP32-C3 von Espressif hat einen RISC-V-Kern (RV32IMC, 160 MHz) und einen USB-Anschluss, der zugleich serieller
Port und JTAG-Debugger ist. Asmonite nutzt beides: Es debuggt ein Programm im RAM des Chips und schreibt es in den
Flash, **mit einem USB-Kabel, ohne Debug-Probe, ohne OpenOCD und ohne ESP-IDF**.

Getestet mit dem LuatOS ESP32C3-CORE (die einfache Version mit einem USB-C-Anschluss direkt am Chip; 4 MB Flash im
DIO-Modus; LEDs an GPIO 12 und 13) und mit einem Board mit zwei USB-C-Anschlüssen und einer RGB-LED WS2812 an GPIO 8
(ein Anschluss geht an den Chip, der andere über einen CH340 an UART0). Andere Boards, deren USB-Anschluss direkt zum Chip geht (GPIO 18 und 19), sollten
genauso gehen; Boards mit eigenem USB-Seriell-Chip (CP2102, CH340, CH343) haben keinen USB-JTAG.

## Was du brauchst

- Ein Board mit ESP32-C3, dessen USB-Anschluss der des Chips ist. Im Geräte-Manager erscheint es als
  „USB JTAG/serial debug unit“ und als COM-Port.
- Windows 10 oder 11.

## Einmal einrichten: der USB-JTAG

Windows gibt dem JTAG-Teil des USB-Anschlusses von selbst den Treiber WinUSB, aber nicht den Eintrag, den Programme
zum Öffnen brauchen. In Asmonite: **Debug > Debug targets > ESP32-C3 > Set up the USB JTAG**. Windows fragt einmal nach
Administratorrechten; danach sollte **Test the connection** melden, dass das Board antwortet. Windows merkt sich das
für jedes Board (es erkennt das Board an seiner Seriennummer, der MAC-Adresse des Chips), an jedem USB-Anschluss
des Rechners: Ein zweites Board braucht den Knopf noch einmal.

## Ein Programm im RAM

```asm
.target esp32c3
.arch riscv32
.imagebase 0x40380000

_start:
    ...
```

Drück F9 (Ausführen) oder F7 (Einzelschritt). Der Debugger setzt den Chip zurück und hält ihn sofort an, bevor die
Firmware im Flash startet, lädt das Programm nach `0x40380000` und hält bei `_start`. Dann gehen: Schritte (F7, F8),
Breakpoints (F5; der Kern hat Hardware-Breakpoints dafür), die Register `x0` .. `x31` und `pc`, der Speicher. Nach
einem Reset (die RESET-Taste) läuft wieder die Firmware des Flash.

Warum der Reset: Firmware wie LuatOS oder ESP-IDF schaltet den Speicherschutz des Chips ein; dann lässt sich bis zum
nächsten Reset nichts mehr ins RAM des Codes schreiben. Angehalten, bevor die Firmware startet, ist das ganze RAM von
`0x40380000` bis `0x403BFFFF` (256 KB) frei für das Programm.

## Ein Programm im Flash

```asm
.target esp32c3 flash
.arch riscv32
.imagebase 0x40380000
```

F9 oder F7 schreiben das Programm jetzt in den Flash an Adresse 0, als Image des Boot-ROM: Das Boot-ROM lädt es bei
jedem Start ins RAM nach `0x40380000`. Geschrieben wird über den **seriellen Port** des Chips (den COM-Port des Boards),
mit dem Protokoll seines Boot-ROM; in diesem Moment darf kein Terminalprogramm (PuTTY o. ä.) den Port offen haben
(der Reiter Serial von Asmonite gibt ihn von selbst frei).
Danach lässt der Debugger das Boot-ROM das Programm starten und hält bei `_start` – du siehst das Programm also genau
so, wie es auch ohne Debugger startet. Es startet außerdem nach jedem Reset von selbst.

Das ersetzt die Firmware, die vorher im Flash war (beim LuatOS-Board: LuatOS; sie lässt sich beim Hersteller wieder
herunterladen).

Ein Programm im Flash muss die **Watchdogs** selbst abschalten: Das Boot-ROM lässt zwei davon an, und sie würden den
Chip nach einigen Sekunden zurücksetzen. `examples/esp32c3/blink_flash.asm` zeigt, wie (ein paar Zeilen bei `_start`).

## Die Beispiele

| Datei | Was es tut |
|---|---|
| `examples/esp32c3/blink_ram.asm` | Die LEDs an GPIO 12 und 13 blinken abwechselnd; jeder Wechsel ist eine Zeile auf dem USB-Seriell-Port (COM-Port): `LED 12 on`, `LED 13 on` |
| `examples/esp32c3/blink_flash.asm` | Dasselbe im Flash, mit abgeschalteten Watchdogs am Anfang |
| `examples/esp32c3/rgb_ws2812_ram.asm` | Für Boards mit einer RGB-LED WS2812 an GPIO 8: abwechselnd rot, grün und blau, und für jede Farbe eine Zeile auf dem USB-Seriell-Port. Die 24 Bit der Farbe misst der Zykluszähler des Kerns; das Programm stellt den Takt des Kerns von 20 auf 40 MHz |
| `examples/esp32c3/rgb_ws2812_flash.asm` | Dasselbe im Flash, mit abgeschalteten Watchdogs am Anfang |
| `examples/esp32c3/hello_uart_ram.asm` | „Hello, world!“ auf UART0 (der Pin GPIO 21, nicht der USB-Anschluss: ein USB-Seriell-Adapter dort zeigt es; bei Boards mit einem zweiten USB-Anschluss mit CH340 dieser Anschluss) |

Die Register, die sie benutzen, stehen in ihren Kommentaren, mit der Quelle: die Header von ESP-IDF und das
ESP32-C3 Technical Reference Manual.

## Die Ausgabe auf dem USB-Seriell-Port

Der USB-Anschluss des Chips ist auch ein serieller Port (COM-Port); ein Programm schreibt ein Byte in das Register
`0x60043000` (`USB_SERIAL_JTAG_EP1`) und schickt ab, was dort steht, mit Bit 0 von `0x60043004` (`EP1_CONF`,
`WR_DONE`). Bit 1 von `EP1_CONF` sagt, dass der Puffer Daten nimmt. Liest kein Programm auf dem PC den Port, läuft der
Puffer voll; die Beispiele lassen die Zeile dann fallen, statt ewig zu warten. Jedes Terminal zeigt die Zeilen (die
Geschwindigkeit ist auf diesem Port egal).

Unter dem Debugger zeigt sie der Reiter **Serial** neben dem Ausgabefenster: Er verbindet sich von selbst mit diesem
COM-Port, wenn der Debugger das Programm geladen hat. Der Debugger hat den JTAG desselben USB-Anschlusses, der
serielle Port bleibt frei; nur der Reset ins Boot-ROM und das Schreiben des Flash gehen über ihn, deshalb gibt der
Reiter ihn beim Start der Sitzung frei. Connect und Disconnect bleiben benutzbar. (Ein Terminal eines anderen
Programms muss vor F9 geschlossen sein.)

Der RISC-V-Kern des C3 liest und schreibt Bytes auch unter der IRAM-Adresse des Programms (`lbu`, `sb`): Die Texte der
Beispiele stehen neben ihrem Code.

## Die Konsole von Asmonite

Wie auf dem ESP32 und dem ESP32-S3 kann der C3 die Konsole von Asmonite ausführen (`boards/esp32c3/console.asm`):
ein Prompt auf dem USB-Seriell-Port, Dateien im Flash, Programme aus den Dateien, das WLAN. **Board > Board Manager**,
das Board wählen, **Prepare Board**: Asmonite schreibt die Konsole ins Flash ab 0 (an die Stelle des Programms dort),
`help.txt`, ein leeres Dateisystem (ab 2 MB des Flashs; vorhandene Dateien bleiben) und das WLAN-Paket. Dann ein
Terminal auf dem COM-Port des Boards (der Reiter Serial):

| Befehl | Was er tut |
|---|---|
| `ls`, `cat name`, `rm name`, `df`, `format` | die Dateien im Flash |
| `run name`, `name [args]` | startet ein Programm aus den Dateien (ein Programm, wie Compile and Upload es schreibt) |
| `boot name`, `noboot` | das Programm, das nach jedem Reset startet (eine Taste in den ersten 3 Sekunden bleibt in der Konsole) |
| `wlan`, `wlan set`, `wlan on`, `wlan off`, `wlan clear`, `wlan scan` | das WLAN-Netz des Boards |
| `name`, `name set name`, `name clear` | der Name des Boards im Netz (DHCP, mDNS: `name.local`) |
| `info`, `reset`, `help` | der Chip, ein Reset, die Befehle |

Ein Programm für die Konsole läuft im RAM ab `0x40380000` (bis `0x403A7FFF`; darüber liegen das WLAN und die
Konsole): `.target esp32c3`, `.arch riscv32`, `.imagebase 0x40380000`, dann **Debug > Upload and Run** (oder
**Project > Compile and Upload** und später `run name` im Terminal). Es bekommt den Text seiner Argumente in `a0` und endet mit `ret` (sein Code in
`a0`), mit `exit(code)` aus beliebiger Tiefe, durch eine Exception (die Konsole sagt, welche und wo) oder durch
Ctrl+C. Die Funktionen der Konsole für Programme liegen bei `0x403CC200`, je ein Sprung von 4 Bytes, in der
Reihenfolge des ESP32: exit, version, put_char, get_char, poll_char, print, millis, file_size, file_read, file_write,
flash_read, args. `boards/esp32c3/contest.asm` benutzt einige davon.

Das WLAN: `wlan set` fragt nach dem Namen des Netzes und seinem Passwort (ohne Echo; das Board behält den Schlüssel
von WPA2, nicht das Passwort). Das Board verbindet im Hintergrund, holt eine Adresse per DHCP (`WiFi: connected,
address a.b.c.d (esp32c3-xxxx.local).`), beantwortet ARP, Ping und mDNS für seinen Namen und startet das WLAN nach
einem Reset von selbst; `wlan off` lässt es aus, auch nach einem Reset. `name set keller` gibt dem Board einen
anderen Namen (für den Router und `keller.local`; `name clear`: wieder den aus der MAC); `wlan set` und `wlan clear`
behalten ihn. Der C3 hat einen Kern: Der WLAN-Dienst bei `0x403A8000` gibt den Tasks des WLANs alle 10 ms über einen
Timer eine Runde, auch während ein Programm rechnet, und sein eigener Task hält die Verbindung, beantwortet ARP, Ping
und mDNS und erneuert die Adresse (`wlan/wlannet_c3.asm`). Ein Programm, das das WLAN
braucht, ruft den Dienst selbst auf (siehe `wlan/wlansvc_c3.asm`; `wifi_get_ip` liefert die Adresse, die Maske, den
Router und den Nameserver). Auf dem ESP32 und dem ESP32-S3 liegt DHCP dagegen in der Konsole, nur weil ihr Dienst
dafür keinen Platz hat; dort wird die Adresse nur erneuert, während die Konsole läuft.

aBelle: Ein Programm mit `target "esp32c3"` (`include "inc/console.abel"` aus `abelle/examples/esp32c3`: die Funktionen
der Konsole) übersetzt `abelle_riscv.exe`; F9, F7 und F8 laden es über den USB-JTAG, die Konsole startet es (der Stack
der Programme, Ctrl+C, `exit`; seine Ausgabe und „Program ended“ im Reiter Serial) und ist danach wieder am Prompt, die
Variablen zeigt die Maus. Compile and Upload legt es als Datei auf das Board. Die Netzwerkprogramme in
`abelle/examples/esp32c3` (`ping`, `dns`, `ntp`, `arpscan`, `httpget`, `dhcp`) nutzen `inc/net.abel` und `inc/tcp.abel`
wie auf dem ESP32; die Adresse kommt vom WLAN-Dienst.

F9 führt ein Assembler-Programm weiter wie oben über den USB-JTAG aus: Ein Programm im RAM hält die Konsole bis zum nächsten
Reset an; ein Programm für das Flash (`.target esp32c3 flash`) tritt an ihre Stelle (Prepare Board bringt sie
zurück; die Dateien bleiben).

## Wenn etwas nicht geht

| Meldung oder Zeichen | Was tun |
|---|---|
| „the ESP32-C3 is plugged in, but ... has not given its USB JTAG an interface“ | Debug targets > ESP32-C3 > Set up the USB JTAG (einmal je Board) |
| „COM8 is open in another program“ | Das Terminal (PuTTY …) schließen, dann noch einmal F9 |
| „the core of the ESP32-C3 hangs“ | RESET am Board drücken, dann noch einmal |
| Das Board startet alle paar Sekunden neu, der COM-Port kommt und geht, ein Terminal zeigt `invalid header: 0xffffffff`; F9 meldet „does not answer over USB JTAG: … (error 31)“ | Der Flash ist leer (Erase Flash im Board Manager, oder ein Schreiben wurde nicht fertig): BOOT halten, RESET drücken (oder das Board anstecken), BOOT loslassen, dann F9; ein Programm für den Flash beendet das |
| Das Board antwortet gar nicht | BOOT halten, RESET drücken, BOOT loslassen: Der Chip wartet in seinem Boot-ROM; dann F9 |
| Nichts auf dem COM-Port | Ist das Programm für den USB-Port (`blink_ram.asm`) oder für UART0 (`hello_uart_ram.asm`)? |

## Grenzen

- Ein Kern (der ESP32-C3 hat einen), das RAM von `0x40380000` bis `0x403BFFFF`.
- Die komprimierten Befehle (C) mit 2 Bytes mit `.option rvc` (F1 auf dieser Zeile: das Thema `compressed`); ohne
  die Zeile ist jeder Befehl 4 Bytes lang. Die Konsole von Asmonite benutzt sie.
- Das Flash-Image ist für 4 MB Flash im DIO-Modus mit 40 MHz. WLAN: mit der Konsole von Asmonite (oben); kein
  Bluetooth. Noch nicht auf dem C3: telnet. Die Antwort auf einen Ping dauert länger, während ein
  Programm rechnet (bis zu den 10 ms des Timers; gemessen 30 bis 130 ms statt 20 bis 35 ms).
- Wie der Chip den USB-JTAG macht: das Protokoll aus `esp_usb_jtag.c` von OpenOCD und die RISC-V-Debug-Spec 0.13.
