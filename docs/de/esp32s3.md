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

Ist die Konsole von Asmonite auf dem Board (Prepare Board im Board Manager) und hat das Programm keinen Breakpoint, bringt F9 es
über die Konsole ins RAM und startet es, ohne Download-Modus und ohne Reset; die Ausgabe zeigt der Reiter Serial (siehe
[boards.md](boards.md)). Eine Konsole von einer älteren Version von Asmonite ersetzt F9 vorher von selbst (etwa
2 Sekunden, die Dateien und das Netz des Boards bleiben), ebenso ein anderes WLAN-Paket.

Mit einem Breakpoint, mit F7 oder F8 startet der Debugger. Ist die Konsole da, geht auch er ohne Reset: Asmonite
verbindet sich mit dem USB-JTAG, wie er ist, die Konsole ruft ihren Gastgeber `dbg_host` auf wie ein Programm, und der
Kern hält dort an; der Debugger lädt das Programm über JTAG und startet es von dort. Nach dem Ende des Programms
(auch mit `exit()` oder einer Ausnahme, die die Konsole fängt) oder nach Stop ist die Konsole wieder da; die nächste
Sitzung beginnt nach einer halben Sekunde. Ohne Konsole auf dem Board, und für ein Programm für den Flash, gilt der
Weg über das Boot-ROM:

F9 (Ausführen) oder F7 (Step into) drücken. Der Debugger setzt den Chip über den USB-Seriell-Port in den Download-Modus
seines Boot-ROMs zurück (mit den Leitungen DTR und RTS, wie esptool), hält Kern 0 dort an, lädt das Programm nach
`0x40378000` und lässt es laufen oder hält bei `_start`. So beginnt jede Sitzung mit demselben sauberen Chip: der Kern
mit 40 MHz, die Watchdogs aus, die Peripherie wie nach einem Reset. Dann: Schritte (F7, F8), Breakpoints (F5), die
Register `a0` .. `a15`, `pc`, `ps`, `sar`, `windowbase`, `windowstart` und die Schleifenregister, der Speicher (auch als
Code). Der Stackpointer `a1` beginnt bei `0x3FCAFFE0`, am oberen Ende des Datenfensters der Programme (32 Bytes unter
`0x3FCB0000`, wo der WLAN-Dienst beginnt). Beginnt `_start` mit `entry`, kommt das Programm wie aus der Konsole
(`callx8`, mit Registerfenster), und `retw` beendet die Sitzung mit seinem `a2`. Ohne `entry` kommt es wie bei call0,
und `ret` beendet sie. In beiden Fällen zeigt `a0` auf eine Endmarke (`0x403D8000`, ein `break` im freien RAM). Nach
RST läuft wieder die Firmware aus dem Flash.

