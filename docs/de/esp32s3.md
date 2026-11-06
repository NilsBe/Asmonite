# Der ESP32-S3 mit Asmonite

Der ESP32-S3 von Espressif hat zwei Xtensa-LX7-Kerne (240 MHz) und einen USB-Anschluss, der zugleich serieller Port
und JTAG-Debugger ist, wie der ESP32-C3. Asmonite assembliert Xtensa-Code (`.arch xtensa`), debuggt ein Programm im RAM
von Kern 0 und schreibt es in den Flash, **mit einem USB-Kabel, ohne Debug-Probe, ohne OpenOCD und ohne ESP-IDF**.

Getestet mit einem Board mit zwei USB-C-Anschlüssen und einer RGB-LED WS2812 an GPIO 48 (ein Anschluss geht an den
Chip, der andere über einen CH343 an UART0). Andere Boards, deren USB-Anschluss direkt zum Chip geht (GPIO 19 und 20),
sollten genauso gehen; der Anschluss eines USB-Seriell-Chips (CP2102, CH340, CH343) hat keinen USB-JTAG.

## Was du brauchst

- Ein Board mit ESP32-S3, angesteckt am USB-Anschluss des Chips. Im Geräte-Manager erscheint es als
  „USB JTAG/serial debug unit“ und als COM-Port.
- Windows 10 oder 11.

## Einmal einrichten: der USB-JTAG

Wie beim ESP32-C3: **Debug > Debug targets > ESP32-S3 > Set up the USB JTAG**. Windows fragt einmal nach
Administratorrechten; danach sollte **Test the connection** melden, dass das Board antwortet. Windows merkt sich das für
jedes Board (es erkennt das Board an seiner Seriennummer, der MAC-Adresse des Chips), an jedem USB-Anschluss des
Rechners.

Erscheint das Board nicht als „USB JTAG/serial debug unit“, sondern als anderes Espressif-Gerät (seine Firmware benutzt
den USB-Anschluss selbst, zum Beispiel ein Arduino-Sketch mit USB-CDC oder MicroPython), dann einmal **BOOT** halten,
**RST** drücken und BOOT loslassen: Der Chip wartet dann in seinem Boot-ROM und zeigt seinen USB-JTAG. Asmonite sagt das,
wenn es so ein Board findet. Sobald das erste Programm von Asmonite im Flash steht, ist das nicht mehr nötig.

## Ein Programm im RAM

```asm
.target esp32s3
.arch xtensa
.imagebase 0x40378000

_start:
    ...
```

F9 (Ausführen) oder F7 (Step into) drücken. Der Debugger setzt den Chip über den USB-Seriell-Port in den Download-Modus
seines Boot-ROMs zurück (mit den Leitungen DTR und RTS, wie esptool), hält Kern 0 dort an, lädt das Programm nach
`0x40378000` und lässt es laufen oder hält bei `_start`. So beginnt jede Sitzung mit demselben sauberen Chip: der Kern
mit 40 MHz, die Watchdogs aus, die Peripherie wie nach einem Reset. Dann: Schritte (F7, F8), Haltepunkte (F5), die
Register `a0` .. `a15`, `pc`, `ps`, `sar`, `windowbase`, `windowstart` und die Schleifenregister, der Speicher (auch als
Code). Der Stackpointer `a1` beginnt bei `0x3FCD0000`. Nach RST läuft wieder die Firmware aus dem Flash.

Das RAM von `0x40378000` bis `0x403BFFFF` (288 KB) ist frei für das Programm; darüber legt das Boot-ROM seine Daten ab.

## Xtensa in Kürze

- **Registerfenster.** `a0` .. `a15` sind ein Fenster auf 64 Register. `call8 f` ruft `f` auf; deren erster Befehl
  `entry a1, 32` dreht das Fenster um 8 und legt ihren Stack an: `a10` .. `a15` des Aufrufers sind `a2` .. `a7` der
  Funktion (die Argumente, `a2` auch das Ergebnis), `a1` ist der Stackpointer, `a0` die Rücksprungadresse. `retw` dreht
  das Fenster zurück. Eine Funktion, die aufgerufen wird, braucht `align 4` vor ihrem Label.
- **Konstanten.** `movi` lädt -2048 .. 2047; größere Konstanten und Adressen kommen mit `l32r` aus einem Literal: einem
  Wort (`dd`), das vor dem Befehl steht.
- **16-Bit-Befehle.** Wie GNU as schreibt Asmonite die 16-Bit-Form, wenn die Operanden passen (`add.n`, `l32i.n`,
  `movi.n`, `mov.n`, `ret.n` …).
