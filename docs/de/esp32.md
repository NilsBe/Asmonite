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
dem Debugger, Dateien ab 16 KB im Board Manager. Asmonite schaltet die Rate um, prüft sie mit einem kurzen
Austausch und fällt auf 115200 zurück, wenn das Board sie nicht schafft; gelingt die Prüfung und scheitert erst die Übertragung,
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

Ist die Konsole von Asmonite auf dem Board (Prepare Board im Board Manager) und hat das Programm keinen Breakpoint, bringt F9 es
über die Konsole ins RAM und startet es, ohne Download-Modus und ohne Reset; die Ausgabe zeigt der Reiter Serial (siehe
[boards.md](boards.md)). Vorher vergleicht Asmonite die Konsole im Flash mit seiner eigenen: Ist sie eine andere (von
einer älteren Version von Asmonite), schreibt es seine eigene über das Boot-ROM (etwa 11 Sekunden, die Dateien und das
Netz des Boards bleiben), ebenso das WLAN-Paket, wenn das Board ein anderes hat, und startet das Programm dann.

Mit einem Breakpoint, mit F7 oder F8 startet der Debugger. Ist die Konsole da, geht auch er über sie: Asmonite lädt den
Debug-Monitor über die Konsole in den RTC-FAST-Speicher, die Konsole ruft das Programm auf wie bei `run`, und der
Monitor hält es am Einstieg an. Nach dem Ende des Programms oder nach Stop ist die Konsole wieder da („Program ended
(code n)“, „Program stopped by the debugger.“), ohne Reset und ohne BOOT-Taste; die nächste Sitzung beginnt nach einer
halben Sekunde. Ohne Konsole auf dem Board, und bei Write to Flash and Run, gilt der Weg über das Boot-ROM:

F9 (ausführen) oder F7 (Einzelschritt) setzt den Chip in den Download-Modus, das Boot-ROM lädt den Debug-Monitor von
Asmonite in den RTC-FAST-Speicher und startet ihn, und der Monitor lädt das Programm bei `.imagebase` und startet es bei
`_start` (ohne `_start`: beim ersten Byte); F7 hält dort an. Dann wie bei den anderen Boards: F7 und F8 gehen Zeile für
Zeile (auch in und über `call8` und die anderen Aufrufe mit Registerfenster), F5 setzt einen Breakpoint, F9 läuft bis
zum nächsten; die Register `a0` bis `a15` des Fensters, `pc`, `ps`, `sar`, `windowbase`, `windowstart` und die
Schleifenregister stehen im Fenster der Register, das Speicherfenster liest den Speicher des Chips. Wenn das Programm
zurückkehrt, endet die Sitzung, und das Ausgabefenster zeigt seinen Wert. Es gibt zwei Arten:

- **Beginnt `_start` mit `entry`**, kommt das Programm so an, wie die Konsole es aufruft (`callx8`, mit
  Registerfenster). `retw` beendet es, sein Wert ist `a2`. Das ist der Weg für Programme, die auch über die Konsole
  laufen und zu ihr zurückkehren sollen, auch aBelle.
- **Ohne `entry`** kommt es wie bei call0: `a0` zeigt auf das Ende des Monitors, `ret` beendet es, das Ausgabefenster
  zeigt `a2` und `a3`.

**Debug > Pause** hält ein laufendes Programm an, wo es gerade ist, auch in einer Endlosschleife; **Stop** (Strg+F2)
beendet die Sitzung sofort. Dafür schickt Asmonite ein Byte über UART0: Solange das Programm läuft, löst es
im Monitor ein NMI aus (siehe unten). Ein laufendes Programm stört das nächste F9 nicht: Es setzt den Chip ohnehin
zurück.

Das Programm startet mit `sp` (`a1`) bei `0x3FFC0000` im DRAM und `ps` = `0x00040025` (Aufrufe mit Registerfenster,
Interrupt-Stufe 5: nur die Debug-Ausnahme und NMI kommen durch). Eine Ausnahme des Programms (ein ungültiger Befehl, ein
Laden von einer Adresse ohne Speicher, ein Byte-Speichern ins IRAM) hält es am Befehl an, mit dem Grund im
Ausgabefenster. Nach einem Reset (EN) läuft wieder die Firmware aus dem Flash.

So funktioniert es: Der Monitor (`src/debugger/esp32mon.asm`, gut 2 KB bei `0x400C0000` im RTC-FAST-Speicher, der 8 KB hat
und nur Kern 0 gehört) setzt `VECBASE` auf seine
eigene Vektortabelle: `break 1,15` (ein Breakpoint), der Schritt von `ICOUNT` und jede Ausnahme landen dort; er sichert
die Register und beantwortet die Befehle von Asmonite über UART0 (Register, Speicher in Wörtern, laufen, Schritt, die
Rate). Er hat die Handler der Registerfenster (Überlauf und Unterlauf von `call4`, `call8`, `call12`), wie jedes
Xtensa-Programm sie braucht, und legt unter den ersten `sp` einen Rahmen für einen Aufrufer von `_start`, den es nicht
gibt: So geht auch eine Aufrufkette, die tiefer ist, als die 64 Register fassen. Für die Pause leitet er den
Interrupt von UART0 (ein Byte im Empfangspuffer) über die Interrupt-Matrix auf den CPU-Interrupt 14, das NMI
(Stufe 7, über der Stufe 5 des Programms); eingeschaltet ist er nur, während das Programm läuft.

