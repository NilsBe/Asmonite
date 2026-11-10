# Der ESP32 mit Asmonite

Der ursprüngliche ESP32 von Espressif hat zwei Xtensa-LX6-Kerne (240 MHz). Asmonite assembliert seinen Code
(`.arch xtensa`, `.target esp32`) und übersetzt Programme in der Sprache aBelle für ihn, lädt ein Programm in sein
RAM oder schreibt es in seinen Flash und debuggt es, **über das USB-Kabel des Boards, ohne JTAG-Probe, ohne esptool
und ohne ESP-IDF**: Breakpoints, Einzelschritte, die Register, der Speicher. Ein kleiner Debug-Monitor von Asmonite
läuft neben dem Programm und spricht über den seriellen Port mit Asmonite. Dazu kommen eine Konsole mit Dateien im
Flash und das **WLAN**: Ein aBelle-Programm verbindet sich mit einem Netz, holt eine Adresse per DHCP und spricht
UDP und TCP, auch während der Debugger es an einem Breakpoint anhält.

Getestet mit einem ESP32 DevKit V1 (ESP32-D0WD, ein CP2102 als USB-Seriell-Chip, 4 MB Flash, die blaue LED an GPIO 2)
und einem Board mit ESP32-WROVER (CH9102, 8 MB Flash).

## Was du brauchst

- Ein Board mit ESP32 und USB-Seriell-Chip: CP2102 oder CP2104, CH340, CH9102, CH343 oder ein FTDI-Chip. Im
  Geräte-Manager erscheint es als COM-Port, zum Beispiel „Silicon Labs CP210x USB to UART Bridge (COM14)“. Den Treiber
  der meisten dieser Chips bringt Windows mit, sonst kommt er vom Hersteller des Chips.
- Windows 10 oder 11.
- Für das WLAN: ein WLAN mit 2,4 GHz, offen oder mit WPA2.

**Debug > Debug targets > ESP32 > Test the connection** zeigt, ob das Board antwortet: seinen COM-Port, seine
MAC-Adresse und seinen Flash, zum Beispiel „flash 4 MB (Boya, JEDEC id 68 40 16)“. Die Größe sagt der Flash-Chip
selbst (der Befehl 0x9F, wie bei `esptool flash_id`); in den eFuses steht sie nicht.

## Wie das Programm auf den Chip kommt

Der ESP32 hat keinen eigenen USB-Anschluss. Sein Boot-ROM wartet auf Befehle über den seriellen Port (UART0), wenn der
Pin GPIO 0 bei einem Reset auf low liegt. Die Boards machen das mit zwei Transistoren an den Leitungen DTR und RTS des
USB-Seriell-Chips: RTS zieht EN (den Reset), DTR zieht GPIO 0. Asmonite macht es wie esptool und prüft nach jedem
Reset die erste Zeile des Boot-ROMs: „boot:0x3 (DOWNLOAD_BOOT …)“ heißt Download-Modus.

Auf vielen Boards braucht das viele Versuche (beim DevKit V1 des Tests 2 bis 125 Resets, 1 bis 7 Sekunden): Die
beiden Leitungen wechseln nacheinander, und dazwischen kann der Chip starten, bevor GPIO 0 low ist.
esptool verlässt sich auf einen Kondensator an EN, der den Chip diesen Moment lang im Reset hält; auf manchen Boards ist
er zu klein. Kommt das Board nicht innerhalb von 10 Sekunden dorthin, bittet Asmonite, **BOOT gedrückt zu halten**:
Dann geht jeder Reset in den Download-Modus. (Ein Kondensator von etwa 10 µF zwischen EN und GND behebt es dauerhaft.)

Große Übertragungen laufen mit **921600 Baud** statt 115200: der Flash über das Boot-ROM, ein Programm ab 16 KB unter
dem Debugger, Dateien ab 16 KB in Board Files. Asmonite schaltet die Rate um, prüft sie mit einem kurzen Austausch und
fällt auf 115200 zurück, wenn das Board sie nicht schafft; gelingt die Prüfung und scheitert erst die Übertragung,
schreibt Asmonite das Ganze noch einmal mit 115200. Bevor das Programm läuft, gilt wieder 115200, wie es das
Programm erwartet. Die Umgebungsvariable `ASMONITE_ESP_BAUD` setzt eine andere Rate (`115200`: nie schneller).

## Ein Programm im RAM