- Die Befehlsreferenz auf der Website zeigt jeden Befehl mit seiner Kodierung:
  [asmonite.com/de/instr-xtensa.html](https://asmonite.com/de/instr-xtensa.html).

## Ein Programm im Flash

```asm
.target esp32s3 flash
.arch xtensa
.imagebase 0x40378000
```

F9 oder F7 schreiben das Programm jetzt in den Flash an die Adresse 0, als Image des Boot-ROMs (ein Segment bei
`.imagebase`); das Boot-ROM lädt es bei jedem Start ins RAM. Das Schreiben geht über den **seriellen Port** des Chips
(den COM-Port des Boards); kein Terminalprogramm darf diesen Port in dem Moment offen haben. Danach legt der Debugger
das Programm so ins RAM, wie es das Boot-ROM tut, und lässt es dort laufen; Haltepunkte gehen also wie bei einem
Programm im RAM. Nach RST (oder wenn das Board wieder angesteckt wird) startet das Boot-ROM es von selbst aus dem Flash.

Das ersetzt die Firmware, die vorher im Flash war.

Ein Programm, das das Boot-ROM aus dem Flash startet, muss zwei Dinge selbst tun
(`examples/esp32s3/rgb_ws2812_flash.asm` zeigt, wie, ein paar Zeilen bei `_start`):

- die **Watchdogs** abschalten (Timergruppe 0 und 1, den RTC-Watchdog und den Super-Watchdog, der sich dann selbst
  füttert): sonst setzt sich der Chip nach einigen Sekunden zurück. Der Debugger schaltet sie ebenfalls ab; unter dem
  Debugger läuft ein Programm also auch ohne diese Zeilen.
- den **Takt** setzen, wenn es Zeit misst: Aus dem Flash lässt das Boot-ROM den Kern auf 20 MHz, in seinem
  Download-Modus auf 40 MHz (`SYSTEM_SYSCLK_CONF` bei `0x600C0060`, `PRE_DIV_CNT` = 0 ergibt 40 MHz).

## Die Beispiele

| Datei | Was sie tut |
|---|---|
| `examples/esp32s3/rgb_ws2812_ram.asm` | Die RGB-LED WS2812 an GPIO 48: rot, grün und blau im Wechsel, je eine halbe Sekunde. Die 24 Farbbits werden mit dem Taktzähler `ccount` getaktet; Aufrufe mit Registerfenster über `call8`, `entry`, `retw` |
| `examples/esp32s3/rgb_ws2812_flash.asm` | Dasselbe im Flash, mit abgeschalteten Watchdogs und gesetztem Takt am Anfang |

Die Register, die sie benutzen, stehen in ihren Kommentaren, mit der Quelle: den Headern von ESP-IDF und dem ESP32-S3
Technical Reference Manual.

## Wenn etwas nicht geht

| Meldung oder Zeichen | Was tun |
|---|---|
| „an Espressif chip is plugged in, but its firmware uses the USB port itself“ | BOOT halten, RST drücken, BOOT loslassen; dann noch einmal F9 |
| „No ESP32-S3 with its USB JTAG (303A:1001) is plugged in“ | Den anderen USB-Anschluss des Boards nehmen (den am Chip), oder Debug targets > ESP32-S3 > Set up the USB JTAG |
| „COM13 is open in another program“ | Das Terminal schließen, dann noch einmal F9 |
| Die Farben des RGB-Beispiels stimmen nicht oder sind weiß | Die Zeiten der WS2812 sind in Takten gerechnet: Das Programm muss mit 40 MHz laufen (siehe oben) |
| Das Board startet alle paar Sekunden neu | Ein Programm im Flash, das die Watchdogs nicht abschaltet; F9 mit einem Programm, das es tut (der Debugger holt den Chip aus der Schleife) |

## Grenzen

- Nur Kern 0; der zweite Kern wird nicht gestartet und nicht gedebuggt.
- Noch nicht: die MAC16- und Vektorbefehle (`ee.*`) des ESP32-S3, Programme im externen Flash oder PSRAM (nur das
  interne RAM), WLAN und Bluetooth.
- Der ursprüngliche ESP32 (Xtensa LX6) hat dieselben Befehle (ohne `salt`, `saltu`), aber keinen USB-JTAG: Asmonite
  startet und flasht ihn über den seriellen Port des Boards, ohne Debugger ([esp32.md](esp32.md)).
- Wie der Chip das Debuggen macht: das Protokoll von `esp_usb_jtag.c` und das Xtensa-Debug-Modul von OpenOCD
  (`src/target/xtensa`).