Das RAM von `0x40080000` bis `0x4009BFFF` (112 KB) nimmt der Debugger für das Programm an; darüber liegt die Konsole,
der Monitor liegt nicht im IRAM. Das normale Fenster, das aBelle nutzt und mit dem auch das WLAN läuft, endet bei
`0x40092FFF` (76 KB); ab `0x40093000` liegen der Dienst des WLAN und `wlan.rom`. Ein größeres Programm läuft im
**großen Fenster** bis `0x4009BFFF`, dann ohne WLAN (siehe „Das WLAN“). Es ist
**Befehls-RAM**: Der Kern liest und schreibt es nur in Wörtern zu 32 Bit. `l32i` und `s32i` gehen, `l8ui`, `l16ui`,
`s8i` halten mit einer Ausnahme an (LoadStoreError). Ein großes Programm (63 KB) lädt in knapp 6 Sekunden.

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

**Project > Write to Flash and Run (ESP32)** tut dasselbe für ein Programm mit `.target esp32` (ohne `flash`): So
geht derselbe Quelltext ohne Änderung in den RAM (F9) oder in den Flash. Weil das Programm dabei die Konsole ersetzt,
fragt Asmonite vorher nach; zurück geht es mit Prepare Board im Board Manager.

Ein Programm, das das Boot-ROM aus dem Flash startet, muss die **Watchdogs** selbst abschalten (Timergruppe 0 und 1
und den RTC-Watchdog), sonst setzt sich der Chip nach ein paar Sekunden zurück; `examples/esp32/blink_flash.asm`
zeigt, wie es geht, mit ein paar Zeilen bei `_start`.

## Die serielle Ausgabe

UART0 ist der serielle Port des Boards: Was das Programm in `UART_FIFO_REG` schreibt (`0x3FF40000`, oder wie ESP-IDF
über den AHB-Bus bei `0x60000000`), kommt am COM-Port heraus, mit 115200 Baud (das Boot-ROM hat ihn eingerichtet).
Unter dem Debugger teilt sich der Monitor den Port mit dem Programm: Was das Programm schreibt, erscheint im Reiter
**Serial** neben dem Ausgabefenster, so wie es kommt (der Reiter kommt bei der ersten Ausgabe einer Sitzung nach vorn).
Connect, Port, Baudrate und die Eingabe sind gesperrt, solange die Sitzung dauert, die Kopfzeile sagt, dass der
Debugger den Port hat; ein Port, der im Reiter verbunden war, wird beim Start der Sitzung freigegeben. Das
Ausgabefenster behält die Meldungen des Debuggers.

Ohne Debugger (ein Programm aus dem Flash nach einem Reset) ist der Reiter **Serial** neben dem Ausgabefenster ein
kleines Terminal: die Zeichen, wie sie kommen. Was du in den Reiter tippst, geht Taste für Taste an das Board, wie in
PuTTY: Enter als CR, die Rücktaste als BS, Ctrl+V fügt den Text der Zwischenablage ein; die Konsole schreibt die
Zeichen zurück und nimmt mit der Rücktaste eines zurück. Für ein Programm, das nichts zurückschreibt, blendet der
Haken **Line** in der Kopfzeile eine Zeile darunter ein, die mit Enter gesendet wird (mit CR und LF). **Connect** öffnet einen Port mit dem Port und der Baudrate aus der Kopfzeile, **Disconnect** gibt ihn für
ein anderes Terminal frei (PuTTY …); **Reset** (nur bei den USB-Seriell-Chips der ESP32-Boards) setzt den Chip
über RTS zurück, ohne den Port zu schließen, so erscheinen die ersten Zeilen des Boot-ROMs und des Programms im Flash.
Das Terminal von Asmonite lässt die Leitungen DTR und RTS aus: Manche Terminalprogramme schalten sie beim Öffnen des
Ports, das setzt den Chip zurück, und ein Programm im RAM ist weg.

## Die Konsole und ihre Dateien

`examples/esp32/console.asm` macht aus dem Board einen kleinen Rechner mit einem Dateisystem im Flash: Es reicht von
2 MB bis zum Ende des Flash (bei 4 MB also 2 MB, bei 8 MB wie auf einem WROVER 6 MB; die Konsole liest die Größe beim
Start aus dem Flash-Chip). Jedes Terminalprogramm arbeitet mit ihr (`ls`, `cat`, `put`, `rm`, `df`, `format`, `run`,
`load`, `boot`, `wlan`, `help`), und der **Board Manager** von Asmonite (Menü Board, siehe [boards.md](boards.md))
arbeitet mit ihr:

- **Prepare Board** schreibt die Konsole in den Flash (über das Boot-ROM), legt ihr Dateisystem an, wenn es
  noch keins gibt, und bringt das WLAN-Paket mit. Eine Konsole von einer älteren Version von Asmonite ersetzt F9 von
  selbst (siehe oben). Mit der Konsole kommt ihre Hilfe als Datei `help.txt` auf das Board (aus
  `examples/esp32/help.txt`); `help` zeigt sie. Fehlt sie, etwa nach `format`, zeigt `help` eine kurze Liste der
  Befehle. Mit `put help.txt` lässt sich die Hilfe auf dem Board selbst ändern; das nächste Update der Konsole
  schreibt wieder die von Asmonite.
- **This Program Autostarts** übersetzt das Programm im Editor, lädt es auf das Board und startet es
  nach jedem Reset.
- Der Board Manager zeigt die Dateien des Boards, darüber, was er über das Board weiß (Chip, Konsole, Flash), und
  sein Netz: ob das WLAN aus ist, sich verbindet oder verbunden ist, die Adresse, die MAC und den Namen
  (`name.local`). Gleich nach einem Reset fehlt die Adresse noch ein paar Sekunden: **Refresh** liest sie neu.
- **Upload File** und **Download** bringen Dateien jeder Art zwischen PC und Board hin und her (100 KB hoch in knapp
  4 Sekunden, herunter in 2), jede an ihrer CRC-32 geprüft; **Delete** löscht eine.
- **Upload This Program** übersetzt das Programm im Editor (Assembler mit `.target esp32` oder aBelle) und lädt es als
  das Image hoch, das das Boot-ROM aus dem Flash starten würde; **Run** startet es (das Fenster schließt sich, der
  Reiter Serial zeigt, was es schreibt), **Autostart** startet es nach jedem Reset. Nach einem Reset wartet die
  Konsole zuerst kurz: BOOT oder eine Taste im Terminal hält sie in der Konsole; **Reset Board** im Board Manager tut
  das auch.
- **Read Chip** liest Chip, Revision, MAC, Quarz und Flash über das Boot-ROM (das Board startet dafür neu).
- **Format** legt ein neues, leeres Dateisystem an.
- **Erase Flash** löscht den ganzen Flash über das Boot-ROM, wie bei einem neuen Board: keine
  Konsole, keine Dateien (8 bis 17 Sekunden bei 4 MB). Das Boot-ROM meldet danach bei jedem Start „flash read err,
  1000“. Prepare Board macht daraus wieder ein Board für Asmonite.
- **Install WiFi Again** schreibt das WLAN-Paket neu (selten nötig, siehe unten).
- Ein Programm für F9 passt unverändert: Sein Code darf `0x40080000..0x40092FFF` belegen (76 KB; ein größeres bis
  `0x4009BFFF`, dann ohne WLAN), seine Daten `0x3FFB0000..0x3FFCFFFF`; die Konsole liegt darüber.

**Wenn ein Programm endet, ist die Konsole wieder da.** Sie ruft es mit `callx8` auf, wie das ROM eine Funktion
aufruft, auf seinem eigenen Stack (`sp` = `0x3FFC0000`, wie unter dem Debugger). Ein Programm, das mit `entry` beginnt,
endet auf drei Arten:

- mit `retw`: Die Konsole meldet `Program ended (code n)`, n ist sein `a2`. aBelle-Programme enden so mit Code 0,
  wenn `main` zurückkehrt.
- mit `exit(code)` aus jeder Aufruftiefe: `callx8` auf `0x4009C800` (die erste der Funktionen unten).
- durch eine Ausnahme oder ein `break`: `Program stopped: exception c at pc p, address v` (c ist `EXCCAUSE`;
  `0x106` ein `break`).
- mit **Ctrl+C** vom Terminal: `Program stopped (Ctrl+C).` Im Reiter Serial von Asmonite schickt der Knopf **Stop**
  das Zeichen (oder Ctrl+C im Reiter, wenn dort nichts markiert ist; mit einer Markierung kopiert es). Das geht auch bei einer Endlosschleife
  mit gesperrten Interrupts: Solange ein Programm läuft, löst jedes Byte auf UART0 das NMI aus. Die Konsole legt die
  Bytes für `get_char` in ihren Puffer, Ctrl+C reicht sie nicht weiter. Schreibt das ROM gerade in den Flash, stoppt
  das Programm erst nach diesem Befehl. Was das Programm nicht mehr gelesen hat, verwirft die Konsole. Nur ein
  Programm, das selbst `VECBASE` oder `INTENABLE` umstellt, lässt sich so nicht stoppen; dann bleibt der Reset.

Danach stellt die Konsole ihren Stack, `ps`, `VECBASE` und `INTENABLE` wieder her. Die Peripherie und der WLAN-Dienst
auf Kern 1 bleiben, wie das Programm sie verlässt. Interrupts der Stufe 1 gibt die Konsole an die Vektoren des
Boot-ROMs weiter, damit seine Interrupt-Funktionen arbeiten wie ohne Konsole. Ein Programm ohne `entry`, etwa die
alten Beispiele, läuft wie bisher bis zum nächsten Reset.

**Funktionen der Konsole für Programme.** Ab `0x4009C800` liegt eine Tabelle mit 4 Bytes je Funktion. Ein Programm
ruft sie mit `callx8` auf, wie eine Funktion des ROMs: die Argumente in `a10` bis `a15`, das Ergebnis in `a10`.