```asm
.target esp32
.arch xtensa
.imagebase 0x40080000

_start:
    ...
```

F9 (ausführen) oder F7 (Einzelschritt) setzt den Chip in den Download-Modus, das Boot-ROM lädt den Debug-Monitor von
Asmonite ans obere Ende des IRAM und startet ihn, und der Monitor lädt das Programm bei `.imagebase` und startet es bei
`_start` (ohne `_start`: beim ersten Byte); F7 hält dort an. Dann wie bei den anderen Boards: F7 und F8 gehen Zeile für
Zeile (auch in und über `call8` und die anderen Aufrufe mit Registerfenster), F5 setzt einen Breakpoint, F9 läuft bis
zum nächsten; die Register `a0` bis `a15` des Fensters, `pc`, `ps`, `sar`, `windowbase`, `windowstart` und die
Schleifenregister stehen im Fenster der Register, das Speicherfenster liest den Speicher des Chips. Ein Programm, das
mit `ret` zurückkehrt (wie bei call0: `_start` bekommt in `a0` das Ende des Monitors), beendet die Sitzung; das
Ausgabefenster zeigt `a2` und `a3`.

**Debug > Pause** hält ein laufendes Programm an, wo es gerade ist, auch in einer Endlosschleife; **Stop** (Strg+F2)
beendet die Sitzung sofort. Dafür schickt Asmonite ein Byte über UART0: Solange das Programm läuft, löst es
im Monitor ein NMI aus (siehe unten). Ein laufendes Programm stört das nächste F9 nicht: Es setzt den Chip ohnehin
zurück.

Das Programm startet mit `sp` (`a1`) bei `0x3FFC0000` im DRAM und `ps` = `0x00040025` (Aufrufe mit Registerfenster,
Interrupt-Stufe 5: nur die Debug-Ausnahme und NMI kommen durch). Eine Ausnahme des Programms (ein ungültiger Befehl, ein
Laden von einer Adresse ohne Speicher, ein Byte-Speichern ins IRAM) hält es am Befehl an, mit dem Grund im
Ausgabefenster. Nach einem Reset (EN) läuft wieder die Firmware aus dem Flash.

So funktioniert es: Der Monitor (`src/debugger/esp32mon.asm`, gut 2 KB bei `0x4009E000`) setzt `VECBASE` auf seine
eigene Vektortabelle: `break 1,15` (ein Breakpoint), der Schritt von `ICOUNT` und jede Ausnahme landen dort; er sichert
die Register und beantwortet die Befehle von Asmonite über UART0 (Register, Speicher in Wörtern, laufen, Schritt, die
Rate). Er hat die Handler der Registerfenster (Überlauf und Unterlauf von `call4`, `call8`, `call12`), wie jedes
Xtensa-Programm sie braucht, und legt unter den ersten `sp` einen Rahmen für einen Aufrufer von `_start`, den es nicht
gibt: So geht auch eine Aufrufkette, die tiefer ist, als die 64 Register fassen. Für die Pause leitet er den
Interrupt von UART0 (ein Byte im Empfangspuffer) über die Interrupt-Matrix auf den CPU-Interrupt 14, das NMI
(Stufe 7, über der Stufe 5 des Programms); eingeschaltet ist er nur, während das Programm läuft.

Das RAM von `0x40080000` bis `0x4009DFFF` (120 KB) ist für das Programm frei; darüber liegt der Monitor. Es ist
**Befehls-RAM**: Der Kern liest und schreibt es nur in Wörtern zu 32 Bit. `l32i` und `s32i` gehen, `l8ui`, `l16ui`,
`s8i` halten mit einer Ausnahme an (LoadStoreError). Ein großes Programm (98 KB) lädt in gut 6 Sekunden.

### Daten im DRAM: `.data`

Texte, Tabellen und Puffer kommen hinter `.data`: Diese Zeilen landen im **DRAM** ab `0x3FFB0000`, wo der Kern Bytes,
Halbwörter und Wörter liest und schreibt. `.code` schaltet zurück zum Code (ins IRAM).

```asm
lit_text: dd text            ; die Adresse im DRAM, für l32r (die Literale bleiben im IRAM)

_start:
  l32r  a3, lit_text
  l8ui  a2, a3, 0            ; ein Byte des Textes
  ...

.data
text:   db 'Hello, world!', 13, 10, 0
buffer: resb 64              ; Platz, beim Laden mit Nullen gefüllt
```

