# Der ESP32 mit Asmonite

Der ursprüngliche ESP32 von Espressif hat zwei Xtensa-LX6-Kerne (240 MHz). Asmonite assembliert seinen Code
(`.arch xtensa`, `.target esp32`), lädt ein Programm in sein RAM oder schreibt es in seinen Flash und debuggt es,
**über das USB-Kabel des Boards, ohne JTAG-Probe, ohne esptool und ohne ESP-IDF**: Haltepunkte, Einzelschritte, die
Register, der Speicher. Ein kleiner Debug-Monitor von Asmonite läuft neben dem Programm und spricht über den seriellen
Port mit Asmonite.

Getestet mit einem ESP32 DevKit V1 (ESP32-D0WD, ein CP2102 als USB-Seriell-Chip, die blaue LED an GPIO 2).

## Was du brauchst

- Ein Board mit ESP32 und USB-Seriell-Chip: CP2102 oder CP2104, CH340, CH9102, CH343 oder ein FTDI-Chip. Im
  Geräte-Manager erscheint es als COM-Port, zum Beispiel „Silicon Labs CP210x USB to UART Bridge (COM14)“. Den Treiber
  der meisten dieser Chips bringt Windows mit, sonst kommt er vom Hersteller des Chips.
- Windows 10 oder 11.

**Debug > Debug targets > ESP32 > Test the connection** zeigt, ob das Board antwortet: seinen COM-Port und seine
MAC-Adresse.

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
Zeile (auch in und über `call8` und die anderen Aufrufe mit Registerfenster), F5 setzt einen Haltepunkt, F9 läuft bis
zum nächsten; die Register `a0` bis `a15` des Fensters, `pc`, `ps`, `sar`, `windowbase`, `windowstart` und die
Schleifenregister stehen im Fenster der Register, das Speicherfenster liest den Speicher des Chips. Ein Programm, das
mit `ret` zurückkehrt (wie bei call0: `_start` bekommt in `a0` das Ende des Monitors), beendet die Sitzung; das
Ausgabefenster zeigt `a2` und `a3`.

**Noch keine Pause:** Der Monitor hört nur zu, solange das Programm angehalten ist. Setze einen Haltepunkt, bevor das
Programm in eine Schleife läuft. Ein laufendes Programm stört das nächste F9 nicht: Es setzt den Chip ohnehin zurück.

Das Programm startet mit `sp` (`a1`) bei `0x3FFC0000` im DRAM und `ps` = `0x00040025` (Aufrufe mit Registerfenster,
Interrupt-Stufe 5: nur die Debug-Ausnahme und NMI kommen durch). Eine Ausnahme des Programms (ein ungültiger Befehl, ein
Laden von einer Adresse ohne Speicher, ein Byte-Speichern ins IRAM) hält es am Befehl an, mit dem Grund im
Ausgabefenster. Nach einem Reset (EN) läuft wieder die Firmware aus dem Flash.

So funktioniert es: Der Monitor (`src/debugger/esp32mon.asm`, 2 KB bei `0x4009E000`) setzt `VECBASE` auf seine eigene
Vektortabelle: `break 1,15` (ein Haltepunkt), der Schritt von `ICOUNT` und jede Ausnahme landen dort; er sichert die
Register und beantwortet die Befehle von Asmonite über UART0 (Register, Speicher in Wörtern, laufen, Schritt). Er hat
die Handler der Registerfenster (Überlauf und Unterlauf von `call4`, `call8`, `call12`), wie jedes Xtensa-Programm sie
braucht.

Das RAM von `0x40080000` bis `0x4009DFFF` (120 KB) ist für das Programm frei; darüber liegt der Monitor. Es ist
**Befehls-RAM**: Der Kern liest
und schreibt es nur in Wörtern zu 32 Bit. `l32i` und `s32i` gehen, `l8ui`, `l16ui`, `s8i` halten mit einer Ausnahme
an (LoadStoreError); `examples/esp32/hello_uart_ram.asm` liest seinen Text deshalb wortweise.

Der Kern läuft mit 40 MHz (dem Quarz), im Download-Modus und nach einem Start aus dem Flash.

## Ein Programm im Flash

```asm
.target esp32 flash
.arch xtensa
.imagebase 0x40080000
```

F9 oder F7 schreiben das Programm in den Flash an die Adresse `0x1000`, als Image des Boot-ROMs (Chip-ID 0, ein
Segment bei `.imagebase`), über das Boot-ROM; dann startet der Debugger den Monitor neu, lädt das Programm ins IRAM, wie
das Boot-ROM es bei jedem Start tut, und debuggt es dort. Nach einem Reset (EN) startet das Boot-ROM es von selbst aus
dem Flash. Es ersetzt die Firmware, die vorher im Flash war (ihr Bootloader steht bei `0x1000`). Während der Flash
geschrieben wird, darf kein Terminal den COM-Port offen haben.