| Adresse | Funktion |
|---|---|
| `0x4009C800` | `exit(code)`: Das Programm endet sofort. |
| `0x4009C804` | `version()`: 2 (die Funktionen dieser Tabelle; 1: ohne `args`) |
| `0x4009C808` | `put_char(c)`: ein Byte zum Terminal |
| `0x4009C80C` | `get_char()`: das nächste Byte vom Terminal; wartet darauf |
| `0x4009C810` | `poll_char()`: das nächste Byte, -1 wenn keines kam |
| `0x4009C814` | `print(text)`: ein Text bis zu seiner 0 |
| `0x4009C818` | `millis()`: Millisekunden |
| `0x4009C81C` | `file_size(name)`: die Länge einer Datei, -1 wenn es sie nicht gibt |
| `0x4009C820` | `file_read(name, puffer, offset, anzahl)`: die gelesenen Bytes, -1 wenn es die Datei nicht gibt |
| `0x4009C824` | `file_write(name, puffer, anzahl)`: 0, oder ein Fehler: -1 Verzeichnis voll, -2 kein Platz, -3 Flash-Fehler, -4 ungültiger Name, -5 kein Dateisystem |
| `0x4009C828` | `flash_read(adresse, puffer, anzahl)`: 0, -1 wenn der Flash dort nicht lesbar ist |
| `0x4009C82C` | `args()`: der Text der Argumente (siehe unten), leer bei `run` |

**Programme als Befehle.** Ein Programm hat keine Endung: Aus `blink.abel` wird `blink`, auf dem PC wie auf dem
Board (Upload This Program; ein gleichnamiges mit `.bin` von einem älteren Asmonite wird dabei gelöscht, und ein
Autostart, der darauf zeigte, zeigt dann auf das neue). Ein Wort, das die Konsole nicht kennt, sucht sie als Datei:
erst `name`, dann `name.bin` (die Programme älterer Versionen). Gibt es sie, startet die Konsole das Programm; der
Rest der Zeile sind seine Argumente, in `a2` und über `args()`. `echo hallo welt` startet also `echo` mit
`hallo welt`. Als Befehl
meldet die Konsole kein `Running` davor und kein `Program ended (code 0)` danach, nur einen anderen Code, eine
Ausnahme oder Ctrl+C. So lassen sich selten gebrauchte Befehle als Programme ins Dateisystem legen, statt die
Konsole zu vergrößern.

In den Flash schreibt ein Programm nur über Dateien. So kann es weder die Konsole noch das Dateisystem beschädigen.
`file_write` legt den neuen Inhalt erst an einer freien Stelle ab und trägt ihn dann ins Verzeichnis ein, wie `put`.
`millis()` zählt die Takte des Kerns: Ein Programm muss es mindestens alle 100 Sekunden aufrufen (bei 40 MHz).

In aBelle bringt `include "inc/console.abel"` diese Funktionen, dazu `println`, `print_int` und die anderen
Ausgaben von `inc/uart.abel`. Das Beispiel `runs.abel` zählt in der Datei `runs.txt`, wie oft es lief, und zeigt
die Tasten vom Terminal. Die Funktionen gibt es, wenn die Konsole das Programm startet: F9 ohne Breakpoint, `run`
oder ein Befehl. Mit einem Breakpoint läuft es unter dem Debugger; dort ist bisher nur `exit` erprobt. Ein Programm,
das allein aus dem Flash startet, hat keine Konsole; dort bleibt `inc/uart.abel`.

Das Fenster hat den seriellen Port, solange es offen ist (der Reiter Serial gibt ihn frei). Unter dem Debugger läuft
die Konsole nicht: Der Debug-Monitor nimmt jedes Byte auf UART0 als seine Pause. Ein Board, das vor 0.12.0 formatiert
wurde, behält sein Dateisystem von 2 MB bis zum nächsten Format.

## aBelle auf dem ESP32

aBelle ist eine kleine Sprache mit der Schreibweise von Python (Seite: asmonite.com/de/abelle.html). Ein Programm mit
`target "esp32"` übersetzt `abelle_esp32.exe` in den Code für das IRAM und die Daten für das DRAM, genau wie ein
Assemblerprogramm mit `.target esp32`; F9 lädt und debuggt es **in seinem Quelltext** (Breakpoints, F7/F8 Zeile für
Zeile, Variablen unter der Maus und im Fenster Watch), Project > Write to Flash and Run (ESP32) schreibt es in den
Flash.

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
`network.abel` (für ein Programm, das sein Netz selbst nennt; die Beispiele nehmen das Netz des Boards, `wlan set`).

## Das WLAN

Das WLAN des ESP32 steckt in Bibliotheken von Espressif (ohne Quelltext). Asmonite bindet sie einmal mit seinem eigenen
Linker zu einer festen Datei zusammen, `wlan.rom`, und bringt einen kleinen Dienst mit, `wlansvc`, der sie startet
und Programmen einfache Funktionen anbietet. **ESP-IDF braucht es dafür nicht.**