Die Labels in `.data` haben ihre Adressen im DRAM; `align 4` vor einem `dd` legt es wie überall auf ein Wort. In der
Datei stehen die Bytes von `.data` hinter dem Code; der Debugger schreibt sie nach dem Code ins DRAM, ein Programm für
den Flash hat sie als zweites Segment im Image, das das Boot-ROM bei jedem Start kopiert. `.data 0x3FFC0100` legt sie
an eine andere Adresse. Frei für `.data` ist das DRAM von `0x3FFB0000` bis `0x3FFDFFFF` ohne den Stack: Er beginnt
bei `0x3FFC0000` und wächst nach unten, und Asmonite hält `0x3FFBF000` bis `0x3FFC000F` für ihn frei (die 4 KB
darunter und den Rahmen des Monitors darüber); Daten, die hineinreichen, sind ein Fehler. Ab `0x3FFE0000` hält das
Boot-ROM seine eigenen Daten. `examples/esp32/hello_uart_ram.asm` und `hello_uart_flash.asm` lesen ihren Text aus
`.data`.

Der Kern läuft mit 40 MHz (dem Quarz), im Download-Modus und nach einem Start aus dem Flash.

## Ein Programm im Flash

```asm
.target esp32 flash
.arch xtensa
.imagebase 0x40080000
```

F9 oder F7 schreiben das Programm in den Flash an die Adresse `0x1000`, als Image des Boot-ROMs (Chip-ID 0, ein
Segment bei `.imagebase` und eins für `.data`, wenn das Programm es hat), über das Boot-ROM; dann startet der Debugger
den Monitor neu, lädt das Programm ins IRAM, wie das Boot-ROM es bei jedem Start tut, und debuggt es dort. Nach einem
Reset (EN) startet das Boot-ROM es von selbst aus dem Flash. Es ersetzt die Firmware, die vorher im Flash war (ihr
Bootloader steht bei `0x1000`). Während der Flash geschrieben wird, darf kein Terminal den COM-Port offen haben. Ein
Image, das nicht in den Flash des Boards passt, weist Asmonite ab.

**Debug > Write to Flash and Run** (Shift+F9) tut dasselbe für ein Programm mit `.target esp32` (ohne `flash`): So
geht derselbe Quelltext ohne Änderung in den RAM (F9) oder in den Flash (Shift+F9).

Ein Programm, das das Boot-ROM aus dem Flash startet, muss die **Watchdogs** selbst abschalten (Timergruppe 0 und 1
und den RTC-Watchdog), sonst setzt sich der Chip nach ein paar Sekunden zurück; `examples/esp32/blink_flash.asm`
zeigt, wie es geht, mit ein paar Zeilen bei `_start`.

## Die serielle Ausgabe

UART0 ist der serielle Port des Boards: Was das Programm in `UART_FIFO_REG` schreibt (`0x3FF40000`, oder wie ESP-IDF
über den AHB-Bus bei `0x60000000`), kommt am COM-Port heraus, mit 115200 Baud (das Boot-ROM hat ihn eingerichtet).
Unter dem Debugger teilt sich der Monitor den Port mit dem Programm: Was das Programm schreibt, erscheint im Reiter
**Serial** neben dem Ausgabefenster, so wie es kommt (der Reiter kommt bei der ersten Ausgabe einer Sitzung nach vorn).
Connect, Port, Baudrate und die Eingabezeile sind gesperrt, solange die Sitzung dauert, die Kopfzeile sagt, dass der
Debugger den Port hat; ein Port, der im Reiter verbunden war, wird beim Start der Sitzung freigegeben. Das
Ausgabefenster behält die Meldungen des Debuggers.

Ohne Debugger (ein Programm aus dem Flash nach einem Reset) ist der Reiter **Serial** neben dem Ausgabefenster ein
kleines Terminal: die Zeichen, wie sie kommen; eine Zeile, die unten eingegeben wird, geht mit Enter an das Board (mit
CR und LF). **Connect** öffnet einen Port mit dem Port und der Baudrate aus der Kopfzeile, **Disconnect** gibt ihn für
ein anderes Terminal frei (PuTTY …); **Reset** (nur bei den USB-Seriell-Chips der ESP32-Boards) setzt den Chip
über RTS zurück, ohne den Port zu schließen, so erscheinen die ersten Zeilen des Boot-ROMs und des Programms im Flash.
Das Terminal von Asmonite lässt die Leitungen DTR und RTS aus: Manche Terminalprogramme schalten sie beim Öffnen des
Ports, das setzt den Chip zurück, und ein Programm im RAM ist weg.