Ein Programm, das das Boot-ROM aus dem Flash startet, muss die **Watchdogs** selbst abschalten (Timergruppe 0 und 1
und den RTC-Watchdog), sonst setzt sich der Chip nach ein paar Sekunden zurück; `examples/esp32/blink_flash.asm`
zeigt, wie es geht, mit ein paar Zeilen bei `_start`.

## Die serielle Ausgabe

UART0 ist der serielle Port des Boards: Was das Programm in `UART_FIFO_REG` (`0x3FF40000`) schreibt, kommt am COM-Port
heraus, mit 115200 Baud (das Boot-ROM hat ihn eingerichtet). Unter dem Debugger teilt sich der Monitor den Port mit dem
Programm: Was das Programm schreibt, erscheint im Ausgabefenster, Zeile für Zeile (`UART0: Hello, world!`).

Ohne Debugger (ein Programm aus dem Flash nach einem Reset) ist der Reiter **Serial** neben dem Ausgabefenster ein
kleines Terminal: die Zeichen, wie sie kommen; eine Zeile, die unten eingegeben wird, geht mit Enter an das Board (mit
CR und LF). **Connect** öffnet einen Port mit dem Port und der Baudrate aus der Kopfzeile, **Disconnect** gibt ihn für
ein anderes Terminal frei (PuTTY …); **Reset** (nur bei den USB-Seriell-Chips der ESP32-Boards) setzt den Chip
über RTS zurück, ohne den Port zu schließen, so erscheinen die ersten Zeilen des Boot-ROMs und des Programms im Flash.
Das Terminal von Asmonite lässt die Leitungen DTR und RTS aus: Manche Terminalprogramme schalten sie beim Öffnen des
Ports, das setzt den Chip zurück, und ein Programm im RAM ist weg.

## Die Beispiele

| Datei | Was es tut |
|---|---|
| `examples/esp32/blink_ram.asm` | Die LED an GPIO 2 an und aus, je eine halbe Sekunde, gezählt mit dem Taktzähler `ccount` |
| `examples/esp32/blink_flash.asm` | Dasselbe im Flash, mit den Watchdogs am Anfang abgeschaltet |
| `examples/esp32/hello_uart_ram.asm` | „Hello, world!“ einmal pro Sekunde über UART0 (den COM-Port des Boards) |

Die Register, die sie benutzen, stehen in ihren Kommentaren, mit der Quelle: den Headern von ESP-IDF und dem ESP32
Technical Reference Manual.

## Wenn etwas nicht geht

| Meldung oder Anzeichen | Was zu tun ist |
|---|---|
| „No board with an ESP32 is plugged in“ | Das USB-Kabel (manche führen nur Strom), der Treiber des USB-Seriell-Chips |
| „… does not go into the download mode by itself: hold the BOOT button“ | BOOT gedrückt halten, bis das Programm läuft |
| „COM14 is open in another program“ | Das Terminal schließen, dann noch einmal F9 |
| Das Board startet alle paar Sekunden neu | Ein Programm im Flash, das die Watchdogs nicht abschaltet |
| „Stopped: exception at …: load/store error“ | Ein Bytezugriff auf das IRAM (siehe oben), oder eine Adresse ohne Speicher |
| „Guru Meditation Error“ am COM-Port (ein Programm aus dem Flash, ohne Debugger) | Dasselbe, oder ein Sprung an eine Adresse ohne Code |

## Grenzen

- Noch keine Pause eines laufenden Programms (siehe oben). Der ursprüngliche ESP32 hat keinen USB-JTAG: Der Debugger
  ist der Monitor von Asmonite im IRAM (2 KB) über den seriellen Port.
- Das Programm darf `VECBASE` nicht ändern, UART0 nicht für Eingaben nutzen und keine Interrupts über Stufe 5
  einschalten: Der Monitor braucht sie.
- Nur Kern 0; der zweite Kern wird nicht gestartet.
- Die Befehle des ESP32-S3 ohne `salt` und `saltu` (der LX6 hat sie nicht: Asmonite sagt das).
- Noch nicht: das DRAM als zweites Segment, Programme im externen Flash (Cache) oder PSRAM, WLAN und Bluetooth.
- Wie mit dem Boot-ROM gesprochen wird: das serielle Protokoll von esptool (`esptool/targets/esp32.py`).