**Das WLAN-Paket:** Die Bibliothek, die Teile von `wlan.rom` für das RAM und `wlansvc` liegen zusammen in einem
festen Bereich des Flash, `0x100000` bis `0x1FFFFF`, unterhalb des Dateisystems. Bei `0x1F0000` steht ein Kopf mit
einer Kennung und je Teil Ort, Länge und CRC-32. **Du musst dafür nichts tun:** Startest du mit F9 ein Programm, das
`inc/wifi.abel` benutzt, prüft Asmonite den Kopf auf dem Board und schreibt das Paket über die Konsole, wenn es fehlt
oder ein anderes ist als das dieser Version von Asmonite (rund 370 KB, etwa 13 Sekunden); ein anderes Paket ersetzt
F9 auch bei Programmen ohne WLAN. Prepare Board legt es gleich mit an, **Install WiFi Again** im Board Manager tut
dasselbe von Hand. Läuft das WLAN gerade auf dem zweiten Kern,
schaltet die Konsole es vorher selbst ab; es startet beim nächsten Start der Konsole oder mit `wlan on` wieder.

**Das Netz des Boards:** Einmal im Reiter Serial (oder in einem anderen Terminal) `wlan set` eingeben, dann den Namen
deines WLAN und sein Passwort (leer für ein offenes Netz, sonst WPA2, 2,4 GHz). Die Konsole zeigt das Passwort nicht
an (mit **Line** zeigt die Zeile darunter Sterne). Gespeichert wird **nicht das Passwort**, sondern der Schlüssel,
den WPA2 daraus macht (PBKDF2-SHA1 aus Passwort und Name, etwa 2,5 Sekunden), in zwei eigenen Sektoren unterhalb des
WLAN-Pakets. Wer den Flash ausliest, kommt damit in dieses eine Netz, erfährt aber nicht das Passwort. `wlan` zeigt
den Namen und ob das WLAN verbunden ist, `wlan clear` löscht das Netz.

**Das WLAN als Dienst der Konsole:** Kennt das Board ein Netz, startet die Konsole das WLAN bei jedem Start selbst und
verbindet sich im Hintergrund („WiFi: connecting to … in the background“), während ihr Prompt schon da ist. Geht die
Verbindung verloren, verbindet sich der Dienst nach einer Sekunde neu, nach einem gescheiterten Versuch alle
5 Sekunden. Nach einem Reset kann das 30 bis 40 Sekunden dauern, weil der Router die verschwundene Station noch eine
Weile festhält. `wlan off` schaltet das WLAN ab, gibt RAM und Strom frei und bleibt auch nach einem Reset aus; `wlan on`
schaltet es wieder ein. Ein Programm, das `wifi_connect_saved()` aufruft, wartet dann nur auf diese Verbindung (bis zu
60 Sekunden) und ist sofort im Netz, wenn sie schon besteht.

**Die Adresse und ping ohne Programm:** Steht die Verbindung, holt sich die Konsole per DHCP eine Adresse und meldet
sie auf einer eigenen Zeile, zum Beispiel „WiFi: connected, address 192.168.1.50 (esp32-789a.local)“. Danach stehen der Prompt und das
schon Getippte wieder da. Der WLAN-Dienst auf dem zweiten Kern beantwortet ab dann ARP-Anfragen und ping für diese
Adresse selbst, auch während ein Programm läuft, das keine Pakete liest. So ist das Board nach einem Neustart oder
einem Stromausfall per ping erreichbar, ohne dass ein Programm läuft. Die Konsole fragt nach der halben Leasedauer
erneut. Geht die Verbindung verloren, meldet sie „WiFi: no connection.“ und holt nach dem nächsten Verbinden eine
neue Adresse. Ein Netzprogramm, das selbst `dhcp_run` aufruft, gibt seine Adresse ebenso an den Dienst weiter. Im
großen Fenster ist das WLAN aus, dann antwortet das Board nicht.

**Der Name des Boards:** Im Netz heißt das Board `esp32-` und die letzten vier Ziffern seiner MAC (der S3:
`esp32s3-…`). Der Router lernt den Namen per DHCP, und die Konsole beantwortet am Prompt Anfragen nach `name.local`
(mDNS): `ping esp32-789a.local`, `telnet esp32-789a.local`. `name` in der Konsole zeigt ihn, `name set keller` gibt dem
Board einen eigenen (Buchstaben, Ziffern und `-`, bis zu 31 Zeichen), `name clear` nimmt wieder den aus der MAC. Die
Konsole speichert ihn zusammen mit dem WLAN-Netz; `wlan set` und `wlan clear` lassen ihn stehen, Erase Flash löscht
ihn. Netzprogramme wie telnetd und webserver nehmen denselben Namen (`inc/net.abel` liest ihn selbst), solange sie
nicht selbst `net_set_name` aufrufen. Läuft ein Programm ohne Netz, antwortet niemand auf den Namen; ping auf die
Adresse geht trotzdem.