## Die Konsole und ihre Dateien

`examples/esp32/console.asm` macht aus dem Board einen kleinen Rechner mit einem Dateisystem im Flash: Es reicht von
2 MB bis zum Ende des Flash (bei 4 MB also 2 MB, bei 8 MB wie auf einem WROVER 6 MB; die Konsole liest die Größe beim
Start aus dem Flash-Chip). Jedes Terminalprogramm arbeitet mit ihr (`ls`, `cat`, `put`, `rm`, `df`, `format`, `run`,
`load`, `boot`, `help`), und **Debug > ESP32 Board Files** in Asmonite zeigt ihre Dateien in einem Fenster:

- **Write Console to Flash** schreibt die Konsole in den Flash (über das Boot-ROM, wie Write to Flash and Run); beim
  ersten Mal legt **Format** ihr Dateisystem an. Die Kopfzeile des Fensters nennt den Flash des Boards.
- **Upload File** und **Download** bringen Dateien jeder Art zwischen PC und Board hin und her (100 KB hoch in knapp
  4 Sekunden, herunter in 2), jede an ihrer CRC-32 geprüft; **Delete** löscht eine.
- **Upload This Program** übersetzt das Programm im Editor (Assembler mit `.target esp32` oder aBelle) und lädt es als
  das Image hoch, das das Boot-ROM aus dem Flash starten würde; **Run** startet es (das Fenster schließt sich, der
  Reiter Serial zeigt, was es schreibt), **Autostart** startet es nach jedem Reset. Nach einem Reset wartet die
  Konsole zuerst kurz: BOOT oder eine Taste im Terminal hält sie in der Konsole; **Reset Board** im Fenster tut das
  auch.
- **Erase Flash** löscht den ganzen Flash über das Boot-ROM, wie bei einem neuen Board: keine Konsole, keine Dateien
  (8 bis 17 Sekunden bei 4 MB). Das Boot-ROM meldet danach bei jedem Start „flash read err, 1000“. Write Console to
  Flash und Format machen daraus wieder ein Board für Asmonite.
- **Install WiFi** bringt das WLAN aufs Board (siehe unten).
- Ein Programm für F9 passt unverändert: Sein Code darf `0x40080000..0x40097FFF` belegen, seine Daten
  `0x3FFB0000..0x3FFCFFFF`; die Konsole liegt darüber.

Das Fenster hat den seriellen Port, solange es offen ist (der Reiter Serial gibt ihn frei). Unter dem Debugger läuft
die Konsole nicht: Der Debug-Monitor nimmt jedes Byte auf UART0 als seine Pause. Ein Board, das vor 0.12.0 formatiert
wurde, behält sein Dateisystem von 2 MB bis zum nächsten Format.

## aBelle auf dem ESP32

aBelle ist eine kleine Sprache mit der Schreibweise von Python (Seite: asmonite.com/de/abelle.html). Ein Programm mit
`target "esp32"` übersetzt `abelle_esp32.exe` in den Code für das IRAM und die Daten für das DRAM, genau wie ein
Assemblerprogramm mit `.target esp32`; F9 lädt und debuggt es **in seinem Quelltext** (Breakpoints, F7/F8 Zeile für
Zeile, Variablen unter der Maus und im Fenster Watch), Shift+F9 schreibt es in den Flash.

```python
target "esp32"

gpio:  u32[0x140] at 0x3FF44000     # die Register als Feld an ihrer Adresse
iomux: u32[64]    at 0x3FF49000
def ets_delay_us(us: u32) at 0x40008534     # eine Funktion des ROM

def main():
    iomux[0x40 / 4] = 0x2800        # der Pin von GPIO 2 als GPIO
    gpio[0x538 / 4] = 0x100         # eine einfache Ausgabe
    gpio[0x24 / 4] = 1 << 2         # GPIO 2 ist ein Ausgang
    while True:
        gpio[0x08 / 4] = 1 << 2     # an
        ets_delay_us(500000)
        gpio[0x0C / 4] = 1 << 2     # aus
        ets_delay_us(500000)
```

Die Beispiele liegen in `examples/abelle/esp32/` (in den Quellen `abelle/examples/esp32/`); `inc/` hat die Teile, die
sie einbinden: `uart.abel` (Text und Zahlen über UART0), `wifi.abel`, `net.abel`, `tcp.abel` (das WLAN) und
`network.abel` (der Name und das Passwort deines WLAN).