Das RAM von `0x40378000` bis `0x403BFFFF` (288 KB) nimmt der Assembler für ein Programm an; darüber liegt die Konsole.
Das normale Fenster, das aBelle nutzt und mit dem auch das WLAN läuft: Code `0x40378000 .. 0x4038FFFF` (96 KB), Daten
`0x3FCA0000 .. 0x3FCAFFFF` (64 KB, der Stack in den oberen 4 KB), siehe [Das WLAN](#das-wlan).

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
das Programm so ins RAM, wie es das Boot-ROM tut, und lässt es dort laufen; Breakpoints gehen also wie bei einem
Programm im RAM. Nach RST (oder wenn das Board wieder angesteckt wird) startet das Boot-ROM es von selbst aus dem Flash.

Das ersetzt die Firmware, die vorher im Flash war.

Ein Programm, das das Boot-ROM aus dem Flash startet, muss zwei Dinge selbst tun
(`examples/esp32s3/rgb_ws2812_flash.asm` zeigt, wie, ein paar Zeilen bei `_start`):

- die **Watchdogs** abschalten (Timergruppe 0 und 1, den RTC-Watchdog und den Super-Watchdog, der sich dann selbst
  füttert): sonst setzt sich der Chip nach einigen Sekunden zurück. Der Debugger schaltet sie ebenfalls ab; unter dem
  Debugger läuft ein Programm also auch ohne diese Zeilen.
- den **Takt** setzen, wenn es Zeit misst: Aus dem Flash lässt das Boot-ROM den Kern auf 20 MHz, in seinem
  Download-Modus auf 40 MHz (`SYSTEM_SYSCLK_CONF` bei `0x600C0060`, `PRE_DIV_CNT` = 0 ergibt 40 MHz).

## Die serielle Ausgabe und Bytes im RAM

Der USB-Anschluss des Chips hat zwei Teile: den JTAG des Debuggers und einen seriellen Port (CDC; im Geräte-Manager
„USB Serial Device (COM13)“). Was ein Programm in das Peripheral USB Serial/JTAG schreibt (`0x60038000`: ein Byte in
`EP1`, dann `WR_DONE` in `EP1_CONF`), kommt an diesem COM-Port heraus, auch während der Debugger den JTAG hat. Der
Reiter **Serial** neben dem Ausgabefenster verbindet sich von selbst damit, wenn der Debugger das Programm geladen hat:
Der Reset ins Boot-ROM und das Schreiben des Flash gehen über diesen Port, deshalb gibt der Reiter ihn beim Start der
Sitzung frei und öffnet ihn danach wieder. Bei der ersten Ausgabe des Programms kommt der Reiter nach vorn, wie beim
ESP32. Connect und Disconnect bleiben benutzbar.
`examples/esp32s3/hello_usb_ram.asm` schreibt dort einmal pro Sekunde „Hello, world!“.

Das RAM des Programms ist ein Speicher an zwei Bussen. Unter seiner IRAM-Adresse (`0x40378000` ..) holt der Kern
Befehle und liest und schreibt nur Wörter: `l8ui`, `l16ui`, `s8i` halten dort mit einem LoadStoreError an, wie beim
ESP32. Am Datenbus liegt dasselbe Byte `0x6F0000` tiefer (`0x3FC88000` für `0x40378000`), und dort gehen Bytes: Das
Beispiel zieht `0x6F0000` von der Adresse seines Textes ab, bevor es ihn liest.

## aBelle auf dem ESP32-S3

Ein Programm in aBelle mit `target "esp32s3"` übersetzt `abelle_esp32.exe` (derselbe Compiler wie für den ESP32) in
den Code für das RAM ab `0x40378000` (bis 96 KB) und die Daten ab `0x3FCA0000` (bis 60 KB, dasselbe RAM über den
Datenbus, hinter dem Code; dort gehen auch Bytes; darüber der Stack und das WLAN). F9 lädt es über den USB-JTAG und debuggt es **im Quelltext**: Breakpoints, F7/F8 Zeile für
Zeile, Variablen unter der Maus und im Fenster Watch. Funktionen des Boot-ROMs werden wie beim ESP32 mit `at` und
ihrer Adresse bekannt gemacht; sie liegen beim S3 woanders (`ets_delay_us` bei `0x40000600`, beim ESP32 bei
`0x40008534`; `esp32s3.rom.ld` von ESP-IDF). Beispiel: `examples/abelle/esp32s3/hello_usb.abel` schreibt „Hello,
world!“ und einen Zähler über den USB-Anschluss des Chips; `examples/abelle/esp32s3/rgb.abel` lässt die RGB-LED des
Boards (GPIO 48) in Rot, Grün, Blau und im Farbkreis leuchten, die Impulse der WS2812 erzeugt der RMT;
`examples/abelle/esp32s3/scan.abel` zeigt die WLAN-Netze in der Nähe (siehe [Das WLAN](#das-wlan)).

## Die Konsole und ihre Dateien

`examples/esp32s3/console.asm` ist die Konsole des ESP32 (siehe [esp32.md](esp32.md)) für den S3: dieselben Befehle
(`ls`, `cat`, `put`, `rm`, `df`, `format`, `run`, `load`, `boot`, `help`), dasselbe Dateisystem im Flash ab 2 MB bis
zu seinem Ende (bei 16 MB also gut 14 MB) und dieselben Pakete für Asmonite. Sie spricht über den USB-Anschluss des
Chips: jedes Terminalprogramm am COM-Port des Chips, die Baudrate spielt keine Rolle.

Der **Board Manager** (Menü Board, siehe [boards.md](boards.md)) arbeitet mit dem S3 wie mit dem ESP32; sind
mehrere Boards angesteckt, wählst du es links in der Liste:

- **Prepare Board** schreibt die Konsole über das Boot-ROM in den Flash (beim S3 an die Adresse 0) und legt
  das Dateisystem an, wenn es noch keins gibt. Antwortet noch keine Konsole, weiß Asmonite nicht, ob ein S3 oder ein
  C3 angesteckt ist (beide haben dieselbe USB-Kennung): Prepare Board und **Read Chip** fragen dann zuerst das Boot-ROM.
- **Upload File**, **Download**, **Delete**, **Run**, **Autostart**, **Reset Board**, **Format**, **This Program
  Autostarts** und **Erase Flash** wie beim ESP32. **Upload This Program** nimmt ein Programm mit `.target esp32s3`
  oder `target "esp32s3"` und weist eines für den ESP32 ab.
- Ein Programm aus der Konsole darf das ganze RAM der Programme nutzen: Code `0x40378000 .. 0x403BFFFF`, Daten im
  selben RAM über den Datenbus `0x3FC88000 .. 0x3FCCFFFF`; ein Programm für F9 passt unverändert. Die Konsole selbst
  liegt darüber (Code ab `0x403C0000`, Daten ab `0x3FCD8000`). Mit dem WLAN gehört der obere Teil davon dem WLAN.
- **Install WiFi Again** schreibt das WLAN-Paket neu (selten nötig, siehe [Das WLAN](#das-wlan)).
- **Wenn ein Programm endet, ist die Konsole wieder da**, wie beim ESP32: `retw` (Meldung `Program ended (code n)`),
  `exit(code)` mit `callx8` auf `0x403C0800`, eine Ausnahme bzw. ein `break` (`Program stopped: …`) oder **Ctrl+C**
  (Knopf Stop im Reiter Serial; ein Paket über den USB-Anschluss löst das NMI aus, auch bei gesperrten Interrupts). Das Programm
  läuft auf seinem eigenen Stack (`0x3FCAFFE0`).
- **Funktionen der Konsole für Programme** wie beim ESP32, ab `0x403C0800` (`exit`, `version`, `put_char`,
  `get_char`, `poll_char`, `print`, `millis`, `file_size`, `file_read`, `file_write`, `flash_read`, `args`, je 4
  Bytes; die Tabelle steht in der Seite zum ESP32). Auch Programme als Befehle wie dort: `name args` startet
  `name` oder `name.bin` aus den Dateien. In aBelle: `include "inc/console.abel"`, Beispiel `runs.abel`. Unter dem
  Debugger und ohne Konsole bleibt `inc/usb.abel`.
- Nach einem Reset wartet die Konsole bei einem Autostart **3 Sekunden** (beim ESP32 eine): Mit dem Reset geht der
  USB-Anschluss kurz weg und kommt wieder, erst dann kann ein Terminal eine Taste schicken.

Ein Reset über RTS (wie Reset Board) setzt nur den Chip zurück, der USB-Anschluss bleibt: Ein Terminal darf offen
bleiben. Manche Terminalprogramme schalten beim Öffnen des Ports RTS und setzen den Chip damit zurück; die Konsole
startet dann neu.

## Das WLAN

Das WLAN des S3 kommt aus den Bibliotheken von Espressif (`wlan/`, gelinkt mit `python wlan/make_wlan.py --chip
esp32s3`), mit einer eigenen Betriebssystem-Schicht in Assembler statt FreeRTOS, wie beim ESP32 ([esp32.md](esp32.md)).
Ein Dienst (`wlan/wlansvc_s3.asm`) läuft auf **Kern 1**, während ein Programm oder die Konsole auf Kern 0 läuft; der
Debugger hält nur Kern 0 an, das WLAN läuft weiter.

1. Das **WLAN-Paket** liegt wie beim ESP32 im Flash von `0x100000` bis `0x1FFFFF`: die Bibliothek, bei `0x1F0000` ein
   Kopf, dahinter die Teile von `wlan.rom` für das RAM und `wlansvc`. Startest du mit F9 ein Programm mit
   `inc/wifi.abel`, schreibt Asmonite das Paket über die Konsole, wenn es fehlt oder nicht passt (rund 300 KB, etwa
   8 Sekunden). Prepare Board legt es gleich mit an, **Install WiFi Again** im Board Manager tut es von Hand.
2. Ein Programm in aBelle mit `include "inc/wifi.abel"` (aus `examples/abelle/esp32s3/inc/`) lädt den Dienst selbst
   aus dem Paket, mit `run` in der Konsole wie unter dem Debugger. `examples/abelle/esp32s3/scan.abel` zeigt die
   Netze in der Nähe. Während die Konsole den Flash benutzt, parkt sie Kern 1 wie beim ESP32 ([esp32.md](esp32.md)):
   Dateien lassen sich bei laufendem WLAN schreiben, eine Verbindung bleibt bestehen.
3. Mit einem Netz verbinden (offen oder WPA2): einmal `wlan set` im Reiter Serial, dann Name und Passwort, wie beim
   ESP32 ([esp32.md](esp32.md)). Die Konsole speichert den Namen und den Schlüssel, nicht das Passwort (etwa
   2,3 Sekunden), in den Sektoren `0xFE000` und `0xFF000`. Die Beispiele sind dieselben wie beim ESP32 ([esp32.md](esp32.md)): `dhcp.abel`, `ping.abel`, `dns.abel`,
   `ntp.abel`, `httpget.abel`, `webserver.abel`, `udpecho.abel`, `wol.abel`, `arpscan.abel`, `telnetd.abel` (die
   Dateien des Boards über die MMU des S3, `led` schaltet die RGB-LED WS2812 an GPIO 48); sie verbinden sich mit
   `wifi_connect_saved()` mit dem Netz des Boards; ihren Text schreiben sie
   über den USB-Anschluss des Chips (`inc/usb.abel` statt `inc/uart.abel`), der Reiter Serial zeigt ihn. `net.abel` und
   `tcp.abel` sind die des ESP32. Für WPA2 entpackt der Dienst den Gruppenschlüssel selbst (AES Key Unwrap nach
   RFC 3394): Das ROM des S3 hat dafür keine Funktion, anders als das des ESP32.
4. Wie beim ESP32 holt sich die Konsole nach dem Verbinden per DHCP eine Adresse („WiFi: connected, address …“), und
   der Dienst beantwortet ARP und ping für sie selbst: Das Board ist auch ohne Programm per ping erreichbar
   ([esp32.md](esp32.md)).

Das RAM mit dem WLAN (Code- und Datenbus sind dasselbe RAM, `0x6F0000` auseinander):

| Bereich | Adressen |
|---|---|
| Code des Programms | `0x40378000 .. 0x4038FFFF` |
| Daten des Programms, Stack | `0x3FCA0000 .. 0x3FCAFFFF` |
| der Dienst (`wlansvc`) | `0x403A0000 ..` (Einträge), Daten ab `0x3FCB6000` |
| `wlan.rom` | `0x403A8000 ..` und `0x3FCBC000 ..` |
| Heap des WLAN | `0x3FCC1000 .. 0x3FCCFFFF` |
| Puffer des WLAN, Stack von Kern 1 | `0x3FCDF000 .. 0x3FCE7FFF`, über den Daten der Konsole |

**Ein großes Programm ohne WLAN:** Braucht ein aBelle-Programm mehr als 96 KB Code oder 60 KB Daten, nimmt
`abelle_esp32` das **große Fenster** und sagt das bei der Übersetzung („Note: … it runs without the WiFi“): Der Code
darf dann bis `0x4039EFFF` reichen (156 KB, über das Datenfenster bis zum Stack), die Daten liegen ab `0x3FCB0000`
(bis 128 KB, der Bereich des Dienstes, von `wlan.rom` und des Heaps). Die Konsole erkennt an den Adressen, dass das
Programm in den Bereich des WLAN reicht, hält das WLAN vorher an und startet es nach dem Ende des Programms im
Hintergrund wieder; mit F9, `run` und dem Debugger. Ein Programm mit `inc/wifi.abel` lehnt der Compiler im großen
Fenster ab.

## Die Beispiele

| Datei | Was sie tut |
|---|---|
| `examples/esp32s3/rgb_ws2812_ram.asm` | Die RGB-LED WS2812 an GPIO 48: rot, grün und blau im Wechsel, je eine halbe Sekunde. Die 24 Farbbits werden mit dem Taktzähler `ccount` getaktet; Aufrufe mit Registerfenster über `call8`, `entry`, `retw` |
| `examples/esp32s3/rgb_ws2812_flash.asm` | Dasselbe im Flash, mit abgeschalteten Watchdogs und gesetztem Takt am Anfang |
| `examples/esp32s3/hello_usb_ram.asm` | „Hello, world!“ einmal pro Sekunde über den USB-Anschluss des Chips: der Reiter Serial zeigt es |

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

- Nur Kern 0 wird gedebuggt; den zweiten Kern startet nur der WLAN-Dienst.
- Noch nicht: die MAC16- und Vektorbefehle (`ee.*`) des ESP32-S3, Programme im externen Flash oder PSRAM (nur das
  interne RAM), Bluetooth.
- Der ursprüngliche ESP32 (Xtensa LX6) hat dieselben Befehle (ohne `salt`, `saltu`), aber keinen USB-JTAG: Asmonite
  debuggt ihn über den seriellen Port des Boards mit einem eigenen Monitor ([esp32.md](esp32.md)).
- Wie der Chip das Debuggen macht: das Protokoll von `esp_usb_jtag.c` und das Xtensa-Debug-Modul von OpenOCD
  (`src/target/xtensa`).