**Das Passwort für telnet:** `passwd set` in der Konsole fragt nach einem Passwort (8 bis 63 Zeichen, ohne Echo),
`passwd` sagt, ob eines gesetzt ist, `passwd clear` nimmt es weg. Gespeichert wird wie beim WLAN nicht das Passwort,
sondern 12 Bytes eines Schlüssels daraus (PBKDF2-SHA1 mit der MAC des Boards als Salz), zusammen mit dem Netz und dem
Namen. Ist eines gesetzt, fragt `telnetd` nach dem Verbinden danach; die Prüfung dauert etwa zwei Sekunden, nach dem
dritten falschen Passwort trennt telnetd die Verbindung. Ohne Passwort lässt telnetd jeden herein und sagt das in
seiner Begrüßung. In eigenen Programmen: `wifi_login_set()` und `wifi_login_check(passwort)` aus `inc/wifi.abel`.
telnet überträgt alles unverschlüsselt, auch das Passwort: Es schützt im eigenen Netz vor Neugierigen, nicht für den
Zugang aus dem Internet.

**telnetd als Autostart:** Findet telnetd sein Netz nicht oder bekommt es keine Adresse, meldet es das und versucht es
alle 10 Sekunden neu. Nach einem Stromausfall braucht der Router oft länger als das Board, telnetd wartet dann
einfach. Fällt das WLAN später weg, beendet telnetd die Sitzung und holt sich nach der neuen Verbindung wieder eine
Adresse. Es endet nur, wenn das Board kein Netz kennt (`wlan set`).

**Ein Programm mit WLAN:** zum Beispiel `ntp.abel` öffnen und F9 drücken. Die Beispiele verbinden sich mit
`wifi_connect_saved()` mit dem Netz des Boards, enden mit `wifi_done()` und kehren zur Konsole zurück: Die
Verbindung der Konsole bleibt, das nächste Beispiel ist sofort im Netz. Die Server (`udpecho`, `webserver`,
`telnetd`) laufen, bis du im Reiter Serial auf Stop drückst (Ctrl+C). Das Programm lädt den Dienst beim ersten WLAN-Aufruf selbst aus dem
WLAN-Paket (`inc/wifi.abel`), mit F9 genauso wie mit `run ntp` in der Konsole oder als Autostart. Ein Programm, das
sein Netz selbst nennen will, ruft `wifi_connect(name, passwort)` auf (`inc/network.abel`).

**Dateien schreiben, während das WLAN läuft:** Der Code der Bibliothek und ihre Interrupts laufen auf dem zweiten
Kern über den Cache aus dem Flash. Solange die Konsole den Flash löscht, beschreibt oder liest, darf der Cache dort
nichts holen. Deshalb parkt die Konsole den zweiten Kern vor jedem solchen Zugriff: Sie läutet über einen Interrupt
zwischen den Kernen, der Dienst wartet mit gesperrten Interrupts in einer Schleife im IRAM, bis die Konsole fertig
ist. Das geschieht bei Uploads, bei `put` und bei `file_write` eines Programms von selbst, eine Verbindung bleibt
dabei bestehen. Antwortet der zweite Kern nicht innerhalb von 200 ms, schreibt die Konsole nicht und meldet einen
Fehler des Flash.

**Ein großes Programm ohne WLAN:** Neben dem WLAN hat ein Programm 76 KB für seinen Code. Braucht es mehr, nimmt
`abelle_esp32` das **große Fenster** bis `0x4009BFFF` (112 KB) und sagt das bei der Übersetzung („Note: … it runs
without the WiFi“). Die Konsole erkennt an den Adressen des Programms, dass es in den Bereich des WLAN reicht, hält
das WLAN vorher an und startet es nach dem Ende des Programms im Hintergrund wieder. Das gilt für F9, `run` und den
Debugger. Ein Programm, das `inc/wifi.abel` einbindet, lehnt der Compiler im großen Fenster ab, denn es bräuchte genau
den Platz, den es belegt.

**Debuggen, während das WLAN läuft:** Der Dienst und das WLAN laufen auf dem **zweiten Kern** des ESP32, das Programm
auf dem ersten. Der Debugger hält nur den ersten an: Steht das Programm an einem Breakpoint, bleibt die Station
verbunden, und was ankommt, wartet in einem Puffer des Dienstes (6 Frames).

**Was ein Programm damit tun kann** (`inc/wifi.abel`, `inc/net.abel`, `inc/tcp.abel`):