## Das WLAN

Das WLAN des ESP32 steckt in Bibliotheken von Espressif (ohne Quelltext). Asmonite bindet sie einmal mit seinem eigenen
Linker zu einer festen Datei zusammen, `wlan.rom`, und bringt einen kleinen Dienst mit, `wlansvc`, der sie startet
und Programmen einfache Funktionen anbietet. **ESP-IDF braucht es dafür nicht.**

**Einrichten, einmal pro Board:** Debug > ESP32 Board Files (die Konsole muss im Flash sein, das Dateisystem
formatiert), dann **Install WiFi**: Sein Teil für den Flash (330 KB bei `0x100000`) geht über das Boot-ROM in den
Flash, `wlan.rom` und `wlansvc` in die Dateien der Konsole (etwa 25 Sekunden).

**Ein Programm mit WLAN:** In `examples/abelle/esp32/inc/network.abel` trägst du den Namen und das Passwort deines
WLAN ein (leer für ein offenes Netz, sonst WPA2), dann zum Beispiel `ntp.abel` öffnen und F9 drücken. Das Programm
lädt den Dienst beim ersten WLAN-Aufruf selbst aus den Dateien des Boards (`inc/wifi.abel`), mit F9 genauso wie mit
`run ntp` in der Konsole oder als Autostart.

**Debuggen, während das WLAN läuft:** Der Dienst und das WLAN laufen auf dem **zweiten Kern** des ESP32, das Programm
auf dem ersten. Der Debugger hält nur den ersten an: Steht das Programm an einem Breakpoint, bleibt die Station
verbunden, und was ankommt, wartet in einem Puffer des Dienstes (6 Frames).

**Was ein Programm damit tun kann** (`inc/wifi.abel`, `inc/net.abel`, `inc/tcp.abel`):

| Funktion | Was sie tut |
|---|---|
| `wifi_scan`, `wifi_connect`, `wifi_status` | Netze suchen, sich verbinden (offen oder WPA2), den Zustand lesen |
| `wifi_send`, `wifi_recv` | Ethernet-Frames hinaus und herein |
| `dhcp_run` | eine Adresse, die Maske, den Router und den DNS-Server vom Router holen |
| `dns_lookup` | einen Namen in eine Adresse auflösen |
| `ping_send` | einen Ping schicken (Pings an das Board beantwortet es von selbst) |
| `udp_send`, `net_recv` | UDP |
| `tcp_connect`, `tcp_listen`, `tcp_accept`, `tcp_send`, `tcp_recv`, `tcp_close` | TCP, eine Verbindung zur Zeit, als Client oder Server |
| `net_set_name`, `mdns_start` | der Name des Boards: der Router lernt ihn per DHCP, mDNS beantwortet `name.local` (`ping esp32.local`) |
| `wifi_error_text` | ein Fehler als Satz, zum Beispiel der Hinweis auf Install WiFi, wenn die Dateien fehlen |

## Die Beispiele

| Datei | Was es tut |
|---|---|
| `examples/esp32/blink_ram.asm` | Die LED an GPIO 2 an und aus, je eine halbe Sekunde, gezählt mit dem Taktzähler `ccount` |
| `examples/esp32/blink_flash.asm` | Dasselbe im Flash, mit den Watchdogs am Anfang abgeschaltet |
| `examples/esp32/hello_uart_ram.asm` | „Hello, world!“ einmal pro Sekunde über UART0 (den COM-Port des Boards), der Text in `.data` |
| `examples/esp32/hello_uart_flash.asm` | Dasselbe im Flash, bei jedem Start des Boards (der Reiter Serial zeigt es) |
| `examples/esp32/clock_ram.asm` | Der Kern vom Quarz und von der PLL mit 80, 160 und 240 MHz, und wie schnell eine Schleife bei jedem Takt läuft |
| `examples/esp32/console.asm` | Die Konsole mit dem Dateisystem im Flash (siehe oben) |
| `examples/abelle/esp32/` | aBelle: blink, hello_uart, chipinfo (MAC, Chip, Flash), clock, timer, dice, reaction, sieve, temperature |
| `examples/abelle/esp32/` (WLAN) | scan, dhcp, dns, ping, wol (Wake-on-LAN), arpscan, ntp, udpecho (mit `udpecho.py` auf dem PC), httpget, webserver (`http://esp32.local/`), telnetd (`telnet esp32.local`: Dateien, Speicher, Ping, LED) |