| Funktion | Was sie tut |
|---|---|
| `wifi_scan`, `wifi_connect`, `wifi_status` | Netze suchen, sich verbinden (offen oder WPA2), den Zustand lesen |
| `wifi_connect_saved`, `wifi_saved_name` | sich mit dem Netz des Boards verbinden (`wlan set`), seinen Namen lesen |
| `wifi_wait_connected` | warten, bis die Konsole im Hintergrund verbunden ist |
| `wifi_done` | am Ende eines Programms: Hält die Konsole die Verbindung, bleibt sie für das nächste Programm; sonst das WLAN aus |
| `wifi_send`, `wifi_recv` | Ethernet-Frames hinaus und herein |
| `dhcp_run` | eine Adresse, die Maske, den Router und den DNS-Server vom Router holen |
| `dns_lookup` | einen Namen in eine Adresse auflösen |
| `ping_send` | einen Ping schicken (Pings an das Board beantwortet der WLAN-Dienst) |
| `wifi_set_ip`, `wifi_get_ip` | die Adresse, für die der Dienst ARP und ping beantwortet (`dhcp_run` setzt sie) |
| `udp_send`, `net_recv` | UDP |
| `tcp_connect`, `tcp_listen`, `tcp_accept`, `tcp_send`, `tcp_recv`, `tcp_close` | TCP, eine Verbindung zur Zeit, als Client oder Server |
| `net_set_name`, `mdns_start` | der Name des Boards: der Router lernt ihn per DHCP, mDNS beantwortet `name.local`; ohne `net_set_name` der Name des Boards (`name set` in der Konsole) |
| `wifi_error_text` | ein Fehler als Satz, zum Beispiel der Hinweis, wenn das WLAN-Paket fehlt |

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
| `examples/abelle/esp32/` (WLAN) | scan, dhcp, dns, ping, wol (Wake-on-LAN), arpscan, ntp, udpecho (mit `udpecho.py` auf dem PC), httpget, webserver (`http://name.local/`), telnetd (`telnet name.local`: Dateien, Speicher, Ping, LED) |

Die Register, die sie benutzen, stehen in ihren Kommentaren, mit der Quelle: den Headern von ESP-IDF und dem ESP32
Technical Reference Manual. Eine Seite mit allen Beispielen: asmonite.com/de/esp32-examples.html.

## Die Speicher des ESP32

Am Beispiel eines ESP32 DevKit V1 mit dem Modul WROOM-32:

```
 ┌─────────────────── Modul WROOM-32 ───────────────────────────────┐
 │  ┌──────────── Chip ESP32 ─────────────┐     ┌──────────────┐    │
 │  │ 2 Kerne (Xtensa LX6)                 │     │ Flash 4 MB   │    │
 │  │ ROM    448 KB  (fest, vom Werk)      │◄───►│ (eigener     │    │
 │  │ SRAM   520 KB  (der eigentliche RAM) │ SPI │  SPI-Chip)   │    │
 │  │ RTC-RAM 16 KB  (überlebt Tiefschlaf) │     └──────────────┘    │
 │  │ Cache          (holt aus dem Flash)  │                         │
 │  │ eFuses         (MAC, Chip-Version)   │     kein PSRAM          │
 │  └──────────────────────────────────────┘     (nur beim WROVER)   │
 └───────────────────────────────────────────────────────────────────┘
```

Echter RAM, schnell und beschreibbar, ist nur im Chip: **520 KB SRAM** und 16 KB RTC-RAM. Alles andere ist fest
(ROM, eFuses) oder liegt außerhalb des Chips (Flash, PSRAM) und kommt nur über den Cache herein.

**IRAM und DRAM.** Der Kern hat zwei Busse: den Befehlsbus, über den er Code holt, und den Datenbus, über den er
Daten liest und schreibt. Die 520 KB SRAM sind in drei Blöcke geteilt, und jeder hängt an einem oder an beiden:

| Block | Größe | erreichbar als | Adressen |
|---|---|---|---|
| SRAM0 | 192 KB | nur IRAM (Befehlsbus) | `0x40070000..0x4009FFFF`; die ersten 64 KB gehören dem Cache |
| SRAM1 | 128 KB | beides | DRAM `0x3FFE0000..0x3FFFFFFF` (als IRAM `0x400A0000..0x400BFFFF`) |
| SRAM2 | 200 KB | nur DRAM (Datenbus) | `0x3FFAE000..0x3FFDFFFF` |

IRAM und DRAM sind also kein verschiedener Speicher, sondern SRAM in zwei Adressfenstern. **IRAM:** Hier kann Code
laufen; Daten liest und schreibt der Kern dort nur in ganzen Wörtern zu 32 Bit (`l8ui` hält mit einer Ausnahme an).
**DRAM:** Bytes, Halbwörter und Wörter gehen, Code nicht. Darum legt Asmonite den Code ins IRAM und `.data` ins DRAM.

**Wer den IRAM teilt.** Von SRAM0 bleiben 128 KB (`0x40080000..0x4009FFFF`), und darin liegen vier Teile: das
Programm (76 KB, mit WLAN), der WLAN-Dienst (20 KB), der Teil der WLAN-Bibliothek, der im RAM laufen muss (13 KB),
und die Konsole (16 KB). Hier ist es eng; im DRAM dagegen ist Platz.

**Die anderen Speicher:**

- **ROM** (448 KB): fest im Chip, mit dem Boot-ROM und vielen Funktionen, etwa `ets_delay_us` oder dem AES, das WPA2
  benutzt. Programme rufen sie auf (`def … at 0x…` in aBelle).
- **RTC-RAM** (2 × 8 KB): bleibt im Tiefschlaf erhalten. RTC FAST (`0x400C0000`) gehört Kern 0, dort liegt der
  Debug-Monitor; RTC SLOW (`0x50000000`) ist der Speicher des ULP-Coprozessors.