Die Register, die sie benutzen, stehen in ihren Kommentaren, mit der Quelle: den Headern von ESP-IDF und dem ESP32
Technical Reference Manual. Eine Seite mit allen Beispielen: asmonite.com/de/esp32-examples.html.

## Wie der Speicher aufgeteilt ist

| Bereich | Was dort liegt |
|---|---|
| Flash `0x001000` | die Konsole (oder das Programm von Write to Flash and Run) |
| Flash `0x100000` .. `0x152000` | der Teil des WLAN für den Flash (Code und Konstanten, über den Cache) |
| Flash `0x200000` .. Ende | das Dateisystem der Konsole: zwei Verzeichnisse, dann die Dateien |
| IRAM `0x40080000` .. `0x40097FFF` | das Programm (mit WLAN: sein Code bis `0x40093000`) |
| IRAM `0x40094000` | der Dienst `wlansvc`, darüber `wlan.rom` |
| IRAM `0x4009C000` / `0x4009E000` | die Konsole / der Debug-Monitor |
| DRAM `0x3FFB0000` .. | die Daten des Programms (mit WLAN: bis `0x3FFD8000`), der Stack ab `0x3FFC0000` abwärts |
| DRAM `0x3FFD0000` | die Daten der Konsole |
| DRAM `0x3FFD8000` .. `0x3FFDFFFF`, `0x3FFE8000` .. | die Daten des WLAN und sein Heap |

## Wenn etwas nicht geht

| Meldung oder Anzeichen | Was zu tun ist |
|---|---|
| „No board with an ESP32 is plugged in“ | Das USB-Kabel (manche führen nur Strom), der Treiber des USB-Seriell-Chips |
| „… does not go into the download mode by itself: hold the BOOT button“ | BOOT gedrückt halten, bis das Programm läuft |
| „COM14 is open in another program“ | Das Terminal schließen, dann noch einmal F9 |
| „The console does not answer“ (Board Files) | Ein Programm läuft (Reset Board), oder die Konsole ist nicht im Flash (Write Console to Flash) |
| „flash read err, 1000“ am COM-Port | Der Flash ist leer (ein neues oder gelöschtes Board): Write Console to Flash |
| „wifi_connect: error 2041 (wlan.rom or wlansvc is not on the board …)“ | Install WiFi in Board Files |
| „… the access point said no“ / „no answer of the access point“ | Das Passwort in `inc/network.abel`, der Name des Netzes, ein Netz mit 2,4 GHz in Reichweite |
| Das Board startet alle paar Sekunden neu | Ein Programm im Flash, das die Watchdogs nicht abschaltet |
| „Stopped: exception at …: load/store error“ | Ein Bytezugriff auf das IRAM (siehe oben), oder eine Adresse ohne Speicher |
| „Guru Meditation Error“ am COM-Port (ein Programm aus dem Flash, ohne Debugger) | Dasselbe, oder ein Sprung an eine Adresse ohne Code |

## Grenzen

- Der ursprüngliche ESP32 hat keinen USB-JTAG: Der Debugger ist der Monitor von Asmonite im IRAM (gut 2 KB) über
  den seriellen Port; er hält nur den ersten Kern an.
- Das Programm darf `VECBASE` nicht ändern, UART0 nicht für Eingaben nutzen, keine Interrupts über Stufe 5
  einschalten und den CPU-Interrupt 14 (`INTENABLE` Bit 14) nicht abschalten: Der Monitor braucht sie.
- Den zweiten Kern benutzt das WLAN; eigene Programme laufen auf dem ersten.
- Das WLAN: nur als Station (kein eigener Access Point), offene Netze und WPA2 (kein WPA3, kein Enterprise), eine
  TCP-Verbindung zur Zeit, kein HTTPS, kein Bluetooth. Während das WLAN läuft, nichts in den Flash schreiben (kein
  Upload): vorher Reset Board.
- Die Befehle des ESP32-S3 ohne `salt` und `saltu` (der LX6 hat sie nicht: Asmonite sagt das).
- Noch nicht: eigene Programme im externen Flash (über den Cache) oder im PSRAM.
- Wie mit dem Boot-ROM gesprochen wird: das serielle Protokoll von esptool (`esptool/targets/esp32.py`).