- **Flash** (4 MB, ein eigener Chip): kein RAM, langsam zu schreiben, nur in Sektoren zu löschen. Der **Cache**
  blendet Teile davon in den Adressraum ein (Code ab `0x400D0000`, Daten ab `0x3F400000`) und hält die zuletzt
  gebrauchten Stücke im SRAM; so läuft der größte Teil der WLAN-Bibliothek direkt aus dem Flash, und `telnetd` liest
  die Dateien bei `0x3F400000`. Solange der Flash gelöscht oder beschrieben wird, ist der Cache aus; darum parkt die
  Konsole dann Kern 1.
- **PSRAM** (nur bei WROVER-Modulen, 4 bis 8 MB): ein RAM-Chip neben dem ESP32, ebenfalls über den Cache
  (`0x3F800000`) und nur für Daten. Asmonite nutzt ihn noch nicht.
- **eFuses:** einmal beschreibbare Bits mit der MAC, der Chip-Version und dem Quarz (Read Chip im Board Manager).

Der ESP32-S3 folgt demselben Muster mit mehr Platz: 512 KB SRAM, die IRAM und DRAM freier teilen, und je nach Modul
PSRAM, in dem dort sogar Code laufen kann.

## Wie der Speicher aufgeteilt ist

| Bereich | Was dort liegt |
|---|---|
| Flash `0x001000` | die Konsole (oder das Programm von Write to Flash and Run) |
| Flash `0x0FE000`, `0x0FF000` | das Netz des Boards (`wlan set`): Name und Schlüssel, abwechselnd beschrieben |
| Flash `0x100000` .. `0x152000` | die Bibliothek des WLAN (Code und Konstanten, über den Cache) |
| Flash `0x1F0000` .. `0x1FFFFF` | der Kopf des WLAN-Pakets, die Teile von `wlan.rom` für das RAM, `wlansvc` |
| Flash `0x200000` .. Ende | das Dateisystem der Konsole: zwei Verzeichnisse, dann die Dateien |
| IRAM `0x40080000` .. `0x40092FFF` | das Programm (im großen Fenster bis `0x4009BFFF`, dann ohne WLAN) |
| IRAM `0x40093000` | der Dienst `wlansvc`, ab `0x40098000` `wlan.rom` |
| IRAM `0x4009C000` | die Konsole |
| RTC FAST `0x400C0000` | der Debug-Monitor (nur unter dem Debugger) |
| DRAM `0x3FFB0000` .. | die Daten des Programms (mit WLAN: bis `0x3FFD8000`), der Stack ab `0x3FFC0000` abwärts |
| DRAM `0x3FFD0000` | die Daten der Konsole |
| DRAM `0x3FFD8000` .. `0x3FFDFFFF`, `0x3FFE8000` .. | die Daten des WLAN und sein Heap |

## Wenn etwas nicht geht

| Meldung oder Anzeichen | Was zu tun ist |
|---|---|
| „No board with an ESP32 is plugged in“ | Das USB-Kabel (manche führen nur Strom), der Treiber des USB-Seriell-Chips |
| „… does not go into the download mode by itself: hold the BOOT button“ | BOOT gedrückt halten, bis das Programm läuft |
| „COM14 is open in another program“ | Das Terminal schließen, dann noch einmal F9 |
| „The console of Asmonite does not answer“ (Board Manager) | Ein Programm läuft (Reset Board), oder die Konsole ist nicht im Flash (Prepare Board) |
| „flash read err, 1000“ am COM-Port | Der Flash ist leer (ein neues oder gelöschtes Board): Prepare Board im Board Manager |
| „wifi_connect: error 2041 (the WiFi package is not on the board …)“ | Das Programm mit F9 starten (Asmonite schreibt das Paket), oder Install WiFi Again im Board Manager |
| „the board keeps no WiFi network“ | `wlan set` in der Konsole (im Reiter Serial) |
| „… the access point said no“ / „no answer of the access point“ | Das Passwort (noch einmal `wlan set`), der Name des Netzes, ein Netz mit 2,4 GHz in Reichweite |
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
  TCP-Verbindung zur Zeit, kein HTTPS, kein Bluetooth.
- Solange die Station verbunden ist, kommt auf dem DevKit ab und zu ein Byte über UART0 falsch an (gemessen etwa
  eines von 500 000; schon vor dem WLAN-Dienst so, sobald ein Programm verband). Pakete prüfen ihre CRC-32 und werden
  wiederholt, Uploads und der Debugger sind also sicher. Einen großen Text darum lieber über den Board Manager hochladen,
  statt ihn mit `put` einzufügen, oder vorher `wlan off`.
- Während die Konsole das WLAN startet (beim Hochfahren, mit `wlan on`, nach einem Programm im großen Fenster),
  kann das erste Byte verloren gehen, das in diesen gut 100 ms über UART0 ankommt. Asmonite schickt ein Paket ohne
  Antwort noch einmal; getippter Text kommt in diesem Moment selten an.
- Die Befehle des ESP32-S3 ohne `salt` und `saltu` (der LX6 hat sie nicht: Asmonite sagt das).
- Noch nicht: eigene Programme im externen Flash (über den Cache) oder im PSRAM.
- Wie mit dem Boot-ROM gesprochen wird: das serielle Protokoll von esptool (`esptool/targets/esp32.py`).
