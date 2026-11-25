# Änderungen

Was sich von Version zu Version geändert hat. Englisch: [CHANGELOG.md](../../CHANGELOG.md).

Versionsnummern: MAJOR.MINOR.PATCH. Solange MAJOR 0 ist, darf ein MINOR-Schritt ändern, was
vorhandene Quelltexte bedeuten; solche Änderungen stehen unter „Geändert“ und sind mit
**(Quelltexte)** markiert.

## Noch nicht veröffentlicht

### Neu
- **aBelle: der Takt des Kerns in einem Programm (ESP32, Pico, Pico 2)**: `cpu_clock(mhz)` aus dem neuen `cpuclock.abel`
  (`include "cpuclock.abel"`): beim ESP32 80, 160 oder 240 MHz vom PLL und 40, 20, 10, 8, 5, 4, 2 oder 1 MHz vom Quarz
  (nicht bei laufendem WLAN), beim Pico jedes ganze MHz von 48 bis 133, beim Pico 2 von 48 bis 150; 0 fragt nur.
  `millis()` und das Terminal laufen richtig weiter, beim ESP32 auch das WLAN. Die Konsole behält den Takt, den ein
  Programm hinterlässt (auch nach Ctrl+C): `info` und die Zeile „CPU clock“ im Board Manager zeigen ihn, ein Reset
  bringt den Standardtakt zurück; nur Takte, bei denen sie nicht erreichbar wäre, behält sie nicht (der ESP32 unter
  1 MHz: zurück auf 40 MHz; Pico und Pico 2 vom Quarz: zurück auf 48 MHz, dort kann Windows den Port nicht neu öffnen).
  Gemessen: dieselbe Arbeit dauert beim ESP32 bei 1, 40, 80, 160 und 240 MHz 12900, 322, 161, 80 und 54 ms, beim Pico
  bei 48, 100 und 133 MHz 269, 129 und 97 ms, beim Pico 2 bei 48, 100 und 150 MHz 200, 96 und 64 ms. Die Konsolen von
  ESP32, Pico und Pico 2 sind dafür neu (Prepare Board), der WLAN-Dienst des ESP32 auch (Version 12: Er behält den Takt,
  den ein Programm eingestellt hat; Install WiFi). Der UART der Konsolen der Picos läuft jetzt vom USB-PLL, nicht mehr
  vom Takt des Kerns. Bis hinunter zu ein paar kHz mit `cpu_clock_khz(khz)`: beim ESP32 vom Quarz bis 39 kHz, von seinem
  Oszillator RC_FAST bis etwa 5 kHz (unter 1 MHz schweigt das Terminal, und `millis()` zählt falsch); beim Pico und Pico
  2 1 bis 12000 kHz vom Quarz (das Terminal läuft weiter, `millis()` stimmt bis etwa 1 MHz). Ausführlich:
  `docs/de/takt.md`.
- **aBelle: der Takt des Kerns beim ESP32-S3**: `cpu_clock(mhz)` aus `abelle/lib/esp32s3/cpuclock.abel`: 80, 160 oder
  240 MHz vom PLL, 40, 20 oder 10 MHz vom Quarz (nicht bei laufendem WLAN). Nicht unter 10 MHz: Der USB-Anschluss des
  Chips, über den die Konsole spricht, hört dort auf zu arbeiten (Zeichen doppelt bei 8 bis 4 MHz, bei 2 und 1 MHz ein
  toter Port). Für 240 MHz hebt `cpu_clock` die Spannung des Kerns um eine Stufe an und senkt sie danach wieder; bei
  laufendem WLAN macht das der WLAN-Dienst auf Kern 1 (der Funkteil benutzt denselben Bus im Chip), sonst schreibt die
  Bibliothek die Register selbst (der Weg über das ROM stürzte direkt nach `wlan on` ab). Die Konsole behält den Takt,
  den ein Programm hinterlässt, `info` zeigt ihn. Gemessen: dieselbe Arbeit dauert bei 10, 40, 80, 160 und 240 MHz 370,
  93, 46, 24 und 15 ms; mit verbundenem WLAN gehen Pings und DNS bei 80, 160 und 240 MHz. Neue Konsole (Prepare Board)
  und WLAN-Dienst Version 13 (Install WiFi; er behält beim Neustart des WLAN einen Takt vom PLL, auch beim ESP32).
  Beispiele `examples/esp32s3/clockspeed.abel` und `setclock.abel`.
- **aBelle: der Takt des Kerns beim ESP32-C3**: `cpu_clock(mhz)` aus `abelle/lib/esp32c3/cpuclock.abel`: 80 oder
  160 MHz vom PLL, 40, 20 oder 10 MHz vom Quarz (nicht bei laufendem WLAN), nicht tiefer (der USB-Anschluss des Chips,
  wie beim S3). Eine Spannung ist beim C3 nicht zu ändern. `millis()` und das Terminal laufen richtig weiter, bei 80 und
  160 MHz auch das WLAN; die Konsole behält den Takt, den ein Programm hinterlässt, `info` zeigt ihn. Gemessen:
  dieselbe Arbeit dauert bei 10, 40, 80 und 160 MHz 350, 87, 44 und 22 ms. Neue Konsole (Prepare Board) und WLAN-Dienst
  Version 7 (Install WiFi; er sagt, ob das WLAN läuft, und sein erster Start behält einen Takt vom PLL). Beispiele
  `examples/esp32c3/clockspeed.abel` und `setclock.abel`.
- **aBelle: der Takt des Kerns beim ESP32-S31**: `cpu_clock(mhz)` aus `abelle/lib/esp32s31/cpuclock.abel`: 320, 160, 80
  oder 53 MHz vom PLL, vom Quarz 40 MHz geteilt durch eine ganze Zahl bis 1 MHz (nicht bei laufendem WLAN), mit
  `cpu_clock_khz` bis 156 kHz. Der USB-Anschluss des S31 arbeitet bei jedem Takt weiter, die Konsole behält deshalb
  jeden Takt; für 320 MHz geht die Spannung des Kerns eine Stufe hoch. `info` zeigt den echten Takt, unter 1 MHz in
  kHz (der Board Manager auch). Gemessen: dieselbe Arbeit dauert bei 1, 10, 40, 160 und 320 MHz 3101, 310, 77, 19 und
  10 ms; mit verbundenem WLAN gehen Pings und DNS bei 320, 160, 80 und 53 MHz. Neue Konsole (Prepare Board). Beispiele
  `examples/esp32s31/clockspeed.abel` und `setclock.abel`.
- **Board Manager: ein Kontextmenü für die Dateien, Examples...**: Ein Rechtsklick auf eine Datei gibt Run bei einem
  Programm, Open in Editor bei einer Textdatei (eine Kopie; beides auch Enter oder ein Doppelklick), Autostart, Download
  und Delete (auch Entf), statt ihrer Knöpfe; Upload File und Refresh (F5) bleiben Knöpfe und stehen auch im Menü.
  Dateien aus dem Explorer, auf das Fenster gezogen, gehen auf das Board. **Examples...** öffnet ein Beispiel für das
  gewählte Board (`examples\common`, der Ordner des Boards, wenn es einen hat, oder die Übersicht der Beispiele) im
  Editor; bei aBelle wird Project > aBelle for das Board des Reiters Serial, so dass F9 es dort startet.
- **Reiter Serial wie ein Terminal**: Ctrl+C im Reiter schickt immer Ctrl+C an das Board (hält ein Programm an);
  kopieren geht mit Strg+Umschalt+C, Strg+Einfg oder dem neuen Kontextmenü (Copy, Paste to the Board, Select All,
  Stop); Strg+V schickt die Zwischenablage an das Board. Beim Verbinden erscheint der Prompt der Konsole (ein Enter,
  wenn das Board eine halbe Sekunde nichts gesagt hat). Ein Klick auf den Reiter, Connect, Reset und Clear setzen den
  Cursor dorthin, so dass Tippen gleich an das Board geht.
- **Ein Pico ohne WLAN hat keine Befehle für das Netz**: Auf einem Pico und einem Pico 2 ohne W sind `wlan`, `name`
  und `passwd` in der Konsole unbekannte Befehle, `help` und `info` nennen sie nicht (Prepare Board schreibt die
  `help.txt` ohne diese Zeilen; nach Install WiFi auf dem Klon „Pico W-2023“ wieder den ganzen Text).
- **Erase Flash beim Pico mit Fortschrittsbalken**: im USB-Boot und hinter der Debug Probe zählt der Balken die
  Blöcke zu 64 KB (STM32 und ESP32-C3 löschen alles auf einmal: der Balken läuft dabei um, wie beim ESP32).
- **Die ersten Beispiele in Assembler in `examples/`**: `windows_intel/demo.asm` (zählt von 1 bis 5, das Programm der
  ersten Schritte), `windows_arm/hello_arm32.asm` (Hello, World für Windows on ARM) und `dos/hello_exe.asm` (Hello,
  World als DOS-EXE mit dem Kopf von Hand). Die README der ZIP-Datei nennt sie statt der noch nicht freigegebenen
  Beispiele (und nicht mehr `examples\dos\HELLO.EXE` und `examples\winarm\pe_arm32_hello_world.asm`); `examples/README`
  in drei Teilen und ein Abschnitt „In Assembler“.
- **Deep Sleep auf dem ESP32**: Weckt der Timer der RTC den ESP32 aus dem Deep Sleep, startet die Konsole ihr
  Autostart-Programm sofort, ohne WLAN und ohne die Sekunde für eine Taste (beides kostet bei jedem Aufwachen Strom);
  weckt ihn etwas anderes (ein Pin wie die Taste BOOT), startet sie diesmal kein Programm: der Ausweg aus einem
  Programm, das immer wieder schläft. Nach einem Deep Sleep mit dem Quarz als Takt stellt sie außerdem die Takte pro
  Mikrosekunde des Boot-ROMs richtig (sie stimmten nicht, millis() lief dreimal zu schnell). Beispiele
  `examples/esp32/bme280_sleep.abel` (Light Sleep zwischen den Messungen, wach 9 ms von je 10 s) und
  `examples/esp32/bme280_deep.abel` (eine Minute Deep Sleep, was es sich merkt im langsamen Speicher der RTC; wach etwa
  150 ms pro Aufwachen, davon 127 für den Start von Boot-ROM und Konsole).
- **Beispiele für den ESP32**: `examples/esp32/bme280.abel` (Temperatur, Luftdruck und Feuchte eines BME280 an I2C,
  von Hand über die Pins) und `examples/esp32/tdisplay.abel` (das Farbdisplay des LilyGO TTGO T-Display: Farben,
  eine 5x7-Schrift, die Tasten; SPI von Hand), `examples/esp32/tdisplay_spi.abel` (dasselbe über VSPI mit 40 MHz:
  das ganze Bild in 14 ms statt 350 ms).
- **Wake-on-LAN für jedes Board mit WLAN**: `examples/common/wol.abel` schickt das Magic Packet, das einen PC startet
  (seine MAC oben im Programm oder als Argument); mit der Adresse des PCs wartet es danach, bis der PC auf einen Ping
  antwortet.
- **HTTP für jedes Board mit WLAN**: `examples/common/httpget.abel` fragt einen Server nach einer Seite (example.com
  oder die Adresse des Arguments) und zeigt die Statuszeile, die Kopfzeilen, den Titel, die Bytes und die Zeit.
- **SHA-256, HMAC und HKDF in aBelle** (`abelle/lib/common/sha256.abel`, der erste Schritt zu HTTPS): für jedes Board
  und für Windows, geprüft mit den Werten aus FIPS 180, RFC 4231, RFC 5869 und RFC 8448
  (`abelle/tests/lib/sha256_test.abel`).
- **ChaCha20-Poly1305 in aBelle** (`abelle/lib/common/chacha20.abel`, RFC 8439, die Verschlüsselung für HTTPS): für
  jedes Board und für Windows, geprüft mit den Fällen des RFC und zufälligen (`abelle/tests/lib/chacha20_test.abel`);
  auf dem ESP32 16 KB in 177 ms.
- **X25519 in aBelle** (`abelle/lib/common/x25519.abel`, RFC 7748, der Schlüsseltausch für HTTPS): für jedes Board und
  für Windows, geprüft mit den Fällen des RFC, Randfällen und zufälligen (`abelle/tests/lib/x25519_test.abel`); auf dem
  ESP32 ein Schlüssel in 0,8 s.
- **HTTPS für die Boards mit WLAN**: `examples/common/httpsget.abel` fragt einen Server über TLS 1.3 nach einer Seite,
  mit einem TLS-Client in aBelle (`abelle/lib/common/tls.abel`: TLS_CHACHA20_POLY1305_SHA256 mit X25519). Auf dem
  ESP32 dauert der Handshake etwa 2 s; ausprobiert mit example.com, Google, GitHub, Wikipedia und Amazon (1,1 MB in
  24 s). Das Zertifikat des Servers wird noch nicht geprüft. Seine Teile ohne Netz (`tls_core.abel`) sind mit dem
  Handshake aus RFC 8448 geprüft (`abelle/tests/lib/tls_core_test.abel`). Noch nicht auf dem ESP32-C3: zu groß für
  seinen RAM.
- **Ein Compiler von aBelle für RISC-V, der optimiert** (`abelle/compiler/abelle_riscv_opt.abel`,
  `bin\abelle_riscv_opt.exe`; der ESP32-C3 und der ESP32-S31): ein einfacher rechter Operand gleich ins zweite
  Register oder als Konstante im Befehl, ein Vergleich als ein einziger Sprung. Etwa 27 % weniger Code und bis zu ein
  Viertel weniger Befehle; damit passt `httpsget` in den RAM des ESP32-C3 (84 KB Code statt 118 KB). `abelle_riscv`
  bleibt, wie er ist; Asmonite nimmt den neuen noch nicht.
- **Die Bibliothek von aBelle im öffentlichen Repository**: `abelle/lib`, das die Beispiele mit `include` einbinden,
  liegt jetzt auch dort (in der ZIP-Datei war es schon immer).

### Behoben
- **ESP32-C3, ESP32-S31: wlan off ohne gespeichertes Netz**: Kannte das Board kein Netz oder hatte ein Programm das WLAN
  selbst gestartet, tat `wlan off` nichts, und das WLAN blieb an. Jetzt schaltet es das WLAN in jedem Fall ab.
- **Tab Serial: Meldungen „Integer overflow“ direkt nach dem Verbinden**: In der ersten halben Sekunde, nachdem sich der
  Tab Serial mit einem Board verbunden hatte, konnte ein Zeitgeber einen Integer-Überlauf melden, mehrmals
  hintereinander.
- **File > Open beginnt im Ordner der zuletzt geöffneten Datei**: auch wenn sie über Open Recent oder Examples... im
  Board Manager geöffnet wurde (vorher kannte Windows nur den Ordner, der zuletzt im Dialog selbst gewählt wurde); beim
  Start von Asmonite der Ordner der neuesten Datei von Open Recent. Eine Kopie einer Datei vom Board (Open in Editor)
  ändert ihn nicht.
- **ESP32: millis() ohne WLAN dreimal zu schnell**: Nach einem Reset kann das Boot-ROM seine Takte pro Mikrosekunde
  auf 13 lassen, während der Kern mit 40 MHz läuft (gesehen nach dem Befehl reset); die Konsole stellte 40 MHz nur
  nach einem Deep Sleep ein, jetzt bei jedem Start.
- **Reiter Serial: eine Markierung hält den Text nicht mehr auf**: War Text markiert, scrollten neue Zeilen vom Board
  nur so weit, dass die Markierung im Fenster blieb; jetzt scrollen sie ans Ende wie ohne Markierung, und die Markierung
  bleibt (zum Kopieren).
- **Fehler von Compiler und Assembler hinter dem Reiter Serial versteckt**: Der Reiter Output kommt für sie jetzt nach
  vorn.
- **Der Name von Asmonite.exe** (in der Taskleiste und im Task-Manager) lautete „x86, x64, ARM and ARM64“; jetzt
  „multi-target assembler, editor and debugger (x86, x64, ARM, ARM64, RISC-V, Xtensa)“.
- **Der Klon „Pico W-2023“ nach einer neuen Konsole**: Startete nur der RP2040 neu (ein Update der Konsole über USB;
  der ESP8285 behält seinen Strom und spricht mit 460800 Baud) und sendete der ESP gerade seine Frames, fand die
  Konsole ihn nicht: „The ESP8285 does not answer“, oder sie hielt das Board für einen Pico ohne WLAN und zeigte, was
  der ESP sendete, als Zeichensalat, bis das Board neu eingesteckt wurde. Bytes mit einem Fehler zwischen ihren Pings
  lassen die Konsole ihn jetzt bei 460800 suchen (20 von 20 Updates der Konsole fanden ihn; vorher 2 von 4).

## 0.15.0 – 2026-11-20

### Kurz gesagt
- **Eine Konsole auf jedem Board**: ESP32, ESP32-S3, ESP32-C3, ESP32-S31 und Raspberry Pi Pico und Pico 2 (W) haben
  eine Konsole von Asmonite mit denselben Befehlen (`ls`, `cat`, `rm`, `df`, `format`, `run`, `boot`, `noboot`,
  `info`, `reset`, `help`, `wlan`, `name`); `load`, `put` und `mem` sind weg. `wlan scan` jetzt auf jedem Board mit
  WLAN, auch auf ESP32 und ESP32-S3.
- **Neue Boards**: ESP32-C3 und ESP32-S31 (RISC-V) mit Konsole, WLAN, aBelle und Debugger; Pico und Pico 2 mit einer
  Konsole über ihr USB-Kabel, ohne Debug Probe.
- **WLAN auf jedem Board mit WLAN**, jetzt auch Pico W, Pico 2 W, der Klon „Pico W-2023“ (ESP8285), C3 und S31: Das
  Board behält sein Netz, antwortet auf Ping, holt seine Adresse per DHCP und antwortet für `name.local` (mDNS), auch
  während ein Programm läuft.
- **Der Board Manager**: das WLAN des Boards über ein Kontextmenü (die Netze, die der PC sieht, das Passwort aus
  Windows; WLAN an und aus, der mDNS-Name), die Versionen von Konsole und WLAN-Dienst, Ein- und Ausstecken wird
  verfolgt.
- **Ein aBelle-Programm für jedes Board** (keine Zeile `target`: Project > aBelle for) und die Beispiele in
  `examples/common`: hello, blink, runs, scan, arpscan, ping, pingled.
- **Compile and Upload, Upload and Run**: ein Programm in den Flash des Boards, von dort gestartet; übersetzt wird
  der Text des Editors, auch wenn er nicht gespeichert ist.
- **Klareres Englisch** in Asmonite und Dismonite: der Fortschritt, die Meldungen und die Dialoge.

### Neu
- **Compile and Upload, Upload and Run**: Project > Compile and Upload (Ctrl+Shift+F9; bei Assembler Assemble and
  Upload) legt das Programm im Editor über die Konsole als Datei in den Flash des Boards im Reiter Serial (ESP32,
  ESP32-S3, ESP32-C3, Pico und Pico 2 am USB-Kabel), unter dem Namen seiner Quelle ohne Endung; Debug > Upload and Run
  (Shift+F9) lässt die Konsole es danach von dort starten. Das Programm bleibt nach einem Reset auf dem Board
  (`run name`, Autostart im Board Manager). Ein laufendes Programm beendet Asmonite vorher mit Ctrl+C, eine Konsole
  einer anderen Version bringt es zuerst auf den Stand (wie bei F9). Bei einem Programm für ein Board heißt F9 jetzt
  Run in RAM / Continue. Die Knöpfe Upload This Program und This Program Autostarts des Board Managers sind weg (dass
  sie das Programm im Editor meinten, war nicht klar).
- **Der ESP32-S31** (RISC-V, Chip-ID 32 des Boot-ROMs): Read Chip nennt den Chip, sein Gehäuse und seine Revision,
  die MAC, den PSRAM im Chip, den Quarz und den Flash. **Eine Konsole für ihn** (`boards/esp32s31`, die des ESP32-C3
  mit den Adressen des S31; im Flash bei 0x2000, wo sein Boot-ROM sucht): Dateien, Programme, Autostart, die Pakete
  des Board Managers, Ctrl+C für ein laufendes Programm (Stop im Reiter Serial: der Interrupt des USB-Anschlusses über
  die Interrupt-Matrix, Quelle 2, auf Interrupt 36 des CLIC des S31; nebenbei korrigiert: ein Wettlauf in get_char
  eines Programms, der bei zwei Tasten auf einmal eine verlor); der Kern mit 160 MHz (das ROM lässt ihn bei 40 MHz
  vom Quarz: Die Konsole schaltet auf die CPLL um, 320 MHz / 2, wie der Bootloader von ESP-IDF; `info` zeigt es,
  `rgb` misst seine Pulse damit); WLAN: siehe unten. In Asmonite: `.target esp32s31` (das RAM 0x2F000000 .. 0x2F07AFBF), der Board Manager (Prepare
  Board, die Dateien, Run, Autostart, Erase Flash), F9 ohne Breakpoint über die Konsole, Compile and Upload, Upload
  and Run. Am Chip gefunden: Der Super-Watchdog nimmt den Schlüssel der anderen Watchdogs, und
  USB-Serial/JTAG schickt einen FIFO nicht ab, der voll wurde, bevor der PC den Port geöffnet hatte. Wo Asmonite nach
  dem Namen sucht, gilt „ESP32-S31“ nicht mehr als ESP32-S3. Test: src/tests/s31contest (21 Prüfungen, auch mit
  ganz gelöschtem Flash); `boards/esp32s31/s31rom.py` ist der Prüfstand über das Boot-ROM. Getestet an einem
  ESP32-S31-Board: Revision v0.0, 16 MB PSRAM, 16 MB Flash. **aBelle für den S31**: `target "esp32s31"` (oder
  Project > aBelle for > das Board des Reiters Serial), übersetzt von `abelle_riscv.exe` für das RAM der Programme
  seiner Konsole (der Code ab 0x2F000000, 304 KB und 16 KB Stack); `abelle\lib\esp32s31\console.abel`: die Funktionen
  der Konsole (ab 0x2F060200) und `gpio_output`, `gpio_write` (GPIO 0 .. 61, die USB-Pins 33 und 34 bleiben unberührt).
  F9 führt es über die Konsole aus, Compile and Upload und Upload and Run legen es in die Dateien. Getestet am Board:
  `hello.abel`, die Pins, `millis`, `file_size`, `exit`. **Die RGB-LED** des S31-Boards (eine WS2812 an GPIO 60):
  `rgb(pin, farbe)` (0xRRGGBB, 0 aus), eine Funktion seiner Konsole (Version 4, bei 0x2F06023C; die Pulse gemessen mit
  mcycle, der Kern mit 40 MHz) und von `console.abel`; Prepare Board bringt die neue Konsole aufs Board. **Der
  Debugger für den S31**: F9 mit Breakpoint, F7 und F8 debuggen ein Programm in aBelle oder Assembler
  (`.target esp32s31`) über den USB-JTAG des Chips, Kern 0: Seine Konsole startet das Programm (`dbg_run`, wie beim C3;
  ein Assembler-Programm endet mit `ret` oder `exit`), Breakpoints (4), Schritte, Pause, die Register und die
  Variablen; das Ende des Programms beendet die Sitzung. Am Chip gefunden: Seine JTAG-Kette hat zwei TAPs (der LP-Kern
  an TDO, IDCODE 0x00003C25, in BYPASS; die HP-Kerne 0x00020C25), sein USB-JTAG bringt eine eigene Interface-GUID mit
  (keine Einrichtung in Debug targets), der Reset mit angehaltenem Kern ist ndmreset. Korrektur auch für den C3: Nach
  Stop läuft das Programm weiter, und an seinem Ende blieb der Kern am ebreak hinter `dbg_run` für immer im
  Debug-Modus stehen (die Konsole war bis zu einem Reset weg): Der Debugger setzt beim Abkoppeln ein nop dorthin, und
  ebreak ist wieder eine Exception. Test: src/tests/s31dbgtest (27 Prüfungen; mit dem Argument c3 dasselbe über die
  Konsole des ESP32-C3).
- **WLAN auf dem ESP32-S31**: Die WLAN-Bibliotheken von Espressif für den S31 (WiFi 6) gelinkt von
  `ablink --chip esp32s31` (dieselben Bytes wie GNU ld), die OS-Schicht und der Dienst des ESP32-C3 übernommen (eine
  Quelle für beide, `wlan/wlanradio_s31.asm` für die Takte des Modems, den CLIC und den analogen I2C des S31), als
  WLAN-Paket im Flash (Install WiFi im Board Manager). In seiner Konsole wie beim C3: `wlan set`, `wlan on`,
  `wlan off`, `wlan clear`, `wlan scan`; das Board verbindet sich im Hintergrund, holt seine Adresse per DHCP,
  antwortet auf ARP und Ping und startet das WLAN nach einem Reset von selbst. Am Chip gefunden: Ohne den Bootloader
  von ESP-IDF lassen die Zugriffsfilter des S31 (APM) nur die CPU in den Speicher, das WLAN konnte also senden, aber
  nie einen Frame empfangen (der WLAN-Dienst schaltet sie jetzt ab, wie dieser Bootloader); und der Takt des
  WLAN-Basisbands darf nicht dauernd erzwungen sein (dann nimmt das Funkteil keinen Frame von 11n/11ax an, auch unter
  ESP-IDF): Die PMU muss die Takte im aktiven Zustand gaten (ICG_SYS_CLOCK_EN), erzwungen sind sie nur noch für die
  Kalibrierung. Tests: `wlan/wlantest2_s31` .. `wlantest5_s31` (Kalibrierung, Scan, Frames, eine Verbindung mit DHCP
  und 4 Pings an den Router), src/tests/s31contest (28 Prüfungen mit dem Netz des Boards). Noch nicht auf dem S31:
  telnet.
- **aBelle-Programme im Netz auf dem ESP32-S31**: `abelle/lib/esp32s31/wifi.abel`, die des ESP32-C3 an den Stellen
  des S31 (sein WLAN-Dienst bei 0x2F03A000, sein TRNG), damit laufen `net.abel` und `tcp.abel` dort wie auf den
  anderen Boards (die Tests übersetzen sie jetzt auch für den S31). Auf dem C3 und dem S31 startet ein Programm das
  WLAN jetzt selbst, wie auf den anderen Boards: Der erste `wifi_`-Aufruf bittet die Konsole darum (`wifi_up`, eine
  neue Funktion der Konsole bei +64, `console_version()` 5), wenn seit dem Reset kein `wlan on` den WLAN-Dienst
  geladen hat.
- **Die Beispiele `examples/common/scan.abel`, `arpscan.abel` und `ping.abel`**: die WLAN-Netze in der Nähe des
  Boards, wer im Netz ist (ARP), und der Ping des Routers, eines Servers oder eines angegebenen Hosts; je eine Quelle
  für jedes Board mit WLAN.
- **`wifi_scan` auf dem Pico W und dem Pico 2 W**: Operation 11 von `wl_call` ihrer Konsole (`console_version()` 4)
  sucht wie `wlan scan` und gibt die Netze wie beim ESP32 zurück (je 48 Bytes: BSSID, Kanal, RSSI, Schutz, Name),
  damit läuft ein Programm, das sucht, auf jedem Board mit WLAN. Den Schutz liest sie aus den IEs jedes Netzes (offen,
  WEP, WPA, WPA2, WPA/WPA2, WPA2 Enterprise, WPA3, WPA2/WPA3); der Klon „Pico W-2023“ gibt den seines ESP8285.
  Prepare Board bringt die Konsole eines Picos auf den Stand.
- **`wifi_pings()` auf jedem Board mit WLAN**: wie viele Pings an das Board beantwortet wurden; das Programm sieht sie
  nicht, der WLAN-Dienst (ESP32 und ESP32-S3: Version 11, ein Wort bei +104; ESP32-C3 und ESP32-S31: Version 5, ein
  Einsprung bei +0x50) oder die Konsole des Pico W und des Pico 2 W (Operation 12 von `wl_call`, `console_version()` 5)
  beantwortet und zählt sie. Install WiFi oder Prepare Board im Board Manager bringt ein Board auf den Stand.
- **Der Board Manager zeigt die Versionen**: „Console: v2 (current: v2)“ (die Zahl, die `console_version()` liefert,
  aus dem neuen Paket V jeder Konsole, und die der Konsole dieses Asmonite), beim ESP32, S3, C3 und S31 „WiFi service:
  v10 (current: v11; "Install WiFi..." to update)“ (aus dem WiFi-Paket im Flash gelesen). Weniger Zeilen:
  WLAN-Zustand, Netz, Adresse und Name in einer („connected to <Netz>, <Adresse> (<Name>)“), der serielle Port nur,
  wenn der Gerätename nicht schon darauf endet, der Hersteller des Treibers hinter der USB-Kennung, keine USB-Seriennummer (beim ESP32-S3/C3 ist sie die MAC), beim Pico Board und
  telnet in Kürze. Ein Rechtsklick kopiert eine Zeile (Copy Line) oder alle (Copy All).
- **Das WLAN des Boards aus dem Board Manager**: Ein Rechtsklick auf die Zeile WiFi (oder ein Doppelklick) bietet Set
  Network..., WiFi On / WiFi Off, Forget Network... und Set mDNS Name... an (name.local, auch der Router zeigt ihn;
  nicht beim C3 und S31); auf der Zeile telnet Set Password... und Clear Password.... Set Network... listet die Netze, die dieser PC sieht (Signal, 2,4 oder 5 GHz: die
  Boards können nur 2,4 GHz), und beim ESP32-C3, ESP32-S31, Pico W und Pico 2 W die, die das Board sieht (Scan with
  Board); From Windows trägt das Passwort ein, das Windows für das gewählte Netz gespeichert hat. Der Board Manager
  tippt die Befehle der Konsole (`wlan set`, `wlan on`, `wlan off`, `wlan clear`, `name set`, `passwd set`, `passwd clear`) und
  beantwortet ihre Rückfragen; kein Passwort wird irgendwo gespeichert.
- **mDNS auf Pico W, Pico 2 W und dem Klon „Pico W-2023“**: Die Konsole beantwortet Anfragen nach `name.local`
  (der Name von `name set`, sonst der aus der MAC: `picow-1a2b.local`), im Hintergrund wie ARP und Ping: am Prompt und
  während ein Programm läuft (ESP32 und S3 am Prompt). Wie beim ESP32: an alle (224.0.0.251), wenn die Frage von Port
  5353 kam, sonst an den Fragenden. Eine Frage, die die Konsole beantwortet hat, geht nicht an das Programm (es würde
  sie noch einmal beantworten). Etwa 500 Bytes je Konsole.
- **Der Befehl `load` ist weg** aus den Konsolen von ESP32, ESP32-S3, ESP32-C3 und ESP32-S31 (die Picos hatten ihn
  nie): Das WLAN braucht ihn nicht (die Konsole holt seine Teile aus dem WiFi-Paket im Flash), `run name` startet ein
  Programm wie bisher. Die Tests der WLAN-Stufen legen die Teile von wlan.rom über das Paket R ins RAM, das jetzt auch
  den Raum zwischen den Programmen und der Konsole beschreiben darf (ESP32, S3). „Prepare Board...“ bringt ein Board
  auf die neue Konsole.
- **Die Konsolen angeglichen**: `reset` jetzt auch auf ESP32 und ESP32-S3 (das Board startet neu wie mit seinem
  Reset-Taster; beim S3 verschwindet sein USB-Port dabei kurz). `put` (eine Datei eintippen) ist weg aus den Konsolen
  von ESP32, S3, C3 und S31 (die Picos hatten es nie): Dateien kommen über den Board Manager (Upload File...) oder
  Compile and Upload aufs Board. `mem` (ein Blick in den Speicher) ist weg aus den Konsolen von Pico, Pico 2, C3 und
  S31: Den Speicher zeigt der Debugger. Damit haben alle Konsolen dieselben Befehle für Dateien und Programme. Die
  Hilfe von Pico und Pico 2 ist jetzt die Datei `help.txt`, wie bei den ESP-Boards (Prepare Board und Format
  schreiben sie, aus `boards/pico/help.txt` und `boards/pico2/help.txt`; ohne sie zeigt `help` eine kurze Liste):
  etwa 700 Byte mehr Platz in ihren Konsolen. `file_write` für Programme jetzt auch auf Pico und Pico 2 (es
  antwortete dort mit -1): eine Datei, geschrieben wie bei Upload File, mit denselben Antworten wie bei den
  ESP-Boards (0, oder -1 Verzeichnis voll .. -5 kein Dateisystem). **`name` und mDNS auch auf ESP32-C3 und
  ESP32-S31**: `name`, `name set keller`, `name clear` wie auf den anderen Boards (im Datensatz des Netzes; `wlan set`
  und `wlan clear` behalten ihn); ihr WLAN-Dienst (Version 6) gibt ihn dem Router (DHCP) und beantwortet mDNS für
  `keller.local`, auch während ein Programm läuft. Der Board Manager bietet für sie Set mDNS Name... an und zeigt
  `.local`. **Ctrl+C** (Stop im Reiter Serial) hält ein Programm auf C3 und S31 jetzt auch an, wenn es fast die ganze
  Zeit im WLAN-Dienst wartet (pingled hielt nicht an).
- **Übersetzen: der Text des Editors** (Project > Save before compile aus): Die Compiler für aBelle, C und Pascal
  lesen jetzt auch den Text im Editor, mit ungespeicherten Änderungen (wie der Assembler schon immer), aus einer
  versteckten Kopie `~name` neben der Quelle (dort finden sich ihre Includes), die danach wieder gelöscht wird; die
  Meldungen und die Map-Datei nennen die Quelle. Vorher lasen sie die Datei auf der Platte.
- **Debug > Stop (Strg+F2) ohne Debug-Sitzung**: Ist der Reiter Serial mit einem Board verbunden, schickt es Ctrl+C
  wie der Knopf Stop des Reiters: Ein Programm von F9 oder vom Autostart hält an.
- **Eine Konsole für den ESP32-C3** (`boards/esp32c3/console.asm`, RISC-V), wie auf dem ESP32 und dem ESP32-S3:
  über den USB-Port des Chips (ein Terminal, etwa der Reiter Serial), im Flash ab 0. Die Dateien im Flash ab 2 MB
  (`ls`, `cat`, `rm`, `df`, `format`), Programme aus den Dateien (`run`, `boot`, `noboot`, der Name
  allein mit Argumenten; ein Programm endet mit seinem Code, mit exit(), mit einer Exception oder mit Ctrl+C), `info`,
  `reset`, `help` (help.txt). Der Board Manager kennt sie: Prepare Board schreibt die Konsole, help.txt, ein
  Dateisystem und das WLAN-Paket; die Dateien, Compile and Upload (`.target esp32c3`, `.arch riscv32`, `.imagebase
  0x40380000`), Run, Autostart, Format, Reset, Erase Flash. Der C3 meldet sich mit dem neuen Paket H (sein
  USB-Port sieht aus wie der des S3).
- **WLAN auf dem ESP32-C3**: die WLAN-Bibliotheken von Espressif für den C3, gebunden von `ablink --chip esp32c3`
  (dieselben Bytes wie mit GNU ld), die OS-Schicht, WPA2-PSK und ein WLAN-Dienst mit Einsprüngen an festen Adressen,
  alles in RISC-V-Assembler (`wlan/*_c3.asm`), als WLAN-Paket im Flash wie auf dem ESP32 (Install WiFi im Board
  Manager). In der Konsole: `wlan set` (Name und Passwort des Netzes; das Board behält den Schlüssel, nicht das
  Passwort), `wlan on`, `wlan off` (bleiben über einen Reset), `wlan clear`, `wlan scan`; das Board verbindet im
  Hintergrund, holt die Adresse per DHCP, beantwortet ARP und Ping und startet das WLAN nach einem Reset von selbst.
  Der C3 hat einen Kern: Ein Timer (alle 10 ms) gibt den Tasks des WLANs eine Runde, auch während ein Programm
  rechnet; ein Task des Dienstes (`wlan/wlannet_c3.asm`) hält die Verbindung, beantwortet ARP und Ping und erneuert
  die Adresse, was auch läuft (auf dem ESP32 und dem S3 liegt DHCP in der Konsole, nur weil ihr Dienst keinen Platz
  dafür hat). Ein Programm ruft den Dienst selbst auf; `wifi_get_ip` liefert Adresse, Maske, Router und Nameserver.
  Getestet auf dem C3 des LilyGO T-PicoC3, angepingt von einem ESP32 im selben Netz, auch während ein Programm 60 s
  rechnet. Noch nicht auf dem C3: telnet, die Brücke für den RP2040 des T-PicoC3.
- **aBelle auf dem ESP32-C3**: der Compiler `abelle_riscv.exe` (RISC-V, RV32IM; `target "esp32c3"`), das Programm im
  RAM der Programme der Konsole ab `0x40380000`, `inc/console.abel` mit den Funktionen der Konsole des C3, das Beispiel
  `hello.abel`. In Asmonite F9, F7, F8 und die Variablen über den USB-JTAG: Die Konsole startet das Programm (ihr neuer
  Einsprung `dbg_run`, Konsole Version 3) und ist danach wieder am Prompt. Ohne Board gegen die x86-Programme geprüft
  (`abelle/tests/riscv_tests.py`, ein Emulator für RV32IM: 1000 zufällige Programme, dieselben Zahlen). Das Netz:
  `inc/wifi.abel` über den WLAN-Dienst des C3 (er hält die Verbindung und die Adresse), `inc/net.abel` und
  `inc/tcp.abel` wie beim ESP32, die Beispiele `dhcp`, `ping`, `dns`, `ntp`, `arpscan`, `httpget`.
- **`info` in den Konsolen des ESP32 und des ESP32-S3**, wie auf dem ESP32-C3: der Chip und der Takt seines Kerns,
  der Flash (seine Größe, seine JEDEC-ID), die MAC der Station, die Version der Konsole. Ihr `.data` wuchs von 4 KB
  auf 5 KB (Puffer nach oben verschoben), damit jede Konsole mindestens 1 KB Code und 256 Bytes Daten frei behält.
- **RISC-V: die komprimierten Befehle mit 2 Bytes (C)** mit `.option rvc` (wie GNU as; `.option norvc` schaltet es
  aus): Der Assembler schreibt überall die kurze Form, wo eine passt, etwa ein Fünftel weniger Code (die Konsole des
  ESP32-C3: 29,7 KB -> 22,3 KB). `addi`, `li`, `mv`, `add`, `lw`/`sw` (auch auf `sp`), `ret`, `jr`, die Schiebe- und
  Bitbefehle; Sprünge und Verzweigungen zu einem Label, wenn es nah ist (`j`, `beqz`, `bnez`; `call` und `tail` als
  `c.jal`/`c.j` bis 2 KB, als `jal` bis 1 MB, sonst wie bisher auipc + jalr). Die `c.`-Befehle (C und Zcb, RV32 und
  RV64) lassen sich auch von Hand schreiben. Ohne die Zeile bleibt jedes Programm Byte für Byte, wie es war.
  Geprüft: Jeder 16-Bit-Befehl, den der Disassembler liest, assembliert wieder zu denselben 2 Bytes; zufällige Befehle
  ergeben dieselben Bytes wie GNU as (`tools/rvc_gnu_check.py`); der Debugger des ESP32-C3 springt über einen Aufruf
  mit 2 Bytes. Zu beachten: Datenwörter, die `lw` liest, brauchen `align 4` davor, eine Tabelle von Sprüngen mit je
  4 Bytes `.option norvc` drumherum.
- **`pins.abel`** (ESP32): findet ohne Messgerät heraus, an welchem GPIO eine LED hängt. `pins` in der Konsole liest
  jeden Pin mit Pull-up und mit Pull-down (eine LED nach GND oder nach 3,3 V hält den Pin fest, ein freier Pin folgt
  dem Pull) und lässt danach die Kandidaten mit der schwächsten Treiberstufe blinken; `pins 2` lässt GPIO 2 blinken,
  bis eine Taste kommt.
- **Der Board Manager folgt dem Ein- und Ausstecken**, solange er offen ist: Ein eingestecktes Board erscheint in der
  Liste (das gewählte bleibt gewählt); wird das gewählte Board abgesteckt, ist keins mehr gewählt und eine Zeile sagt
  es, und das nächste eingesteckte Board wird gewählt (dasselbe wieder oder ein anderes, auch beim Tausch in einem
  Zug). Zwei DevKits mit derselben Seriennummer zählen nach ihrem Port. Ein Reset durch das Fenster selbst (der USB-Port eines ESP32-S3 ist
  dabei kurz weg) zählt nicht.
- **`fm.abel`** (ESP32, ESP32-S3): die Dateien des Boards im Browser, eine erste Version, die nur liest. `run fm` in der
  Konsole, dann `http://name.local/fm`: die Daten des Boards (Chip, Name, Adressen, Flash, freier Platz, Autostart) und
  seine Dateien, jede zum Ansehen (als Text oder hex) oder zum Herunterladen. `/` zeigt `index.html` des Boards, und
  Dateien mit einer Endung fürs Web (`.html`, `.css`, `.js`, `.png` …) stehen unter ihrem Namen bereit: eigene Seiten
  vom Board. Mit einem Passwort (`passwd set`, dasselbe wie für telnetd) fragt der Browser bei `/fm` danach (der
  Benutzername ist egal); die eigenen Seiten bleiben offen. Eine Datei `fm.html` auf dem Board ersetzt die eingebaute
  Seite (`/fm?builtin` zeigt immer die eingebaute); die Seite holt ihre Daten als JSON von `/api/info` und `/api/files`.
- **Eine Konsole für den Raspberry Pi Pico 2** (`boards/pico2/console.asm`, seine Arm-Kerne), auf dem Weg zu
  einer Konsole wie beim ESP32: im Flash, sie kopiert sich ins RAM (0x20070000) und läuft dort; UART0 an GPIO 0 und 1
  mit 115200 Baud, über den UART des Raspberry Pi Debug Probe (sein Anschluss „U“) im Reiter Serial. Der Prompt `> `,
  `help`, `info` (der Chip, seine Revision, die Kerne, das Boot-ROM), `mem adresse [n]`, `reset`; ein Lesen, wo
  nichts ist, zeigt die Exception, und der Prompt kommt wieder. Die Dateien im Flash von 1 MB bis 4 MB wie beim ESP32
  (`ls`, `df`, `cat`, `rm`, `format`), geschrieben mit den Funktionen des Boot-ROM, und die Pakete von Asmonite dafür
  (hoch, herunter, auflisten, löschen, das Programm für den Start). Programme aus den Dateien: `run name [args]` oder
  der Name allein, `boot name` (nach einem Reset hält eine Taste in der ersten Sekunde die Konsole), `noboot`; ein
  Programm endet mit seinem Code, mit exit, durch einen Fault oder durch Ctrl+C (Stop im Reiter Serial), danach kommt
  der Prompt wieder. Die Funktionen der Konsole für Programme (put_char, get_char, print, millis, file_size,
  file_read, args …) sind eine Tabelle bei 0x20078140; `examples/pico2/hello_console.asm` benutzt sie. Im Board
  Manager zeigt der Pico 2 hinter dem Debug Probe seine Dateien mit den Knöpfen des ESP32 (eine Datei oder das
  Programm im Editor hochladen, herunterladen, löschen, starten, Autostart, formatieren); Prepare Board schreibt die
  Konsole über den Probe in seinen Flash. F9 debuggt wie bisher über den Probe.
- **Dieselbe Konsole für den Raspberry Pi Pico** (RP2040, `boards/pico/console.asm`): die Befehle, die Dateien und
  die Pakete wie beim Pico 2, in Thumb-1 für seinen Cortex-M0+. Die Konsole läuft im RAM bei 0x20030000, die Programme
  bei 0x20000000 bis 0x2002FFFF (`.target pico`), die Tabelle der Funktionen liegt bei 0x20038140
  (`examples/pico/hello_console.asm`); die Dateien im Flash von 1 MB bis 2 MB; `reset` über den Watchdog. Der Board
  Manager zeigt den Pico hinter dem Debug Probe mit seinen Dateien und Prepare Board wie beim Pico 2.
- **Ein eigenes USB-Gerät auf dem Pico und dem Pico 2** (`examples/pico/usb_echo_ram.asm`,
  `examples/pico2/usb_echo_ram.asm`, der Code in `examples/pico/usb_cdc.asm`), ohne SDK: über das USB-Kabel des Boards
  ein COM-Port am PC (USB CDC-ACM, der Treiber von Windows), eine Begrüßung, wenn ein Terminal ihn öffnet, ein Echo
  dessen, was kommt (Enter als neue Zeile). F9 lädt es über die Debug Probe ins RAM. Getestet auf dem Pico und dem
  Pico 2.
- **Die Konsolen von Pico und Pico 2 auch über das USB-Kabel des Boards** (`boards/pico/console_usb.asm`, gesteuert
  über den Interrupt der USB-Steuerung): ein eigener COM-Port am PC (1209:0001), der Prompt, die Pakete von Asmonite
  (Dateien rund zehnmal so schnell wie über den UART), Programme, Ctrl+C, Reset; der UART der Probe geht weiter wie
  bisher. Die Konsolen laufen jetzt mit 48 MHz aus PLL_USB.
- **Pico und Pico 2 ohne Probe:** Der Board Manager kennt die Konsole am USB („Pico (USB console)“, „Pico 2 (USB
  console)“: die Seriennummer des Geräts ist der Chip) mit ihren Dateien, Run, Reset Board; F9 startet ein Programm im
  RAM über sie (ohne Breakpoint, der Reiter Serial an ihrem Port). Prepare Board für einen Pico im USB-Boot (BOOTSEL):
  die Konsole als UF2-Datei auf sein Laufwerk. Prepare Board an der USB-Konsole: ein Update ohne Taste (1200 Baud: die
  Konsole startet den Chip in seinen USB-Boot, dann die UF2-Datei; die Dateien bleiben). Getestet auf beiden. Die
  Seriennummer der Konsole am USB ist der Chip und die Kennung des Boards (das OTP des RP2350, beim Pico die Kennung
  des Flash-Chips): Jedes Board bekommt einen eigenen COM-Port.
- **Pico W und Pico 2 W erkannt:** Die Konsolen fragen beim Start den WiFi-Chip des Boards (CYW43439,
  `boards/pico/console_wifi.asm`); der Gruß, `info` (die Zeile *board*), das neue Paket H und der Board Manager (der
  Titel „Pico W“, „Pico 2 W“, das Foto, die Zeile *Board* mit einem Wort zur LED) nennen das Board. Getestet auf einem
  Pico, einem Pico W, einem Pico 2 und einem Pico 2 W.
- **aBelle auf Pico und Pico 2:** Ein vierter Compiler, `abelle_pico.exe`, übersetzt Programme mit `target "pico"` oder
  `target "pico2"` in Thumb-1 für die Konsole des Boards (in ihr RAM ab `0x20000000`). F9 führt sie über die Konsole
  aus; mit Breakpoint debuggen F9, F7 und F8 sie, über das USB-Kabel oder die Debug Probe, mit den Variablen.
  `include "inc/console.abel"` liefert die Funktionen der Konsole (Text, `millis()`, die Dateien, `args()`,
  `led(an)`); Beispiele `hello.abel` und `blink.abel` in `examples/abelle/pico` und `pico2`. Die Konsolen legen ihre
  Funktionen zusätzlich als aufrufbaren Code an eine feste Stelle (ab `0x20039E00` / `0x20079E00`) und haben `led(an)`:
  die LED des Boards (GPIO 25; beim Pico W und Pico 2 W am WiFi-Chip, siehe unten).
- **Der WiFi-Chip von Pico W und Pico 2 W startet** (der erste Schritt zum WiFi dort): `wlan on` in der Konsole
  schickt die Firmware des CYW43439 (Infineon, 7.95.61) aus den Dateien `43439A0.bin` und `nvram_rp2040.bin` über das
  SPI des Chips in seinen RAM (etwa 226 KB in 0,6 s), und sein Arm-Kern läuft; danach spricht die Konsole in Paketen
  mit der Firmware (SDPCM, ioctl und iovar) und gibt ihr die CLM-Daten (`43439A0_clm.bin`); dazu `wlan off` und
  `wlan`. `led()` der Programme schaltet die LED eines W am Chip (der erste Aufruf startet ihn): `blink.abel` lässt
  sie unverändert blinken. Prepare Board legt die drei Dateien auf einen W, nur die, die dort nicht genau so liegen;
  das ZIP hat sie in `wlan\infineon`, unverändert, mit der Lizenz von Infineon. `wlan scan` zeigt die Netzwerke in
  der Nähe (das Signal, den Kanal, offen oder geschützt, den Namen). `wlan set` fragt nach einem Netz und seinem
  Passwort und verbindet sich (WPA2 mit AES, oder offen); wie beim ESP32 behält die Konsole den Namen und den
  Schlüssel von WPA2 (PBKDF2), nicht das Passwort, in den letzten zwei Sektoren des Flash (die Dateien enden jetzt
  8 KB früher); `wlan on` verbindet sich wieder, `wlan clear` vergisst das Netz. Getestet auf einem Pico 2 W (ein
  WPA2-Netz, ein falsches Passwort, ein Reset, clear) und einem Pico W (die Firmware, der Scan, `wlan set`, `wlan on`
  nach Kaltstarts, `blink.abel` lässt seine LED blinken).
- **aBelle-Programme im Netz auf dem Pico W und dem Pico 2 W:** Die Konsolen geben Programmen die Frames des Netzes
  (`wl_call`, eine neue Funktion der Konsole; `console_version()` 3); `inc/wifi.abel` in `abelle/examples/pico` und
  `pico2` baut darauf die Funktionen des ESP32 (`wifi_connect_saved`, `wifi_send`, `wifi_recv`, `wifi_mac` …), so
  laufen `inc/net.abel` (ARP, IPv4, Ping, UDP, DHCP, DNS, mDNS) und `inc/tcp.abel` wie beim ESP32. Beispiele `dhcp`,
  `ping`, `dns`, `ntp`, `arpscan` und `httpget` für beide Boards. Fragt ein Programm danach, startet die Konsole den
  Chip und verbindet sich mit dem Netz, das das Board behält (`wlan set`); Chip und Netz bleiben nach dem Programm.
  Getestet auf einem Pico W (alle sechs; Ctrl+C mitten in einem; kein Netz gespeichert) und einem Pico 2 W (alle
  sechs, Kaltstarts).
- **Die Konsole eines Pico W und eines Pico 2 W im Netz:** Nach einer Verbindung holt sie sich eine Adresse per DHCP
  und erneuert sie nach der Hälfte der Lease (`wlan on` und `wlan` zeigen sie mit Maske, Router und DNS-Server);
  einmal nach ihrem Start, nach 3 ruhigen Sekunden am Prompt, verbindet sie sich von selbst mit dem gespeicherten
  Netz („WiFi: connected, address …“). SysTick schaut alle 10 ms beim WiFi-Chip nach: Er beantwortet ARP und Ping für
  das Board am Prompt, während ein Programm läuft (auch eines ohne Netz) und während es an einem Breakpoint steht;
  `wlan` zählt die Antworten. `name`, `name set`, `name clear` (der Name für den Router) und `passwd`, `passwd set`,
  `passwd clear` (das Passwort für telnet, als Schlüssel gespeichert) wie beim ESP32. `telnetd.abel` für beide Boards
  (die Shell über telnet des ESP32). Eine Verbindung, die scheitert, nennt die Antworten des Access Points
  („(events; … PSK_SUP status 8 reason 15)“: ein falsches Passwort). Der Board Manager zeigt bei einem W das WLAN,
  die Adresse, die MAC, den Namen, das gespeicherte Netz und ob telnet nach einem Passwort fragt (das Paket N wie beim
  ESP32, mit zwei Feldern mehr). Getestet auf einem Pico 2 W, auch vom PC aus: Ping
  (auch über den mDNS-Namen, während telnetd läuft) und telnet mit seinen Befehlen; auf einem Pico W der Start,
  `name`, `passwd`, das Paket N, die Beispiele und telnetd. `ping.abel` (ESP32, ESP32-S3,
  Pico W, Pico 2 W) pingt das Ziel seines Arguments: `ping 192.168.178.20` oder `ping example.com` in der Konsole.
- **Pico und Pico 2 ohne Probe debuggen:** Die Konsolen haben einen Debug-Monitor (`boards/pico2/console_mon.asm`,
  `boards/pico/console_mon.asm`). Ist der Reiter Serial an der USB-Konsole des Boards (oder steckt keine Probe und das Board mit seiner Konsole) und
  das Programm fürs RAM,
  debuggen F9 mit Breakpoint, F8 und F7 über das USB-Kabel: Breakpoints, Schritte, Pause, die Register und der
  Speicher; USB und die Konsole laufen weiter, während das Programm steht. Der Pico 2 nimmt Breakpoints und Schritte
  in seinem Cortex-M33 (die Exception DebugMonitor); der Pico, dessen Cortex-M0+ keine hat, hält an BKPT-Befehlen, die
  Asmonite schreibt. Write to Flash und die RISC-V-Kerne des Pico 2 brauchen weiter die Probe.
- **Ein aBelle-Programm für jedes Board:** Ein Programm ohne Zeile `target` übersetzt Asmonite für das Ziel von
  **Project > aBelle for** (Windows x86, Windows x64 oder das Board im Reiter Serial; Asmonite merkt sich den Chip jedes
  Boards). Die Compiler nehmen dafür `--target <board>`, und ein `include`, das nicht neben der Datei liegt, kommt aus
  der Bibliothek `abelle\lib\<board>\` und dann `abelle\lib\common\`: `console.abel` (dieselben Funktionen der
  Konsole auf jedem Board und unter Windows; `println` und Co. in `console_text.abel`), `wifi.abel` je Board,
  `net.abel` und `tcp.abel` für alle. `def main():` geht auch unter Windows (Exit-Code 0). Getestet: dasselbe
  `examples/common/hello.abel`, das erste Beispiel für jedes Board (`include "console.abel"`,
  `println("Hello, world!")`), schreibt auf sechs Boards „Hello, world!“ über die serielle Ausgabe. Pins:
  `gpio_output(pin)` und `gpio_write(pin, an)` in `console.abel` jedes Boards (die Register des Chips stecken darin);
  Pico W und Pico 2 W kennen dazu `WL_GPIO0`, den Pin ihres WLAN-Chips mit der LED. Das zweite Beispiel,
  `examples/common/blink.abel`, lässt damit die LED blinken: oben `LED_PIN` für das eigene Board setzen (die
  bekannten Boards stehen im Kommentar).
- **WLAN auf dem Klon „Pico W-2023“** (ein RP2040 mit einem ESP8285 statt des CYW43439 eines Pico W, an UART0):
  eine eigene Firmware für den ESP8285 (`wlan/esp8285_fw.asm`, Xtensa LX106, mit den Bibliotheken des ESP8266 NONOS
  SDK von Espressif, gebunden von `ablink --chip esp8266`), die die Frames über UART0 (SLIP, 460800 Baud) an die
  Konsole weiterreicht. Board Manager > **Install WiFi (ESP8285)** schreibt sie über die Konsole des Pico in den
  ESP8285 (das Board dafür mit gehaltener BOOT-Taste einstecken; etwa 40 s, mit Fortschrittsbalken). Die Konsole
  erkennt den ESP8285 beim Start („Raspberry Pi Pico (WiFi: ESP8285)“, mit Foto im Board Manager) und nutzt ihn wie
  den WLAN-Chip eines Pico W: `wlan set`, `wlan on`, `wlan off`, `wlan scan`, das WLAN nach dem Start von selbst,
  ARP und Ping im Hintergrund, DHCP, `inc/wifi.abel` für Programme. UART0 gehört dann dem ESP8285, die Konsole
  spricht nur über USB. Getestet mit `ping` (Router und Internet), einem falschen Passwort und einem fehlenden Netz.

### Geändert
- **Die Konsolen der Boards liegen jetzt in `boards\`**, neben den Fotos des Board Managers:
  `boards/esp32/console.asm` (mit `help.txt` und dem DHCP-Teil), `boards/esp32s3`, `boards/esp32c3`,
  `boards/pico`, `boards/pico2` (auch die beiden Blink-Programme, mit denen der Board Manager die Kerne des
  Pico 2 umschaltet). Asmonite sucht sie in `boards\` neben Asmonite.exe; `examples\` ist für die Beispiele da.
- **Die Beispiele werden noch einmal durchgegangen, eines nach dem anderen.** In `examples/` stehen nur die neu
  getesteten (zuerst keines; aBelle-Programme für jedes Board kommen nach `examples/common/`); das ZIP und das
  öffentliche Repository nehmen nur diese. Die bisherigen Beispiele (in Assembler und in aBelle, vorher in
  `examples/` und `abelle/examples/`) liegen bis dahin in `examples_internal/` des Quelltext-Repositorys.
- Board Manager: Der Knopf Look Again heißt jetzt **Scan** (Alt+N).
- Board Manager: Der Knopf Reset Board heißt jetzt **Reset** (Alt+S); wie bisher startet er das Board neu und hält es
  in der Konsole (ein Autostart-Programm läuft nicht), sein Tooltip sagt das. Reset im Reiter Serial startet es wie
  sein Reset-Taster neu (ein Autostart-Programm läuft).
- Board Manager: Der Knopf Install WiFi Again heißt jetzt **Install WiFi...** (Alt+W).
- Ein leerer Flash: Erase Flash schreibt ein kleines Parkprogramm in den gelöschten Flash (`boards/<chip>/park.asm`,
  ESP32, S3, C3, S31): Das Board startet ruhig und sagt alle 3 s, dass es leer ist, statt immer wieder neu zu
  starten; dann fragt der Board Manager, ob gleich Prepare Board laufen soll. Ein Board, das mit leerem Flash immer wieder neu
  startet („invalid header: 0xffffffff“, „flash read err“), zeigt der Board Manager als „Console: none (the flash is
  empty; ...)“, und der Reiter Serial sagt es. Während Erase Flash arbeitet, läuft sein Fortschrittsbalken.
- Klareres Englisch in Asmonite und Dismonite: die Schritte beim Fortschritt („Writing the WiFi library“), die
  Meldungen nach einem Vorgang („WiFi package installed (352 KB in 9.8 s)“) und alle Rückfragen sagen in einfachen
  Worten, was geschieht.
- Board Manager: Der Knopf Read Chip heißt jetzt **Chip Details** (Alt+C); sein Tooltip nennt, was er liest (Chip und
  Revision, MAC, Flash, PSRAM, Quarz), und dass das Board dabei neu startet.

### Behoben
- ESP32-C3: Ein aBelle-Programm, das `millis()` nutzt (etwa ein Blink mit Pausen), hing unter F9 beim ersten
  Warten. Der USB-JTAG setzte den Chip vor dem Laden zurück; die Konsole blieb im RAM, war aber nicht eingerichtet
  (ihr Timer stand). Jetzt hält er die laufende Konsole nur an, ohne Reset (sie startet das Programm wie `run`,
  auch das WLAN bleibt); ist sie nicht eingerichtet, startet er sie nach dem Reset erst aus dem Flash.
- Die Konsole des Pico W hätte sich nach ihrem ersten DHCP für ein Board mit ESP8285 gehalten: Die Merkzelle dafür
  lag im selben Speicher wie die Adresse des Routers (nie veröffentlicht, gefunden beim Klon).
- Die Konsolen von Pico und Pico 2 veränderten in ihrem Fehler-Handler r7 eines Programms: Beim Pico geht jeder
  Schritt unter dem Debug-Monitor ohne Probe durch ihn, so verlor ein Programm, das etwas in r7 hält, es nach einem
  Schritt.
- Die Debug Probe nach einem Programm, das zwischen einem Kommando und seiner Antwort endete (ein Absturz): Asmonite
  meldete „the probe answers another command“, bis die Probe neu eingesteckt war, weil die alte Antwort noch in der
  Probe wartete. Jetzt liest Asmonite alte Antworten beim Öffnen der Probe weg und überspringt eine Antwort auf ein
  anderes Kommando.
- Der Thumb-Assembler schrieb `adds r0, r0, #39`, `subs r2, r2, #200`, `sub sp, sp, #12` in der 32-Bit-Form von
  Thumb-2: Beim Pico (Cortex-M0+, nur Thumb-1) wurde so eine Zeile abgelehnt, beim Pico 2 und der Blue Pill brauchte
  sie 4 statt 2 Bytes. Jetzt nimmt er die 16-Bit-Form, wenn die Zahl hineinpasst.
- Knöpfe, Checkboxen und Radiobuttons von Asmonite (im Board Manager, in der Leiste des Reiters Serial und in den
  anderen Fenstern) waren nach Alt oder Alt+Tab unsichtbar, bis die Maus darüberfuhr (gefunden vom Nutzer): ein Fehler
  von Delphi 7 mit den Themes von Windows; sie zeichnen sich jetzt neu, wenn Windows die Unterstreichungen der Tasten
  ein- oder ausblendet.
- telnetd (ESP32, ESP32-S3) nahm von den zwei Kopien des Verzeichnisses die erste, auch wenn die zweite neuer war (es
  verglich ihre Kennung statt ihrer Nummer): `ls` konnte die Dateien so zeigen, wie sie vor dem letzten Schreiben der
  Konsole waren.

## 0.14.0 – 2026-11-14

### Neu
- **Der Name des Boards** (ESP32, ESP32-S3): `name set keller` in der Konsole gibt dem Board einen Namen, `name`
  zeigt ihn, `name clear` nimmt wieder den aus der MAC (`esp32-789a`, beim S3 `esp32s3-789a`). Der Router lernt ihn
  per DHCP, die Konsole beantwortet am Prompt mDNS für `name.local` und nennt den Namen mit der Adresse; telnetd,
  webserver und die anderen Netzprogramme nehmen denselben Namen (`inc/net.abel` liest ihn; die festen `esp32` /
  `esp32s3` gibt es nicht mehr).
- **Ein Passwort für telnet** (ESP32, ESP32-S3): `passwd set` in der Konsole (8 bis 63 Zeichen; das Board behält 12
  Bytes eines PBKDF2-SHA1-Schlüssels daraus, nicht das Passwort), `passwd`, `passwd clear`. telnetd fragt danach und
  trennt nach dem dritten falschen; ohne Passwort lässt es jeden herein und sagt das. `inc/wifi.abel`:
  `wifi_login_set`, `wifi_login_check`.
- **Ping ohne Programm** (ESP32, ESP32-S3): Steht die WLAN-Verbindung der Konsole, holt sie sich per DHCP eine
  Adresse und meldet sie („WiFi: connected, address …“), und der WLAN-Dienst auf dem zweiten Kern beantwortet ARP
  und ping für sie selbst, auch während ein Programm läuft, das keine Pakete liest. So ist das Board nach einem
  Neustart oder Stromausfall per ping erreichbar. Die Konsole fragt nach der halben Leasedauer erneut und meldet
  „WiFi: no connection.“, wenn die Verbindung weg ist. `dhcp_run` aus `inc/net.abel` gibt seine Adresse ebenso an
  den Dienst weiter (neu: `wifi_set_ip`, `wifi_get_ip`).
- **Der Board Manager** (Board > Board Manager) ersetzt das Fenster Board Files. Er zeigt die angesteckten Boards,
  ein Foto des gewählten Boards, was Asmonite über es herausfindet, ohne es zu stören (Chip und Revision, Flash, die
  Konsole, die laufenden Kerne; MAC, Quarz und beim S3 der PSRAM im Chip mit Read Chip; das Netz eines ESP32 oder
  ESP32-S3: WLAN aus, verbindet oder verbunden, seine Adresse, MAC und sein Name), und nur die Knöpfe, die zum Board
  passen:
  - ESP32, ESP32-S3: die Dateien der Konsole wie bisher; Reset Board, Read Chip (über das Boot-ROM: das Board startet
    neu), Prepare Board, This Program Autostarts, Install WiFi Again, Format, Erase Flash.
  - ESP32-C3: Reset Board, Read Chip, Erase Flash, über sein Boot-ROM.
  - Pico, Pico 2 und die STM32F103 Blue Pill hinter der Debug Probe: Reset Board, Erase Flash; beim Pico 2 dazu
    RISC-V Cores / Arm Cores (das Beispiel `blink` der anderen Kerne kommt in den Flash).
  - Der Pico im USB-Boot (BOOTSEL): Start Program, Erase Flash. Der Pico 2 im USB-Boot: Arm Cores, RISC-V Cores, über
    sein Laufwerk.
  - Ein Board, das Asmonite nicht kennt: was Windows über es sagt, keine Knöpfe.
- Der Board Manager **öffnet sich von selbst**, wenn ein Board zum ersten Mal eingesteckt wird, auch beim Start von
  Asmonite mit einem solchen Board (gemerkt im Abschnitt `[Boards]` der Datei `Asmonite.ini`).
- Mit mehreren angesteckten Boards bleiben Board Manager und Reiter Serial beim selben Board: Der Board Manager öffnet
  sich mit dem Board des Reiters Serial, und beim Schließen verbindet sich der Reiter Serial mit dem Board, das zuletzt
  darin gewählt war.
- **telnetd versucht es wieder** (ESP32, ESP32-S3): Ohne sein Netz oder eine Adresse per DHCP meldet es das und
  versucht es alle 10 Sekunden neu, statt zu enden (nach einem Stromausfall startet der Router oft langsamer als das
  Board); fällt das WLAN weg, beendet es die Sitzung und holt sich wieder eine Adresse. Es endet nur, wenn das Board
  kein Netz kennt.
- Die ZIP-Datei hat die Fotos der Boards in `boards\`.

### Geändert
- **Im Reiter Serial tippst du direkt**: Die Tasten gehen sofort an das Board, wie in PuTTY (Enter, Rücktaste, Ctrl+C
  ohne Markierung stoppt das Programm, Ctrl+V fügt ein); ein Programm, das einzelne Tasten liest, bekommt sie ohne
  Enter. Der Haken **Line** in der Kopfzeile blendet die Zeile darunter wie bisher ein, für ein Programm, das nichts
  zurückschreibt.
- **Die Hilfe der Konsole ist eine Datei** auf dem Board, `help.txt` (ESP32, ESP32-S3): Prepare Board, Format und
  jedes Update der Konsole schreiben sie; `help` zeigt sie, ohne sie eine kurze Liste. Die Konsole hat dadurch etwa
  600 Bytes mehr Platz für ihre Daten.
- **Programme für die Boards haben keine Endung**: Aus `blink.abel` wird `blink` (abelle_esp32 ohne Namen für das
  Programm, Asmonite neben der Quelle und auf dem Board). Upload This Program und This Program Autostarts löschen ein
  `blink.bin` eines älteren Asmonite und stellen einen Autostart, der darauf zeigte, auf `blink` um. Die Konsole
  findet `name.bin` weiterhin. Quellen behalten `.abel`.
- **Das Menü Board** hat nur noch **Board Manager...**. **Write to Flash and Run (ESP32)** steht im Menü Project.
  Set This Program as Autostart ist der Knopf **This Program Autostarts**; Prepare Board, Erase Flash und Install WiFi
  Again sind Knöpfe des Board Managers.

### Behoben
- telnetd konnte auf dem ESP32 das Board mit „IllegalInstruction“ anhalten, wenn es startete, während sich das WLAN
  der Konsole gerade verband (als Autostart nach einem Stromausfall, solange der Router noch nicht da ist): Es richtete
  die MMU des ersten Kerns für die Dateien ein, während der zweite Kern das WLAN aus dem Flash ausführte. Jetzt bildet
  die Konsole die Dateien bei ihrem Start ab, vor ihrem WLAN, und telnetd lässt die MMU in Ruhe, sobald das WLAN läuft;
  außerdem nimmt es die Größe des Flashs, die die Konsole kennt, statt den Flash zu fragen (`wifi_flash_size` aus
  `inc/wifi.abel`).
- Nach dem Ende eines Programms, das F9 (oder Run im Board Manager) über die Konsole gestartet hatte, zeigte die
  Konsole erst nach Enter wieder einen Prompt (ESP32, ESP32-S3); jetzt schreibt sie `> ` von selbst.

### Bekannt
- Zwei ESP32-DevKits mit dem USB-Seriell-Chip CP2102 haben dieselbe Seriennummer („0001“); das zweite gilt schon als
  gesehen und öffnet den Board Manager nicht von selbst.

## 0.13.0 – 2026-11-12

### Neu
- **Der ESP32-S3 als zweites Board für aBelle, die Konsole und das WLAN.** Alles, was der ursprüngliche ESP32 seit
  0.12.0 kann, geht jetzt auch auf dem ESP32-S3, über den USB-Anschluss des Chips (ohne USB-Seriell-Chip):
  - aBelle mit `target "esp32s3"` (der Compiler `abelle_esp32.exe`): F9 führt ein Programm aus, Breakpoints,
    Einzelschritte und Variablen im Quelltext. Beispiele in `examples/abelle/esp32s3/`, darunter `hello_usb.abel` und
    `rgb.abel` (die RGB-LED des Boards, ein WS2812 an GPIO 48, angesteuert über das RMT).
  - Die Konsole mit Dateisystem (`examples/esp32s3/console.asm`, das Dateisystem bis zum Ende des Flash).
  - Das WLAN: Netze suchen, offene Netze und WPA2, DHCP, DNS, Ping, TCP. Die WLAN-Beispiele des ESP32 (`dhcp`, `ping`,
    `dns`, `ntp`, `httpget`, `webserver`, `udpecho`, `wol`, `arpscan`, `telnetd` und weitere) gibt es auch für den
    S3. Die WLAN-Bibliotheken von Espressif bindet `ablink --chip esp32s3`; der S3 hat kein `aes_unwrap` im ROM, der
    WPA2-Code von Asmonite bringt deshalb ein eigenes mit (AES-128 Key Unwrap, RFC 3394).
- **Die Konsole ist die Heimat der Programme** (ESP32 und ESP32-S3):
  - **F9 führt ein Programm über die Konsole aus:** ins RAM, dort gestartet, die Ausgabe im Reiter **Serial**. Kein
    Download-Modus, keine BOOT-Taste, kein Reset, keine Ausgabe geht verloren. **Stop** (oder Ctrl+C) beendet es,
    auch eine Endlosschleife mit gesperrten Interrupts; danach ist die Konsole wieder da.
  - **Debuggen über die Konsole:** Mit einem Breakpoint startet F9 den Debugger ohne Reset des Boards; nach der
    Sitzung ist die Konsole wieder da.
  - Ein Programm kehrt zur Konsole zurück, wenn `main` endet, mit `exit(code)` aus beliebiger Tiefe oder nach einer
    Exception (die Konsole sagt, warum).
  - **Funktionen der Konsole für Programme:** eine Tabelle an fester Stelle (ESP32 `0x4009C800`, S3 `0x403C0800`):
    `exit`, `version`, `put_char`, `get_char`, `poll_char`, `print`, `millis`, `args`, `file_size`, `file_read`,
    `file_write`, `flash_read`. aBelle: `include "inc/console.abel"`, Beispiel `runs.abel`.
  - **Programme als Befehle:** Ein Wort, das die Konsole nicht kennt, startet die Datei dieses Namens; der Rest der
    Zeile sind ihre Argumente.
  - Der Reiter **Serial** verbindet sich selbst, wenn Asmonite startet oder das Board eingesteckt wird, und zeigt Chip
    und Konsole in seiner Kopfzeile.
- **Das WLAN als Dienst der Konsole** (ESP32 und ESP32-S3):
  - `wlan set` speichert das Netz auf dem Board (das Passwort wird ohne Echo abgefragt; das Board behält nur den
    daraus berechneten WPA2-Schlüssel), `wlan`, `wlan on`, `wlan off`, `wlan clear`.
  - Mit gespeichertem Netz verbindet sich die Konsole beim Start im Hintergrund. Programme nutzen diese Verbindung
    sofort (`wifi_connect_saved()` in `inc/wifi.abel`) und lassen sie dem nächsten Programm (`wifi_done()`). Die
    WLAN-Beispiele enden und kehren zur Konsole zurück; die Server laufen bis Stop.
  - WLAN-Bibliothek und Dienst liegen in einem festen Bereich des Flash (das WLAN-Paket). F9 schreibt es dorthin,
    wenn ein Programm es braucht.
  - Der Flash lässt sich schreiben, während das WLAN läuft (die Konsole parkt dafür Kern 1).
  - Ein Programm, das neben dem WLAN keinen Platz hat, bekommt auch dessen Bereich (ESP32: 112 KB Code statt 76;
    S3: 156 KB Code und 128 KB Daten); die Konsole hält das WLAN dafür an und startet es danach wieder.
    `abelle_esp32` sagt das an („it runs without the WiFi“).
- **Das Menü Board** (zwischen Debug und Help): **Files...** (das Fenster Board Files), **Set This Program as
  Autostart**, **Prepare Board...** und **Advanced**: **Write to Flash and Run...** (mit Warnung: es ersetzt die
  Konsole), **Erase Flash...**, **Install WiFi Again...**.
- **Prepare Board:** Ein Board ohne die Konsole von Asmonite (neu, gelöscht, MicroPython) wird erkannt; Prepare Board
  schreibt die Konsole und legt das Dateisystem an. Asmonite bietet das bei F9 an.
- **Updates von selbst:** Vor F9 und vor dem Debuggen vergleicht Asmonite die Konsole auf dem Board mit der eigenen
  und schreibt bei einem Unterschied die eigene (Dateien und Netz des Boards bleiben), danach bei Bedarf das
  WLAN-Paket.
- **`.if`, `.elif`, `.else`, `.endif`** im Assembler: Bedingungen über Konstanten (`equ`, Zahlen, Vergleiche, `&&`,
  `||`, `!`, `defined(name)`); ein Quelltext für mehrere Chips. Eine Konstante darf jetzt vor `.format`, `.target`
  und `.output` stehen.

### Behoben
- **ESP32-S3-Boards, die beim Start des WLAN neu starteten:** Auf manchen Boards (Chip v0.2) setzte der
  Taktglitch-Detektor den Chip etwa 0,3 s nach dem Start des Funkteils zurück, und der USB-Anschluss verschwand.
  WLAN-Dienst und Konsole schalten diesen Reset vor dem Start des Funkteils ab; Asmonite bringt das neue WLAN-Paket
  selbst auf das Board.
- **Das Fenster Debug targets** schnitt die letzten Zeilen längerer Texte ab; es misst seine Texte jetzt und wächst mit
  ihnen.
- ESP32: UART0 bei laufendem WLAN: Die Konsole zählt die Bytes im FIFO wie ESP-IDF und schaltet den Takt vor ihrem
  Hallo um, so kommen Pakete von Asmonite nicht mehr verstümmelt an. Die Beispiele `hello_uart_ram.asm`,
  `hello_uart_flash.asm` und `clock_ram.asm` schreiben UART0 über `0x60000000`, wie die Konsole.
- Pause, während ein Programm in einer Funktion des Boot-ROM wartet (zum Beispiel `ets_delay_us`), hält nach der
  Rückkehr im Quelltext an (Xtensa).

### Geändert
- **(Quelltexte)** Feste Speicherfenster für Programme, gleich auf jedem Weg (F9, Konsole, mit oder ohne WLAN):
  - ESP32: aBelle-Code bis 76 KB (`0x40080000 .. 0x40092FFF`); Assembler und Debugger nehmen ein Programm bis
    `0x4009BFFF` (darüber liegt die Konsole).
  - ESP32-S3: aBelle-Code bis 96 KB (`0x40378000 .. 0x4038FFFF`), die Daten ab `0x3FCA0000` bis 60 KB, darüber 4 KB
    Stack. `.data` des Assemblers ohne Adresse beginnt bei `0x3FCA0000` (vorher `0x3FCA8000`).
- **Write to Flash and Run** steht im Menü Board unter Advanced; Shift+F9 entfällt. Das Fenster Board Files behält nur
  die Dateien, Reset Board und Format.
- Der Debug-Monitor des ESP32 liegt im RTC-FAST-Speicher (`0x400C0000`), das IRAM bleibt für Programme und Konsole.
- ESP32-S3: Der Debugger stellt den Daten-Cache ein wie ein Start aus dem Flash (32 KB).
- Bekannt: Beim ESP32 DevKit kommt bei verbundener Station etwa ein Byte von 500 000 über UART0 falsch an; Pakete haben
  eine CRC und werden wiederholt.

## 0.12.0 – 2026-11-10

### Neu
- **aBelle**, eine kleine Programmiersprache mit der Schreibweise von Python, nah an der Hardware (`.abel`). Ihr
  Compiler ist in aBelle geschrieben und übersetzt sich selbst; er schreibt den Maschinencode selbst, mit einer
  Map-Datei für den Debugger. Drei Compiler liegen in der ZIP neben Asmonite: `abelle.exe` (Windows, x86),
  `abelle64.exe` (Windows, x64; Project > aBelle for x64) und `abelle_esp32.exe` (der ESP32, `target "esp32"`). In
  Asmonite übersetzt und debuggt F9 eine `.abel`-Datei in ihrem Quelltext: Breakpoints, F7/F8 Zeile für Zeile,
  Variablen unter der Maus und im Fenster Watch nach ihrem Typ, F1-Hilfe zu den Wörtern der Sprache. Auf dem ESP32:
  Register als Felder an einer festen Adresse (`gpio: u32[0x140] at 0x3FF44000`), Funktionen des ROM
  (`def ets_delay_us(us: u32) at 0x40008534`), F9 in den RAM, Shift+F9 in den Flash. Beispiele in `examples/abelle/`
  und `examples/abelle/esp32/` (blink, timer, chipinfo, clock, dice, reaction, sieve, temperature ...). Seite:
  asmonite.com/de/abelle.html.
- **WLAN auf dem ursprünglichen ESP32**, ohne ESP-IDF: **Debug > ESP32 Board Files > Install WiFi** bringt das WLAN
  aufs Board (sein Teil im Flash bei 0x100000, `wlan.rom` und der Dienst `wlansvc` in die Dateien der Konsole;
  `wlan.rom` enthält die WLAN-Bibliotheken von Espressif, einmal gebunden mit dem eigenen Linker von Asmonite,
  Apache-Lizenz 2.0, siehe `wlan/`). Ein aBelle-Programm lädt den Dienst selbst (`inc/wifi.abel`), mit `run` in der
  Konsole wie unter F9. Das WLAN läuft auf dem zweiten Kern: Der Debugger hält das Programm auf dem ersten Kern am
  Breakpoint an, und die Station bleibt verbunden. Scan, offene Netze und WPA2, Frames hinein und hinaus; ein kleiner
  IP-Stack in aBelle (`inc/net.abel`: ARP, IPv4, Ping in beide Richtungen, UDP, DHCP mit dem Namen des Boards, DNS,
  mDNS: das Board ist unter `esp32.local` erreichbar) und TCP (`inc/tcp.abel`, eine Verbindung zur Zeit, als Client
  oder Server). Beispiele: scan, dhcp, dns, ping, wol (Wake-on-LAN), arpscan, ntp, udpecho, httpget, webserver
  (`http://esp32.local/`), telnetd (eine kleine Shell über Telnet: Dateien, Speicher, Ping, LED). Ein Fehler des WLAN
  kommt als Satz (`wifi_error_text`). Seite: asmonite.com/de/esp32.html.
- Assembler: **`.include "name"`** setzt den Text einer anderen Datei an diese Stelle (der Name gilt vom Ordner der
  Datei aus, in der die Zeile steht; jede Datei wird einmal gelesen, eine eingebundene Datei darf weitere einbinden).
  Fehlermeldungen und Warnungen nennen die eingebundene Datei und ihre Zeile (`inc\uart.asm(12): ...`), in Asmonite
  und in `asmoc`. Hält der Debugger in einer eingebundenen Datei, zeigt der Editor sie an Stelle der Quelle,
  schreibgeschützt; Breakpoints, Einzelschritte, F4 und die Werte unter der Maus gehen dort wie in der Quelle.
  F1-Hilfe: Direktiven.
- ESP32: **`.data`** legt Texte, Tabellen und Puffer ins DRAM (ab `0x3FFB0000`, oder `.data 0x3FFC0100`), wo sich Bytes
  lesen und schreiben lassen: Das IRAM des Programms nimmt nur Wörter, ein `l8ui` auf einen Text dort hielt mit einem
  LoadStoreError an. `.code` schaltet zurück zum Code. Der Debugger lädt die Daten nach dem Code; ein Programm für den
  Flash bekommt sie als zweites Segment im Image, das das Boot-ROM bei jedem Start kopiert. Daten, die in den Stack
  (`0x3FFBF000..0x3FFC000F`) oder aus dem DRAM hinaus reichen, sind ein Fehler. `examples/esp32/hello_uart_ram.asm`
  liest seinen Text jetzt Byte für Byte, neu: `hello_uart_flash.asm`.
- Website: Die Originaldokumentation jeder Befehlsreferenz hat einen Link pro Zeile.
- Doku: `docs/de/boards.md`, welches Board wie debuggt wird (über eine Debug-Probe oder mit dem USB-Kabel allein) und
  wie seine serielle Ausgabe zum PC kommt, auch als Tabelle auf der Seite der Ziele; neue Anleitungen für die Blue Pill
  (`stm32.md`) und den LilyGO T-PicoC3 (`t-picoc3.md`); riscv-pico2.md, picoboot.md und d1.md sagen, was es ohne Probe
  und für die serielle Ausgabe gibt.
- ESP32: Was das Programm unter dem Debugger über UART0 schreibt, erscheint im Reiter **Serial** (so wie es kommt, der
  Reiter kommt nach vorn), nicht mehr als Zeilen „UART0: …“ im Ausgabefenster. Solange die Sitzung dauert, sind
  Connect, Port, Baudrate und die Eingabe gesperrt, und die Kopfzeile sagt, dass der Debugger den Port hat; ein im
  Reiter verbundener Port wird beim Start freigegeben (bisher meldete F9 „COM14 is open in another program“).
- Raspberry Pi Pico 2, Pico und Blue Pill: Der Reiter Serial verbindet sich von selbst mit dem UART der Raspberry Pi
  Debug Probe (ihr Stecker „U“), wenn eine Sitzung über die Probe das Programm geladen hat; er schaltet dafür DTR ein
  (die Probe sendet nur dann) und lässt es bei den Boards von Espressif aus. Neue Beispiele `hello_uart_ram.asm` für
  den Pico 2 (RISC-V; `hello_uart_arm_ram.asm` für Arm), den Pico und die Blue Pill: „Hello, world!“ mit 115200 Baud
  (RP2040 und RP2350 starten dafür ihren Quarz). Die Anleitung riscv-pico2.md sagt, wie das Kabel geht.
- ESP32-S3 und ESP32-C3: Der Reiter Serial verbindet sich von selbst mit dem seriellen Port des USB-Anschlusses des Chips, wenn der
  Debugger das Programm geladen hat (beim Start gibt er ihn frei: Der Reset ins Boot-ROM und der Flash brauchen ihn);
  der Debugger behält den JTAG desselben Anschlusses. Neu: `examples/esp32s3/hello_usb_ram.asm` (USB Serial/JTAG). Die
  Anleitung sagt, wie Bytes im RAM gelesen werden: Die IRAM-Adresse nimmt nur Wörter, dasselbe Byte am Datenbus liegt
  0x6F0000 tiefer.
- ESP32: **Debug > Pause** hält ein laufendes Programm an, auch in einer Endlosschleife, und Stop beendet die Sitzung
  sofort (bisher musste man auf einen Haltepunkt warten). Der Debug-Monitor von Asmonite nimmt ein Byte auf UART0 als
  NMI, während das Programm läuft. Auf dem Board auch mit dem Flash getestet (`.target esp32 flash` unter dem
  Debugger).
- Reiter Serial: Die Liste der Ports zeigt den Port zuerst (`COM14 - Silicon Labs CP210x USB to UART Bridge`), so ist
  er auch in einer schmalen Box zu sehen; die aufgeklappte Liste ist so breit wie ihr längster Eintrag, und der ganze
  Eintrag ist der Hinweis (Tooltip) der Box.

- Befehlsinfo (F1): Jeder Befehl des Assemblers hat jetzt einen Abschnitt. Wo die Hilfe keine eigene Erklärung hat (das
  meiste von SSE, x87, Gleitkomma und Neon bei ARM64, die Befehle von Xtensa), zeigt F1 den kurzen Abschnitt aus der
  Befehlsreferenz: Syntax, Wirkung, Flags (help/<Sprache>/<arch>_ref.md, erzeugt von tools/gen_help_ref.py aus den
  Tabellen des Assemblers). Neu: eine Hilfe für Xtensa (Registerfenster, `l32r`, `loop`, das Schieben über `SAR`,
  Laden und Speichern und das IRAM, Spezialregister), die Überblicke `x87` und `sse` für x86 (F1 auf einem x87- oder
  SSE-Befehl zeigt sie nach seinem eigenen Abschnitt).
- **File > Open Recent**: die letzten fünf Dateien, geöffnet oder unter neuem Namen gespeichert (in der ini-Datei
  gemerkt); eine Datei, die es nicht mehr gibt, verlässt die Liste.
- Asmonite und Dismonite: Das Mausrad scrollt den Teil des Fensters unter dem Mauszeiger (Editor, Register, Stack,
  Speicher, Ausgabe), nicht den mit dem Fokus.
- ESP32: neues Beispiel `examples/esp32/clock_ram.asm`: der Kern vom Quarz (40 MHz) und von der PLL mit 80, 160 und
  240 MHz, so wie der Bootloader von ESP-IDF sie einrichtet (die PLL über den I2C-Bus im Chip mit der Funktion
  `rom_i2c_writeReg` des ROMs, aufgerufen mit `callx8`; die Spannung des Kerns für 240 MHz); UART0 und der Timer folgen
  jeder Änderung des Takts der Peripherie. Es schreibt, wie schnell eine Schleife bei jedem Takt läuft: auf einem
  DevKit V1 6664, 13333, 26666 und 40000 Durchläufe pro Millisekunde.
- ESP32: neues Beispiel `examples/esp32/console.asm`, eine **Konsole über UART0 mit einem kleinen Dateisystem** im
  Flash, für jedes Terminalprogramm (115200 Baud): `ls`, `cat`, `put` (einen Text tippen oder einfügen, bis 64 KB,
  dann eine Zeile mit nur einem Punkt), `rm`, `df`, `format`, `help`. Backspace, Ctrl+C und CR, LF oder CR LF am
  Zeilenende funktionieren. Das Dateisystem belegt die oberen 2 MB eines Flash mit 4 MB: ein Verzeichnis für 64
  Dateien, doppelt gehalten, sodass ein Reset während des Schreibens das alte stehen lässt; jede Datei mit ihrer
  CRC-32. Der Flash wird mit den Funktionen des ROMs beschrieben. Was hereinkommt, landet in einem Ring von 4 KB,
  auch während die Konsole sendet; so kommt auch ein eingefügter Text von 62 KB vollständig an. Schreiben mit Debug >
  Write to Flash and Run, die Sitzung beenden, dann der Reiter Serial (Connect, Reset) oder ein anderes Terminal.
  Unter dem Debugger läuft sie nicht: Der Debug-Monitor nimmt jedes Byte auf UART0 als seine Pause.
  Ein Programm auf dem PC spricht mit ihr in Paketen (STX, Befehl, Länge, Daten, CRC-32): Dateien jeder Art und Größe
  hoch und herunter (etwa 10 KB/s), die Liste, der Platz, Löschen; ein beschädigtes Stück wird neu geschickt. Asmonite
  hat die Gegenseite in `src/debugger/EspConsole.pas`.
  `run name` startet ein Programm aus einer Datei (dem Image, das Asmonite in den Flash schreibt: Code und `.data`),
  `boot name` startet es nach jedem Reset (eine Sekunde, um in der Konsole zu bleiben: BOOT oder eine Taste),
  `noboot` beendet das. Ein Programm für F9 passt unverändert: Die Konsole liegt darüber (Code ab `0x4009C000`, Daten
  ab `0x3FFD0000`); die Datei wird an ihrer CRC-32 geprüft, die Segmente an ihren Adressen. `load name` bringt die
  Teile eines Programms für den RAM an ihren Platz, ohne es zu starten, auch in den Raum zwischen den Programmen und
  der Konsole (IRAM `0x40098000` .. `0x4009BFFF`, DRAM `0x3FFD8000` .. `0x3FFDFFFF`); Segmente für den Flash lässt es
  aus. Ein Teil, den `load` dorthin bringt, kann eigene Befehle mitbringen (bei `0x40094000` das Wort `CMDS` und die
  Adresse einer Tabelle aus Namen, Funktionen und Zeilen für `help`); nach einem Reset vergisst die Konsole sie. Ihre
  Wartezeiten folgen dem Takt des Kerns (`g_ticks_per_us_pro` des ROMs), auch wenn ein Programm ihn geändert hat.
- ESP32: **Debug > ESP32 Board Files**, ein Fenster für die Dateien der Konsole: die Liste (mit dem Programm, das nach
  einem Reset startet), Upload File, Upload This Program (das Programm im Editor als Image), Download, Delete, Run
  (danach zeigt der Reiter Serial, was es schreibt), Autostart, Reset Board, Format, Write Console to Flash. Die Arbeit
  läuft im Hintergrund mit ihren Schritten und einem Balken; Cancel bricht sie ab. Doku: esp32.md hat einen Teil zur
  Konsole und sagt, wie Write to Flash and Run arbeitet.
- ESP32: **Debug > Write to Flash and Run** (Shift+F9) schreibt ein Programm für den RAM (`.target esp32`) zuerst in
  den Flash, wie `.target esp32 flash` es tut, und debuggt es dann wie F9: Das Board startet es bei jedem Start. So
  geht derselbe Quelltext ohne Änderung in den RAM oder in den Flash (`.target esp32 flash` bleibt, wie es war).
- Boards: ein **Startfenster** mitten über Asmonite, während eine Sitzung startet (ab einer halben Sekunde): die
  Schritte (verbinden, die Resets in den Download-Modus mit dem Versuch, der Debug-Monitor, das Programm, der Flash,
  der Lauf bis zur Zeile), ein Balken für die Bytes, die Zeit bisher und **Cancel**. Es geht, sobald das Programm läuft
  oder angehalten hat. Alle Schritte beim ESP32; die anderen Boards zeigen Verbinden, Programm oder Flash und den Lauf
  bis zur Zeile.
- ESP32: Ein Schritt über eine Zeile, die lange dauert (eine Schleife in einer Zeile, `for: pass` in einem übersetzten
  Programm), läuft nach 100 Einzelschritten mit voller Geschwindigkeit weiter, mit Breakpoints an den Zeilenanfängen.
- ESP32: Der Flash wird mit 921600 Baud geschrieben (Write to Flash and Run, Write Console to Flash): Das Boot-ROM
  wechselt seine Rate (CHANGE_BAUDRATE), ein Lesezugriff mit der neuen Rate prüft sie; schafft das Board sie nicht,
  startet Asmonite das Boot-ROM neu und schreibt mit 115200. 334 KB dauerten 14,6 s statt 44 s.
- ESP32-Debugger: Ein Programm ab 16 KB wird mit 921600 Baud geladen (98 KB in 6,3 s statt 21 s). Der Debug-Monitor
  wechselt die Rate von UART0 auf den Befehl `b` und geht von selbst zurück, wenn mit der neuen Rate keine Antwort
  kommt; jedes Stück von 8 KB wird zurückgelesen und neu geschrieben, wenn es abweicht. Bevor das Programm läuft
  oder einen Schritt macht, gilt wieder 115200, wie das Programm es erwartet.
- ESP32 Board Files: Ein Upload oder Download ab 16 KB läuft mit 921600 Baud (100 KB hoch in 3,7 s statt 11,5 s,
  herunter in 1,8 s statt 9,6 s). Die Konsole wechselt die Rate von UART0 auf das Paket `S` und geht zurück, wenn
  das nächste Paket nicht richtig ankommt; am Ende jeder Übertragung gilt wieder 115200, die Rate eines Terminals.
- ESP32: Die Größe des Flash des Boards aus seiner JEDEC-ID (der Befehl 0x9F über SPI1, wie esptool flash_id):
  Test the connection und Board Files zeigen sie an („flash 4 MB (Boya, JEDEC id 68 40 16)“), Write to Flash
  verweigert ein Image, das nicht hineinpasst, Erase Flash löscht ihn ganz, und mit weniger als 4 MB warnt Board
  Files und formatiert nicht (das Dateisystem der Konsole liegt bei 2 bis 4 MB). Die Konsole beantwortet das Paket
  `I` mit der ID. Auch das Beispiel chipinfo zeigt sie.
- ESP32-Konsole: Das Dateisystem reicht von 2 MB bis zum Ende des Flash (2 MB bei 4 MB Flash wie bisher, 6 MB bei
  8 MB wie auf einem WROVER; bis 16 MB). Ein vorher formatiertes Board behält seine Größe bis zum nächsten Format.
- ESP32: Scheitert das Schreiben des Flash mit der schnelleren Rate, obwohl sie ihre Prüfung bestanden hat (ein
  USB-Seriell-Chip, der 3 MBaud annimmt), startet Asmonite das Boot-ROM neu und schreibt das ganze Image mit 115200:
  Es bleibt kein halb geschriebenes Image zurück.
- ESP32 Board Files: **Erase Flash...** löscht den ganzen Flash (4 MB beim DevKit) über das Boot-ROM, wie bei einem neuen Board:
  keine Konsole, keine Dateien (8 bis 17 s). Write Console to Flash und Format machen daraus wieder ein Board für
  Asmonite.

### Behoben
- ESP32: Der Debugger konnte kein Programm laden, das größer als etwa 34 KB ist („Cannot write the program to
  40080000“): Er schickte es in einem Stück, und das dauerte länger, als der serielle Port für einen Schreibvorgang
  zulässt. Es geht jetzt in Stücken von 8 KB. Die Meldung eines solchen Fehlers nennt den Grund (und verweist nicht
  mehr auf `.imagebase 0x20000000` des Pico).
- Boards: Pause und Stop wirkten nicht, solange ein Schritt Befehl für Befehl lief (eine lange Zeile): Die Sitzung
  blieb auf „running“. Ein Stop, auf den das Board 3 Sekunden lang nicht antwortet, beendet die Sitzung trotzdem.
- ESP32: Ein Reset des Boards, während das Programm lief (Knopf EN, Strom), ließ Asmonite auf „running“, und weder
  Pause noch Stop beendeten das. Die Zeile `rst:0x…,boot:0x…` des Boot-ROMs am Port beendet die Sitzung jetzt mit
  einem Hinweis.
- Befehlsinfo (F1): Mit `.arch riscv64` und mit `.arch xtensa` zeigte sie die Hilfe für x86.
- ESP32: Ein Programm, dessen Aufrufe tiefer gehen, als die 64 Register der Fenster fassen (mehr als etwa sieben
  `call8`), hielt mit einer Double Exception im Überlauf-Handler an: Der Monitor legt jetzt unter den ersten `sp` einen
  Rahmen für den Aufrufer von `_start`, wie ESP-IDF.
- ESP32: Solange ein Programm den zweiten Kern (die APP-CPU) beschäftigte, bekam `examples/esp32/console.asm` hin
  und wieder ein Byte von UART0 doppelt. Die Konsole und der Debug-Monitor lesen und schreiben UART0 jetzt wie
  ESP-IDF (den RX-FIFO bei `0x3FF40000`, den TX-FIFO bei `0x60000000`), der Monitor leert den RX-FIFO bei einem
  Stopp, und beide schauen beim Warten seltener nach: Ein Kern, der den APB ständig belegt, kann die Lesezugriffe des
  anderen Kerns auf DPORT-Register verfälschen (ein Erratum des ESP32).
- x86-Assembler: Ein Abstand von 128 bis 255 in 32-Bit-Code (`mov eax, [esp+200]`, `[ebx+200]`) wurde als ein Byte
  geschrieben, das der Prozessor als -128 bis -1 liest; jetzt nimmt er 32 Bit. 16-Bit-Code behält 0 bis 255 als ein
  Byte, wie geschrieben.
- `.format pe`: Ein Abschnitt, dessen Größe ein Vielfaches von 0x200 ist (Code von genau 0x200, 0x400, 0xC00 …
  Bytes), bekam in den Köpfen die Größe 0x1000: Windows lud das Programm nicht, oder es stürzte ab. Ein Label am Ende
  eines solchen Abschnitts (`data_end:`) hatte die Adresse des Anfangs des nächsten.

## 0.11.0 – 2026-11-06

### Behoben
- Ein Zeichen als Immediate geht auch außerhalb von x86: `movs r0, #'0'` (Thumb), `li a0, 'A'` (RISC-V), `movi a2,
  '1'` (Xtensa). Thumb nimmt auch die kurzen Schreibweisen von GAS: `lsrs r1, r1, r3` und `ands r2, r2, r4` geben die
  16-Bit-Form, `muls r1, r0` geht, `dsb`, `dmb`, `isb` brauchen keine Option, und `mrs`/`msr` kennen die
  Spezialregister des Cortex-M (`primask`, `control`, `msp`, `psp`, `basepri`, `faultmask` ...). Mit `.target pico`
  nennt ein Laden oder Speichern, dessen Offset für den Cortex-M0+ zu groß ist (`ldrb r0, [r2, #40]`), die Bereiche,
  die er hat.
- Ein Wort mit Doppelpunkt ist in jedem Modus außer x86 eine Marke, auch wenn es der Name eines x86-Befehls ist:
  `loop:` wurde unter `.arch riscv32` (und thumb, x64, arm64) abgelehnt.
- Pico 2: Das Umschalten von den Arm-Kernen zurück auf die RISC-V-Kerne klappt wieder, wenn der Chip in seinem
  USB-Boot steht (BOOTSEL), etwa weil im Flash kein Programm steht, das das Boot-ROM starten kann. Der Arm-Kern blieb
  dort im HardFault des Boot-ROMs stehen („stopped for another reason (DFSR 03, pc 000002F8)“): Der USB-Boot läuft
  im Non-secure-Zustand, mit einer Stack-Grenze und dem RAM als Non-secure. Der Debugger setzt den Kern für die
  Flash-Funktionen des Boot-ROMs jetzt auf Secure. Ein Programm für die anderen Kerne ohne IMAGE_DEF-Block wird nicht
  mehr geschrieben (das Boot-ROM könnte es nicht starten, der Chip bliebe im USB-Boot): Der Debugger sagt das
  stattdessen.

### Neu
- **Der Raspberry Pi Pico (RP2040) ohne Debug-Probe:** Steht das Board in seinem USB-Boot (BOOT halten, RUN drücken:
  das Laufwerk RPI-RP2), debuggen F9 und F7 ein Programm mit `.target pico` für das RAM allein über das USB-Kabel:
  Breakpoints, Schritte Zeile für Zeile, Schritt über einen Aufruf, die Register, das RAM; kehrt das Programm zurück,
  zeigt das Ausgabefenster r0 und r1. Ein kleiner Stub von Asmonite bei 0x2003F000 wird vom Boot-ROM aufgerufen
  (PICOBOOT, die Schnittstelle von picotool) und kommt an jedem Breakpoint zurück. Keine Pause eines laufenden
  Programms; nur Programme im RAM (unter 0x2003F000). Einmal für jedes Board: der Treiber WinUsb Device für „RP2
  Boot“, dann Debug > Debug targets > Raspberry Pi Pico > „Set up the USB boot“. Ausprobiert mit einem LilyGO
  T-PicoC3. Anleitung: `docs/de/picoboot.md`.
- Beispiele: `examples\esp32c3\sum_ram.asm` (die Summe von 1 bis 100 mit einer Funktion, ohne Pin: für jedes
  C3-Board) und `examples\t-picoc3\display_ram.asm` für das LilyGO T-PicoC3 (ein RP2040 und ein ESP32-C3 auf
  einem Board): Der RP2040 füllt sein Display (ST7789 über SPI0) und schaltet die rote LED ein; als UF2 fürs RAM
  (Project > UF2, dann auf das Laufwerk RPI-RP2), der Flash bleibt, wie er ist. Beide am Board ausprobiert.
  `examples\t-picoc3\lines_ram.asm`: ein weißer Rahmen und Linien in den Farben des Regenbogens auf dem Display (eine
  Routine, die ein Rechteck füllt), gemacht für den Debugger über den USB-Boot: Es kehrt zurück, das nächste F9
  zeichnet wieder. `examples\t-picoc3\text_ram.asm`: Text mit einem eigenen Zeichensatz (5 × 7 Punkte, Ziffern und
  Großbuchstaben) und ein Zähler, der auf dem Display hochzählt, während die rote LED blinkt; eine Taste des Boards
  beendet ihn.
- **ESP32 (der ursprüngliche, Xtensa LX6): ausführen und flashen** mit `.target esp32` und `.target esp32 flash`
  (`.arch xtensa`, das IRAM bei `0x40080000..0x4009FFFF`): F9 setzt den Chip über die Leitungen DTR und RTS des
  USB-Seriell-Chips des Boards (CP210x, CH340, CH9102, CH343, FTDI) in den Download-Modus seines Boot-ROMs, wie esptool,
  und legt das Programm ins RAM und startet es, oder schreibt es in den Flash bei `0x1000` (ein Image des Boot-ROMs,
  Chip-ID 0) und setzt den Chip zurück. Ein Reset wird an der ersten Zeile des Boot-ROMs geprüft und wiederholt, bis sie
  „DOWNLOAD“ sagt; kommt ein Board in 10 Sekunden nicht dorthin, bekommt der Benutzer den Hinweis „BOOT halten“.
  **Debuggen** über denselben seriellen Port: Ein kleiner Debug-Monitor von Asmonite (`esp32mon.asm`, 2 KB oben im
  IRAM) übernimmt die Vektoren von break, ICOUNT und den Ausnahmen und spricht über UART0 mit Asmonite (Register,
  Speicher, laufen, Schritt): Haltepunkte, Schritte in und über Aufrufe mit Registerfenster, die Register; was das
  Programm über UART0 schreibt, steht im Protokoll. Noch keine Pause.
  `salt`, `saltu` werden für den LX6 abgelehnt. Debug targets: der Eintrag ESP32 mit Test the connection (COM-Port und MAC-Adresse). Beispiele `examples/esp32/` (`blink_ram.asm`,
  `blink_flash.asm`: die LED an GPIO 2; `hello_uart_ram.asm`: Text am COM-Port des Boards). Anleitung:
  `docs/de/esp32.md`.
- **RISC-V mit 64 Bit (RV64)**: `.arch riscv64` im Assembler und im Disassembler: RV64I, M, A, die RV64-Formen von
  Zba, Zbb, Zbs, Zbc, Zbkb, die 16-Bit-Formen von RV64 (`c.ld`, `c.sd`, `c.addiw` …); `li` nimmt jede 64-Bit-Zahl,
  mit einer Marke 4 Befehle, die eine Adresse ab `0x80000000` positiv lassen. Gegen capstone geprüft; F1-Hilfe für
  die neuen Befehle.
- **MangoPi MQ-Pro (Allwinner D1, RV64)** mit `.target d1`: F9 lädt das Programm über USB ins SRAM des Chips (der
  FEL-Modus seines Boot-ROMs, ein Kabel, ohne sunxi-fel, ohne JTAG) und **debuggt es**: Haltepunkte, Schritte Zeile
  für Zeile, die Register mit 64 Bit, der Speicher; wenn `_start` mit `ret` zurückkehrt, zeigt das Protokoll `a0` und
  `a1`. Ein kleiner Stub von Asmonite bei `0x27800` lässt das Programm zwischen zwei Aufrufen des Boot-ROMs laufen und
  kommt bei einem Haltepunkt (`ebreak`) oder einer Ausnahme zurück; ein laufendes Programm lässt sich nicht anhalten.
  Debug targets: der Eintrag MangoPi MQ-Pro mit Test the connection. Beispiele `examples/d1/` (`sum_ram.asm`, `fibonacci_ram.asm`). Anleitung:
  `docs/de/d1.md`.
- **Der Reiter Serial** neben dem Ausgabefenster: ein kleines Terminal für den seriellen Port eines Boards. Nach F9 auf
  einem ESP32 zeigt es, was das Programm über UART0 schreibt, und schickt ihm eine eingegebene Zeile; Disconnect gibt
  den Port frei, Connect öffnet einen beliebigen seriellen Port von Hand (die Liste von Windows mit den Gerätenamen,
  die Baudrate; in der ini-Datei gemerkt), Reset gibt einen Puls auf RTS (EN) bei den ESP32-Boards. Hellgrau auf
  Schwarz. DTR und RTS bleiben aus, das Öffnen des Ports setzt den Chip also nicht zurück.

## 0.10.0 – 2026-11-06

### Neu
- **Xtensa: Assembler und Disassembler** (`.arch xtensa`), für den ESP32-S3 (Xtensa LX7; der ESP32, LX6, hat dieselben
  Befehle ohne `salt`, `saltu`): die Grundbefehle, die 16-Bit-Befehle der Code-Density-Option (von selbst, wenn die
  Operanden passen, wie bei GNU as: `add.n`, `l32i.n`, `movi.n`, `mov.n` …), Aufrufe mit Registerfenster (`call4/8/12`,
  `entry`, `retw`), Schleifen ohne Zusatzaufwand, Multiplikation und Division, Minimum und Maximum, die booleschen
  Register, Gleitkomma mit einfacher Genauigkeit, die Spezial- und Benutzerregister mit Namen (`rsr.ps a3` oder
  `rsr a3, ps`), Konstanten aus einem Literal-Pool mit `l32r` und `dd`. Gegen GNU as und objdump von Espressif geprüft
  (über eine Million Befehlswörter ohne Abweichung). Der Editor färbt die Zeilen nach `.arch xtensa`. Noch nicht: MAC16
  und die Vektorbefehle des ESP32-S3 (`ee.*`).
- **ESP32-S3 über seinen USB-JTAG, mit einem Kabel.** `.target esp32s3` (das RAM bei `0x40378000..0x403BFFFF`) und
  `.target esp32s3 flash`: F9/F7 setzen den Chip über seinen USB-Seriell-Port in den Download-Modus seines Boot-ROMs
  zurück (kein Knopf nötig, außer eine Firmware benutzt den USB-Anschluss selbst), halten Kern 0 dort an, laden das
  Programm und lassen es laufen oder halten bei `_start`; Schritte (auch in Aufrufe mit Registerfenster hinein und
  heraus), Haltepunkte, Step over, Pause, die Register `a0`..`a15`, `pc`, `ps`, `sar`, `windowbase`, `windowstart`,
  `lbeg`, `lend`, `lcount` (änderbar), der Speicher auch als Xtensa-Code. Mit `flash` kommt das Programm als Image des
  Boot-ROMs in den Flash und läuft dann im RAM, wie das Boot-ROM es dort hinlegt. Der Debugger schaltet bei jedem Halt
  die Watchdogs ab. Debug targets: *ESP32-S3* mit *Test the connection* und *Set up the USB JTAG*. Beispiele
  `examples/esp32s3/` (`rgb_ws2812_ram.asm`, `rgb_ws2812_flash.asm`: die RGB-LED an GPIO 48). Anleitung:
  `docs/de/esp32s3.md`.
- Website: die Xtensa-Befehlsreferenz (224 Befehle mit Kodierung, ESP32-S3 und ESP32) und das ARM-Assembler-Tutorial
  für den Raspberry Pi Pico 2 (nach dem ARM-ASM-Tutorial von Niklas Gürtler, mit seiner freundlichen Erlaubnis).

### Behoben
- ESP32-C3: Ein Debug-Zugriff, den das Debug-Modul mit „busy“ oder „failed“ beantwortete, ließ die Verbindung hängen
  (beides bleibt stehen, bis der Debugger es löscht); jetzt wird es gelöscht und wiederholt, ohne einen Schreibzugriff
  doppelt auszuführen.

## 0.9.3 – 2026-11-05

### Neu
- **STM32F103 („Blue Pill“, Cortex-M3) über die USB-Debug-Probe.** `.target stm32f103` (auch `bluepill`) mit
  `.arch thumb`: Der Assembler prüft das Programm (RAM 20 KB ab `0x20000000`, Flash ab `0x08000000` mit der
  Vektortabelle am Anfang). F7/F9 setzen den Kern zurück und halten ihn an, laden ein Programm ins RAM oder schreiben es
  über den Flash-Controller des Chips in den Flash (nur die Seiten zu 1 KB, die sich unterscheiden) und setzen den Chip
  zurück; Schritte, Haltepunkte (im RAM Software-Haltepunkte), Register, Speicher. Die Geräte-ID (`DBGMCU_IDCODE`
  0x410) wird geprüft: Auf einem anderen Chip wird nichts geschrieben. Ein Programm, das in `wfi` schläft, bleibt
  erreichbar (`DBGMCU_CR`). Debug targets: *STM32F103 (Blue Pill)* mit *Test the connection*. Anschluss: SWCLK, SWDIO
  und GND der Probe an die vier Pins des Boards, 3V3 bleibt frei. Beispiele `examples/stm32/` (`blink_ram.asm`,
  `blink_flash.asm`: die LED an PC13). Getestet mit einem originalen STM32F103C8.

### Behoben
- Raspberry Pi Pico und Pico 2 (Arm-Kerne): Ein Programm im RAM startete auf dem Kern so, wie ihn das Programm davor
  verlassen hatte: Dessen SysTick lief weiter, und eine Ausnahme, in der es steckte, ließ die Interrupts des neuen
  Programms nicht zu. Jetzt wird der Kern vor dem Start zurückgesetzt und angehalten (die Peripherie behält ihren
  Zustand). Ein Programm im RAM ohne Vektortabelle bekommt das Ende des RAM als Stackpointer (vorher stimmte er nur
  zufällig).
- Pico 2: Den Flash direkt nach einem Programm im RAM zu schreiben scheiterte („the boot ROM function ... stopped“), bis
  das Board einmal abgezogen war; jetzt wird der Chip vorher zurückgesetzt, damit sein Boot-ROM bereit ist.
- Thumb-Assembler: `str r0, [r1, #0]` (ein Offset von 0, auch aus einer `equ`-Konstanten), `mov r2, #0xab00ab00`
  (Konstanten ab `0x80000000`) und `ldreq r2, label` (`ldr` und `adr` mit Label im IT-Block) fanden keine Kodierung.

## 0.9.2 – 2026-11-05

### Behoben
- ESP32-C3, den Flash schreiben: Das Boot-ROM lehnte einen Block ab, mit „the boot ROM refuses command 03 (error 05)“,
  wenn im Programm das Byte `$C0` oder `$DB` vorkam (wie bei `rgb_ws2812_flash.asm`). Das serielle Protokoll muss diese
  beiden Bytes umschreiben, und Asmonite tat es nicht: Die Ersetzen-Funktion von Delphi hört beim ersten Null-Byte auf,
  und jedes Paket beginnt mit einem. Jetzt wird jedes Byte einzeln umgeschrieben. Ein gescheiterter Versuch ließ den
  Flash gelöscht zurück; das Board startete dann immer wieder neu („invalid header: 0xffffffff“).
- ESP32-C3: Nach dem Schreiben startete bei manchen Boards das Boot-ROM wieder im Download-Modus statt des Programms
  (`boot:0x4 (DOWNLOAD(USB/UART0/1))`). Jetzt setzt der RTC-Watchdog den Chip zurück, wie bei esptool; der Reset über
  RTS bleibt, wenn das Boot-ROM nicht antwortet.

## 0.9.1 – 2026-11-05

### Neu
- ESP32-C3-Beispiele für Boards mit einer RGB-LED WS2812 an GPIO 8: `rgb_ws2812_ram.asm` (im RAM) und
  `rgb_ws2812_flash.asm` (im Flash): Die LED ist abwechselnd rot, grün und blau, mit einer Zeile je Farbe auf dem
  USB-Seriell-Port. Die 24 Bit der Farbe misst der Zykluszähler des Kerns; die Programme stellen den Takt des Kerns von
  20 auf 40 MHz. Getestet an einem zweiten Board (zwei USB-C-Anschlüsse, einer am Chip, einer mit CH340 an UART0).

### Behoben
- ESP32-C3, Set up the USB JTAG: Der Knopf meldete „The setup did not work“, obwohl es geklappt hatte. Er prüfte den
  Wert, während die Schnittstelle noch neu startete; jetzt wartet er bis zu 10 Sekunden auf sie.
- Die Einrichtung ist einmal je Board nötig, nicht je USB-Anschluss: Windows erkennt das Board an seiner Seriennummer
  (der MAC-Adresse des Chips), an jedem Anschluss. Anleitung, Infotext in Debug targets und Meldungen sagten anderes.

## 0.9.0 – 2026-11-05

### Neu
- **ESP32-C3: debuggen und flashen mit einem USB-Kabel, ohne Debug-Probe und ohne OpenOCD.** Der Chip hat einen
  USB-Anschluss, der zugleich serieller Port und JTAG-Debugger ist; Asmonite steuert beides selbst (`EspUsbJtag`: das
  USB-JTAG-Protokoll des Chips, `EspRvDmi`: der RISC-V-Debug-Transport über JTAG; das Debug-Modul des Pico 2 wird
  wiederverwendet). `.target esp32c3` mit `.arch riscv32`: F7/F9 setzen den Chip zurück und halten ihn an, bevor die
  Firmware des Flash startet (diese Firmware sperrt den Speicherschutz, danach gehen Schreibzugriffe ins RAM ohne
  Fehlermeldung verloren), schalten Interrupts und Watchdogs ab, laden das Programm nach `0x40380000` und halten bei
  `_start`; Schritte, Haltepunkte, Register, Speicher.
  - **`.target esp32c3 flash`** schreibt das Programm als Image des Boot-ROM in den Flash, über den seriellen Port des
    Chips mit dem Protokoll seines Boot-ROM (`EspRomFlash`; der Port wird über die USB-Kennung 303A:1001 gefunden);
    danach lässt der Debugger das Boot-ROM es laden und hält bei `_start`. Ein Block, den das Boot-ROM ablehnt, wird
    noch einmal gesendet.
  - **Debug > Debug targets > ESP32-C3 > Set up the USB JTAG:** Windows gibt dem USB-JTAG den Treiber WinUSB, aber
    keine Geräteschnittstelle, also können Programme ihn nicht öffnen; der Knopf trägt sie ein (Administratorrechte,
    einmal je Board).
  - Beispiele `examples/esp32c3/` (`blink_ram.asm`, `blink_flash.asm`: die LEDs an GPIO 12 und 13 und Zeilen auf dem
    USB-Seriell-Port; `hello_uart_ram.asm`: UART0), Anleitung `docs/de/esp32c3.md`, Testfälle `target_esp32c3_*`.
    Getestet mit dem LuatOS ESP32C3-CORE.

### Behoben
- Assembler: Ein Name, der zugleich Label und `equ`-Konstante ist (Groß- und Kleinschreibung zählen nicht: `count:`
  und `COUNT equ 5`), ist jetzt ein Fehler. Vorher nahm der Wert der Konstanten den Platz des Labels ein: auf x86
  sprang `jmp count` ohne Meldung an die Adresse 5, auf RISC-V hieß es „the target is out of reach“.

## 0.8.0 – 2026-11-04

### Neu
- **Raspberry Pi Pico und Pico 2: assemblieren, flashen und debuggen, ohne OpenOCD.** Asmonite steuert eine CMSIS-DAP-Debug-Probe (die Raspberry Pi Debug Probe) selbst über USB an (`CmsisDap`): F7 lädt ein Programm ins RAM (`.imagebase 0x20000000`) oder **schreibt es in den Flash** (`.imagebase 0x10000000`: über die Funktionen des Boot-ROM, nur die Sektoren, die sich unterscheiden, zurückgelesen) und hält bei `_start`; Schritte, Step over, Run to cursor, Pause, Breakpoints, Register (änderbar), Stack mit Notizen, Speicher als **Bytes oder als Code** (der neue Umschalter *Bytes / Code*). *Project > Save as UF2 file (Raspberry Pi Pico)* schreibt die Datei für das BOOTSEL-Laufwerk mit der Familie des Chips. *Debug > Debug targets* hat die Einträge *Raspberry Pi Pico (RP2040)* und *Raspberry Pi Pico 2 (RP2350)*, jeder mit *Test the connection*. Die Anleitung `docs/de/riscv-pico2.md` erklärt es Schritt für Schritt.
- **Der Raspberry Pi Pico (RP2040, Cortex-M0+).** `.target pico` (auch `rp2040`) erlaubt nur die Befehle des ARMv6-M (von den 32-Bit-Befehlen `bl`, `msr`, `mrs`, die Barrieren; kein `cbz`, `cbnz`, `it`); adr/ldr mit einer Marke weiter unten nehmen zuerst die 16-Bit-Form. Der Debugger erreicht Kern 0 auf dem Multidrop-SWD-Bus (TARGETSEL) über den MEM-AP von ADIv5: 4 Hardware-Breakpoints im Flash, Software-Breakpoints (`bkpt`) im RAM, die die Speicheransicht nicht zeigt. Kerne, die nicht mehr antworten, holt der Rescue-Port des Chips zurück.
  - **`.boot2`** setzt den boot2-Block des Pico-SDK an den Anfang eines Flash-Programms (die Datei `boot2/boot2_w25q080.bin`, BSD-3-Clause, oder dieselben Bytes eingebaut); `.boot2 datei.bin` einen eigenen (252 Bytes, dann wird die CRC-32 angehängt, oder 256, dann wird sie geprüft).
- **Die RISC-V-Kerne des Pico 2 (Hazard3).** `.arch riscv32`: RV32I, M, A, Zicsr, Zifencei, die Pseudobefehle `li`, `la`, `mv`, `j`, `ret`, `call` ... und die Bit-Manipulations-Sätze Zba, Zbb, Zbs, Zbc, Zbkb. Der Debugger arbeitet über das Debug-Modul des Chips (`RvDebugModule`, `RvLink`): Register `x0`..`x31` und `pc`, 4 Hardware-Breakpoints. OpenOCD (Host und Port seines GDB-Servers) bleibt für diese Kerne als Ersatzweg; die Verbindung weckt den Debug-Port auf, den OpenOCD im Ruhezustand zurücklässt.
  - Der Disassembler `dis_riscv` liest auch die komprimierten Befehle (C, Zcb); gegen capstone geprüft (alle 16-Bit-Codes und 200.000 Zufallswörter: kein Unterschied, `tools/riscv_check.py`).
  - Editor: Syntaxfarben für `.arch riscv32`; F1-Hilfe `help\<Sprache>\riscv.md` (jeder Befehl, die Register, die Pseudobefehle, die Befehlsformen).
- **Die Arm-Kerne des Pico 2 (Cortex-M33).** `.arch thumb` mit `.target pico2`; F7/F9 debuggen über die USB-Probe (`CmCore`, `CmLink`, `CmFlash`): Register `R0`..`R12`, `SP`, `LR`, `PC`, `XPSR` und die Flags `N Z C V` (änderbar), 8 Hardware-Breakpoints, Step over bei `bl` und `blx`, die Speicheransicht zeigt Thumb-Code; der Stackzeiger kommt aus der Vektortabelle.
  - Der Chip läuft immer nur mit einer Sorte von Kernen. Läuft die andere Sorte, schreibt sie ein Flash-Programm in den Flash, und der Chip wird zurückgesetzt (das Boot-ROM startet die Kerne, für die das Programm ist); ein RAM-Programm bekommt eine Meldung, was zu tun ist. *Test the connection* sagt, welche Kerne laufen.
- **`.target pico`** (auch `rp2040`) und **`.target pico2`** (auch `rp2350`) sagen, für welches Board ein Programm ist: Die Ausgabe ist eine reine Binärdatei, und nach dem Assemblieren wird das Programm geprüft (Fehler mit der Zeile, F1 `err-target`): die `.arch`, `.imagebase` im RAM oder im Flash, und das Programm passt hinein; beim Pico 2 ein IMAGE_DEF-Block in den ersten 4 KB, dessen IMAGE_TYPE zu `.arch` passt, beim Pico der boot2-Block mit seiner CRC-32; ein Arm-Programm im Flash beginnt mit seiner Vektortabelle (Thumb-Bit). Ohne `.target` gibt `.arch thumb` mit `.format binary` eine Warnung. Bevor der Debugger etwas schreibt, liest er die Chip-ID und lehnt ein Programm für das andere Board mit dessen Namen ab.
- Beispiele: `examples/pico/` (`blink_ram.asm`, `blink_flash.asm`) und `examples/pico2/` (`blink_arm_ram.asm`, `blink_arm_flash.asm` für Arm; `blink_ram.asm`, `blink_flash.asm` für RISC-V; `stack_demo.asm`). Die Flash-Programme starten nach dem Aus- und Einschalten von selbst.
- Tests: `rvtest` (Assembler, Disassembler, UF2, Highlighter), `regedittest` (Cortex-M-Register), Fälle `riscv_*` und `target_*`, `anatest` (Hilfe); mit einem Board: `rvdbgtest` (31 Prüfungen, `usb` für den direkten Weg), `rvdmtest`, `rvflashtest`, `cmdbgtest` (37 Prüfungen am Pico 2, beide Umschaltungen der Kerne; `cmdbgtest pico` 38 Prüfungen am Pico).
- Die Debug-Ansichten (Register, Stack, Speicher) ändern ihre Zeilen an Ort und Stelle und flackern weniger.
- Dismonite: **PE-Dateien für das alte ARM** (Machine 0x01C0: der ARM-Befehlssatz aus der Zeit vor Thumb-2, wie ihn Windows CE benutzte) lassen sich öffnen und werden zerlegt: der Code ab dem Einsprung ist ARM (A32, der Zerleger der ARM-ELF-Dateien), der Export schreibt den Code als Bytes mit dem Befehl als Kommentar (als Befehle lässt er sich nicht übersetzen: Asmonite hat keinen A32-Assembler). Vorher zeigte so eine Datei gar keinen Code. Die Statuszeile sagt „old ARM (Windows CE): ... no Windows PC runs it“, und die Prüfung vor dem Start nennt das alte ARM ($1C0 / $1C2) als einen Typ, den kein Windows-PC ausführt. Die Seite `winarm.html` hat eine Tabelle der ARM-Dateitypen (ARM64, ARM32 mit Thumb-2, das alte ARM, ARM64EC/X) und sagt, was Asmonite und Dismonite damit tun. Fall in `anatest` (`pe_oldarm_example.exe`, mit fasmarm gemacht). Werkzeuge: `tools/pe_scan.c` (natives Programm, das die PE-Dateien eines Laufwerks erfasst) und `tools/pe_stats.py` (Statistik der Maschinentypen).

## 0.7.6 – 2026-10-30

### Neu
- Beispiele: `examples/windows_intel/if_x64.asm`, `examples/windows_arm/if_arm64.asm` und `if_arm32.asm` benutzen `if` / `else` mit mehreren Arten von Bedingungen; jedes endet mit dem Exit-Code 31 (die ARM-Beispiele sind auf einem echten Windows-on-ARM-Rechner gelaufen).
- Assembler, Thumb (`.arch thumb`): **`if` / `else` / `endif` und `do` ... `while`** gehen wie bei arm64 (`bne`, `blt` ..., `tst`, eine Zahl bekommt ihr `#`, keine Speicheroperanden). Fälle `thumb_*`, auch mit Blöcken aus 130 Befehlen.
- Assembler, arm64: **`if` / `else` / `endif` und `do` ... `while`** gehen in `.arch arm64`-Quelltext mit denselben Wörtern und Regeln (`if w0 == 5`, `if signed x1 < x2`, `if zero`, `if x3 & x4`, `do ... while not zero`, verschachtelt): die Sprünge sind `b.cond`, `if a & b` ist `tst`, eine Zahl bekommt ihr `#`; es gibt keine Speicheroperanden und kein `parity`; Thumb / ARM 32 bleibt ein Fehler. Fälle `a64_*`; der Editor färbt die Wörter in arm64-Quelltext. Noch nicht auf einem Gerät gelaufen.
- Assembler, x64: **`if` / `else` / `endif` und `do` ... `while`** gehen jetzt in `.arch x64`-Quelltext mit denselben Wörtern und Regeln wie bei i386 (`if rax == rbx`, `if signed eax < r8d`, `if zero`, `if eax & ebx`, `do ... while not zero`, verschachtelt); `func` und `call Name(args)` bleiben nur für i386, in ARM-Quelltext meldet `if` weiterhin einen Fehler. Die Sprünge vorwärts haben die lange Form (rel32). Fälle `x64_if_*`, `x64_do_while_*`, `x64_compare_default`, `x64_error_*`.

### Behoben
- Assembler, Thumb: ein **Sprung vorwärts, der in der kurzen Form nicht reicht, wird von selbst die lange Form** (ein weiterer Durchgang läuft); vorher musste der Befehl mit `.w` geschrieben werden („the branch does not reach its target in this form“).
- Assembler, x64 und Thumb: die Größen der Zeilen (aus Durchgang 1 für Durchgang 2 gemerkt) wurden mit der Quelltextzeile indiziert; bei erzeugten Zeilen (`if`, `else`, `do`, `func`) teilen sich mehrere Zeilen eine Quelltextzeile, und die Größen kamen durcheinander (Fehler „the instruction does not have the size it had in pass 1“). Jetzt zählt die erzeugte Zeile.

## 0.7.5 – 2026-10-28

### Neu
- Dismonite: **Export mit `call Name(Argumente)`** (Menü Datei, *Export with call Name(args)*, gespeichert in `Dismonite.ini`; `DismoniteC --calls`). In einem 32-Bit-Windows-Programm werden die `push`-Befehle direkt vor einem Aufruf als dessen Argumente geschrieben: `push 3` / `push eax` / `call near Fatal` / `add esp,8` wird zu `call cdecl Fatal(eax, 3)`. Welche Pushes zum Aufruf gehören: ein `add esp, 4*m` dahinter sagt cdecl und m Argumente; ein direkter Aufruf eines Labels, dessen Code mit `ret 4*n` endet, ist stdcall mit n Argumenten; ein `call [Import]` einer Windows-Funktion, die `help\<Sprache>\winapi.md` mit ihrer Parameterzahl kennt, ist stdcall mit so vielen. Alles andere bleibt (die Pushes könnten zu etwas anderem gehören); eine Folge von Pushes endet an einem Label, einer Kommentarzeile oder einem Push, der keine Zahl, kein Register, kein Label und kein Dword ist. Nur wo der Assembler dieselben Bytes macht: die Datei wird assembliert und verglichen, sonst ohne geschrieben (der Dialog sagt es). Es lässt sich zusammen mit dem `if`-Export benutzen. Im 32-Bit-dcc32 1.832 Aufrufe (die Datei kommt zusammen mit den 10.224 Ifs und Schleifen Byte für Byte zurück), in Dism.exe 542 von 4.091, in OpenWith.exe 205, in PkgMgr.exe 304. Unit `DisCallExport`; Fälle in `anatest` (`CallExportText`) und der Round Trip von `wste1.exe` mit `--if --calls`.

- Assembler, i386 (auch `.arch x86_real`): **ein Zeichen in Anführungszeichen ist in einem Befehl eine Zahl**: `mov al, '0'`, `cmp al, '9'`, `add al, "A"`, `push 'x'`, `mov eax, 'abcd'` (bis zu vier Zeichen, das erste im niedrigsten Byte, wie bei NASM); beide Anführungszeichen gehen, `db` behält seine Zeichenketten. Fall `char_immediate`.
- Assembler, i386: **`loop`, `loope`, `loopne`, `jecxz` und `jcxz` nehmen ein Label ohne `short`** (sie haben keine andere Form; ein Label außer Reichweite ist ein Fehler wie bei `short`). Fälle `loop_label`, `loop_label_far`.
- Beispiele: `examples/dos/tick.asm` zählt in `ebx` und gibt es jede Sekunde aus einem Haken im Zeitgeber-Interrupt 08h aus (der Handler sieht die Register der Zählschleife); `examples/windows_intel/tick_i386.asm` macht dasselbe für Windows mit einem zweiten Thread, der `ebx` mit `GetThreadContext` liest; `examples/func/func_fact.asm` ist die Fakultät.

### Behoben
- Assembler: **`call Name(0x1B)`**: eine hexadezimale Zahl, die auf `B` endet, als einziges Argument (`(0x1B)`, `(0xB)`) wurde als Zahl mit dem Binär-Suffix gelesen und abgelehnt (*unexpected token*).

## 0.7.4 – 2026-10-26

### Neu
- Dismonite: **`if` auf den Flags und `do ... while` im Listing und im Export** (dieselben Regeln wie in Asmonite seit 0.7.3). Ein bedingter Sprung vorwärts zu einem Label, das nur er benutzt, ohne ein `cmp` / `test` davor, aus dem sich eine Bedingung lesen lässt, wird als `if zero`, `if not below` ... geschrieben (`dec ecx` + `jnz` über den Block ist `if zero`); ein bedingter Sprung **zurück** zu einem Label, das nur er benutzt, ist eine Schleife: das Label wird zu `do`, der Sprung zu `while <Bedingung>` (cmp + `jnz` ist `while a != b`, `dec ecx` + `jnz` ist `while not zero`). Schleifen und Ifs verschachteln sich; das Listing zeigt `; do` am Label, `while ...` / `back to do` am Ende und rückt den Körper ein. Im 32-Bit-dcc32: 9.090 `if` (davon 1.035 auf den Flags) und 1.134 `do ... while`; der Export kommt Byte für Byte zurück. Der Export versucht zuerst alles, dann nur die Ifs mit Flags, dann nur die Ifs mit `cmp` / `test` und behält den ersten, der dieselben Bytes ergibt. `DismoniteC --if-dump <Vorsilbe>` speichert jeden Versuch als Datei (eine Testhilfe).

### Behoben
- Assembler, i386: **Sprünge ohne `short` / `near` beginnen kurz und werden nur dort lang, wo sie nicht reichen** (vorher begannen sie lang und wurden kurz, wo sie passten; so bleiben Sprünge lang, die nur zusammen kurz sein können: zwei Sprünge, die übereinander hinweggehen, eine Schleife und der Sprung darüber). Das Ergebnis ist die kürzeste Anordnung, wie sie ein Compiler hat. Fälle `jump_short_together`, `jump_short_back_edge`.

## 0.7.3 – 2026-10-26

### Neu
- Asmonite, i386: **`if` auf den Flags** und **`do ... while`**. `if zero`, `if not carry`, `if below or equal` und so weiter brauchen keinen Vergleich: die Flags des Befehls davor zählen, und nur der Sprung um den Block wird geschrieben (`dec ecx` / `if zero` ist ein `jnz` über den Block). Die Wörter: `zero` (`equal`), `carry`, `sign`, `overflow`, `parity`, `above` / `below` (ohne Vorzeichen), `less` / `greater` (mit Vorzeichen), `not` davor, `or equal` hinter den letzten vier. **`do` ... `while <Bedingung>`** lässt den Block einmal und dann so lange laufen, wie die Bedingung gilt: die Bedingung hat die Formen des `if` (ein Vergleich mit `signed` / `unsigned` oder `.compare`, `a & b`, ein Flag-Wort), und der Sprung zurück zum `do` ist die Bedingung selbst (`while not zero` ist `jnz`, `while signed eax < 10` ist `cmp` und `jl`). Das Label am `do` macht der Assembler (`asmogen_do<Zeile>s`). Schleifen und Ifs verschachteln sich; eine am falschen Ort geschlossene ist ein Fehler (`endif without if (the open block is the do in line 3, while is missing)`). `do` und `while` dürfen keine func, keinen Parameter und kein Lokales benennen; sie haben die Farbe der Syntax. Beispiel `examples/func/func_loop.asm`, Fälle `func_if_flag_*` und `func_do_*`; die Seite `if.html` hat Abschnitte zu beidem.
- Asmonite, i386: **`if a & b`** prüft Bits: `if eax & ebx` ist `test eax, ebx` und der Sprung um den Block, wenn in beiden kein Bit gesetzt ist, `if eax & ebx == 0` lässt den Block laufen, wenn keines gesetzt ist, `if eax & ebx != 0` ist dasselbe wie `if eax & ebx`. Ein Register, eine Zahl oder Speicher (`if byte [ebx] & 1`, `if al & 0x80`); `test` kennt nicht „Register gegen Speicher“, die Operanden werden vertauscht. Kein `signed` / `unsigned` dabei, dahinter nur `== 0` / `!= 0`. Fälle `func_if_test*.asm`; die Seite `if.html` hat einen Abschnitt dazu.- Dismonite: **Export mit `if` / `else` / `endif`** (Menü Datei, *Export with if / else / endif*, gemerkt in `Dismonite.ini`; `DismoniteC --if`). In einem 32-Bit-Windows-Programm wird ein `cmp` oder `test` mit dem bedingten Sprung dahinter, der vorwärts zu einem Label geht, das nur dieser Sprung benutzt, als `if a == b` ... `endif` geschrieben (der Sprung der Gegenbedingung: `jne` ist `==`, `jl` ist `if signed a >= b`, `jbe` ist `if unsigned a > b`, `test` + `jz` ist `if a & b`); ein `jmp` zu einem Label, das nur er benutzt, am Ende des Blocks ergibt `else`; Blöcke sind um zwei Leerzeichen eingerückt. Nur wo der Assembler dieselben Bytes daraus macht: die Datei wird assembliert und verglichen, sonst wird sie ohne geschrieben (der Dialog sagt es); Sprünge, die das Programm als `near` hat, bleiben wie sie sind. Im 32-Bit-dcc32 (19.663 bedingte Sprünge) werden 8.055 zu einem `if`, und die Datei kommt Byte für Byte zurück. Unit `DisIfExport`.
- Dismonite: **Export mit `if` / `else` / `endif`** (Menü Datei, *Export with if / else / endif*, gemerkt in `Dismonite.ini`; `DismoniteC --if`). In einem 32-Bit-Windows-Programm wird ein `cmp` oder `test` mit dem bedingten Sprung dahinter, der vorwärts zu einem Label geht, das nur dieser Sprung benutzt, als `if a == b` ... `endif` geschrieben (der Sprung der Gegenbedingung: `jne` ist `==`, `jl` ist `if signed a >= b`, `jbe` ist `if unsigned a > b`, `test` + `jz` ist `if a & b`); ein `jmp` zu einem Label, das nur er benutzt, am Ende des Blocks ergibt `else`; Blöcke sind um zwei Leerzeichen eingerückt. Nur wo der Assembler dieselben Bytes daraus macht: die Datei wird assembliert und verglichen, sonst wird sie ohne geschrieben (der Dialog sagt es); Sprünge, die das Programm als `near` hat, bleiben wie sie sind. Im 32-Bit-dcc32 (19.663 bedingte Sprünge) werden 8.055 zu einem `if`, und die Datei kommt Byte für Byte zurück. Unit `DisIfExport`.
- Dismonite: **if / else / endif im Listing** (Menü Analyze, *Show if / else / endif in the listing*, beim Start an, gemerkt in `Dismonite.ini`). Die Stellen, die der Export als `if` schreiben würde, bekommen einen Kommentar: die Zeile mit `cmp` / `test` sagt `if eax == 0x10`, der Sprung `if not: to endif` (oder `to else`), der Sprung am Ende des Then-Teils `then part done: to endif`, das Label `; else` / `; endif`; der Code eines Blocks steht je Ebene zwei Zeichen weiter rechts. Nur eine Ansicht: jeder Befehl behält seine Zeile, Adresse, Bytes und seinen Haltepunkt, der Debugger geht wie vorher; Listing, Suche und Export sind dieselben. Die Regel ist die des Exports (ein Label, das nur dieser Sprung benutzt, verschachtelte Blöcke), gefunden je Funktion; der Einsprungcode vor der ersten Funktion auch. Rund 1,4 s mehr für alle 338.000 Zeilen des 32-Bit-dcc32; wo ein Sprung im Export `near` geschrieben ist, zeigt das Listing den Block trotzdem.

### Geändert
- Dismonite, Debugger: die beiden Fenster unten haben die Plätze getauscht: links die Ausgabe des Programms, rechts der Speicher (feste Breite, genug für eine Zeile mit 16 Bytes und dem Text; der Trenner verschiebt sie).

### Geändert
- Assembler, i386: Sprünge ohne `short` / `near` werden in **Runden** gekürzt, bis sich nichts mehr ändert. Vorher fiel eine Entscheidung aus den Abständen des ersten Durchlaufs, ein Sprung über andere Sprünge, die erst kurz werden, blieb lang (`jmp x` über zwanzig `jne`: 5 statt 2 Bytes). Jetzt kommt das kürzeste Ergebnis heraus, wie bei anderen Assemblern; eine Datei mit vielen solchen Sprüngen wird einige Male assembliert (rund 16 s statt 7 s für die 231.000 Zeilen eines disassemblierten dcc32). Fall `jump_relax_rounds`.

### Behoben
- Assembler, i386, zwei Fehler bei Sprüngen, die automatisch kurz werden (`jmp x` / `jne x` ohne `short`): (1) ein Befehl, den asm_x86 an den anderen Kodierer abgibt (x87 wie `fld tword [label]` und andere), nahm die Adresse eines Labels weiter unten aus dem ersten Durchlauf, vor dem Kürzen der Sprünge: falsche Adresse im Code; (2) ein `jmp short` über Sprünge, die erst später kurz werden, bekam den Fehler „error with bdo“, obwohl er am Ende reicht. Gefunden beim Zurückbauen des 32-Bit-dcc32 aus seiner `if`-Form. Fälle `jump_short_fpu_label`, `jump_short_over_shortened`.

## 0.7.2 – 2026-10-23

### Geändert
- `conwatch.exe` (das Hilfsprogramm, das die Konsole des debuggten Programms spiegelt) hat jetzt eine Versionsinformation und importiert `AttachConsole` normal: weniger Fehlalarme von Virenscannern (Urteile von maschinellem Lernen).

## 0.7.1 – 2026-10-23

### Geändert
- Die ZIP-Datei enthält die Beispielprogramme (`.exe`) von `examples\windows_intel`, `windows_arm`, `func`, `x64`, `arm64` und `winarm` nicht mehr: Virenscanner meldeten winzige, von Hand gebaute Programme fälschlich. Die Quelltexte sind da; F9 in Asmonite baut die Programme. `examples\dos\HELLO.EXE` (für Dismonite) bleibt.

## 0.7.0 – 2026-10-23

### Neu
- Assembler: **Ausdrücke, `equ`, `$` und `$$`**. Überall, wo eine Zahl steht, rechnet der Assembler: `* / % + - << >> & ^ | ~` und Klammern, Zahlen als `0x1F`, `1Fh`, `101b`, `'A'`. `name equ ausdruck` definiert eine Konstante (auch hinter ihrer Verwendung), `$` ist die Adresse der Zeile, `$$` der Anfang des Abschnitts, und die **Differenz zweier Labels** ist eine Zahl: `mov ecx, end-start`, `len equ $-msg`. Der konstante Teil eines Speicheroperanden wird ebenfalls gerechnet (`[ebx+2*4]`). Eine Differenz von Labels braucht die Adressen, der Assembler läuft deshalb erneut, bis sie gleich bleiben. Gemacht von einem Durchlauf über den Quelltext (`src/cpu/asm_expr.pas`) vor dem Kern, für alle Architekturen; was kein Ausdruck ist, bleibt wie es war. Neu auch im Kern: eine Zahl hinter einem Label als Wert, `mov eax, table+4`, `push table-4`, `dd table+4` (Sprung und Aufruf: Fehler).
- Asmonite, i386: die Wörter der `func`- und `if`-Syntax (`func begin end var uses cdecl stdcall if else endif signed unsigned`) dürfen nicht der Name einer func, eines Parameters oder eines Lokalen sein (ein Fehler, wie es die Hilfe für Register, Befehle und Schlüsselwörter schon immer sagte); Labels und Datennamen sind nicht betroffen. Fälle `func_error_keyword_*`.
- Asmonite, i386: **`if` / `else` / `endif`** mit direktem Vergleich: `if ebx == [0x04+eax]` ... `endif` ist `cmp` und der Sprung der Gegenbedingung um den Block (ohne eigenes Label); `else` geht, Ifs lassen sich verschachteln, es gilt überall im i386-Code und in einer func (ihre Namen gehen im Vergleich). Ein Vergleich, keine Ausdrücke: `==`, `!=`, `<`, `<=`, `>`, `>=`; die vier Ordnungsvergleiche sagen **`signed`** oder **`unsigned`** (`if unsigned eax < ebx` ist `jae`, `if signed eax < ebx` ist `jge`), ohne das Wort ist es ein Fehler, außer davor steht **`.compare signed`** / **`.compare unsigned`** (für alle Ifs dahinter, bis zum nächsten `.compare`; `.compare none` nimmt es zurück; ein Wort in der `if`-Zeile gilt immer). Der Debugger führt die `if`-Zeile (`cmp` und Sprung) als einen Schritt aus. Beispiel `examples/func/func_if.asm`, Fälle `func_if_*.asm`.
- Asmonite und Dismonite, Debugger: **Register und Flags ändern** beim angehaltenen Programm, für x86 (Windows, DOS), x64, ARM / Thumb und ARM64. **Doppelklick** (oder **F2**, **Enter**) auf ein Register öffnet einen kleinen Dialog mit seinem Wert; ein **Flag** (CF, ZF, N, Z, T ...) schaltet der Doppelklick oder **Leertaste** um; das Kontextmenü hat *Change value...*, *Toggle flag*, *Set to 0* und *Copy value*. Der Wert ist hex (`1F`, `0x1F`, `$1F`, `1Fh`), dezimal mit `#` (`#31`), ein Zeichen (`'A'`) oder ein Ausdruck aus Werten und Registernamen mit `+` und `-` (`esp+8`, `r0-#1`); ein Wert, der nicht ins Register passt, oder ein unbekanntes Wort bleibt mit der Begründung im Dialog. Ein neues `EIP` / `RIP` / `PC` versetzt das Programm: Editor und Ansicht zeigen die neue Stelle wie einen Halt („nächste Anweisung setzen“). In Dismonite führt ein Doppelklick auf ein Register, das ins Programm zeigt, weiter dorthin; ändern mit F2 oder über das Menü. Die Änderungen gehen an das Programm, wenn es weiterläuft (Windows: `SetThreadContext`; die Debug-Server und QEMU: das `G`-Paket). Beide Programme benutzen denselben Code (`DbgRegEdit`, `DbgRegDlg`).
- Dismonite: **Argumente und Lokale in mehr Funktionen gefunden**, und mehr dazu gesagt. Die Funktionen der Microsoft-Compiler, die mit `mov edi,edi` beginnen (Hotpatch-Präfix), 16-Bit-Funktionen (`push bp / mov bp,sp`: die Argumente sind 2-Byte-Plätze ab `[bp+4]`, ab `[bp+6]` in einer Far-Funktion, die mit `retf` endet; `[word 0xFE7E+bp]` ist eine negative Verschiebung) und Funktionen, die nur angesprungen werden (ein Label am `push ebp`), bekommen jetzt die Hinweise `arg1` / `loc1`. Lokale, die sich überlappen (ein `byte [ebp-7]` im `dword [ebp-8]`), sind eine Variable (`loc2+1`), die Rahmengröße wird aus `sub esp,N` / `add esp,-N` / `push ecx` gelesen. Die Zusammenfassung am `push ebp` sagt mehr: `stdcall, 2 args, 3 locals, frame 0x10`; die Konvention (`stdcall`, `cdecl`, `pascal`, `far`, `register`) kommt aus `ret N` und den Argumenten, **Register als Argumente** (`eax`, `edx`, `ecx`, gelesen bevor sie geschrieben werden: Delphi `register`, fastcall, thiscall) werden genannt (`register, regs eax edx ecx, 1 stack args, ...`), und das Sichern eines solchen Registers in einem Lokalen steht als `loc2 = ecx`. Nur Kommentare: der Export ergibt dieselben Bytes. Im 32-Bit-Notepad hatten vorher 0 von 6894 `[ebp+x]`-Operanden einen Hinweis, jetzt 94 %; in einem DOS-Compiler (TPC) 0 von 1060, jetzt 71 %.

## 0.6.0 – 2026-10-22

### Neu
- Asmonite: **neue Fensteraufteilung**: Register, Stack und Memory stehen untereinander in einer Spalte rechts über die ganze Höhe (nur beim Debuggen; jeder Block ist im Menü View schaltbar, die Spalte entfällt, wenn alle drei aus sind), links Code und Ausgabefenster. Größen und Blöcke stehen in `Asmonite.ini`. Memory zeigt in einer schmalen Spalte 8 Bytes je Zeile, in einer breiten 16, und den Stack (`esp`), solange nichts eingegeben ist.
- Asmonite, Debugger: **Step Over auf `call Name(args)` und `call [printf](args)`** führt die ganze Zeile in einem Schritt aus (den Aufruf und das Aufräumen dahinter) und geht nicht in eine func hinein, wenn die Zeile Argumente ablegt.
- Asmonite: **die Konvention eines Imports** in `call [name](...)`: die `.import`-Zeile sagt sie für ihre Namen: `.import msvcrt.dll cdecl printf`, dann räumt `call [printf](fmt, 42)` den Stack auf (`add esp, 8`); ohne das Wort ist ein Import stdcall. Bei einer DLL der C-Laufzeit (`msvcrt.dll`, `ucrtbase.dll`, `api-ms-win-crt-*`) ist das Wort Pflicht: ein Aufruf mit Argumenten ohne es ist ein Fehler. `call cdecl [name](...)` oder `call stdcall [name](...)` entscheidet für einen Aufruf. Beispiel `examples/func/func_printf.asm`.
- Dismonite, DOS-Programme (MZ): **Konstanten und Displacements im Code** lassen sich als Offsets bezeichnen, mit denselben Tasten wie die Wörter einer Tabelle: auf einem Befehl **L** (Offset auf Code), **Umschalt+L** (Offset auf Daten), **X** (eine Zahl). Das Label des Ziels steht im Operanden (`mov bx,C0000_9C2A`, `jmp [cs: word L0000_085A+bx]`), der Code hinter einem Code-Offset ist sicher und wird verfolgt, und der Export schreibt das Label ebenfalls (vom Assembler geprüft, Bytes identisch). Daten, die eine Konstante nennt, liegen im **Datensegment**: dem Paragraphen, den DS enthält, aus dem Einstiegscode erkannt (`mov ax,0x10D0 / mov ds,ax`) oder in DOS > Data segment gesetzt (als `dataseg` gespeichert); mit `cs:` liegt das Ziel im Codesegment. Ein Befehl mit zwei Feldern: das Displacement (außer es ist ein einfaches `[0x1788]`), sonst die Konstante. Gespeichert als `ref <Offset> operand <Rolle>`; Entf nimmt zuerst die Entscheidung des Befehls zurück.
- Dismonite: **die Markierungen des Benutzers im Gutter**: ein Balken vor der Adresse (blau: ein Eintrag, grün: der Anfang eines Laufs, lila: eine Entscheidung über eine Adresse). Die Maus im Gutter sagt, was die Markierung ist (Art und Größe, der Lauf mit seinen Grenzen, die Entscheidung und ihr Ziel, dein Name für das Label) und was Entf zurücknimmt.
- Dismonite: **strenge Markierungen über mehrere Bytes** (was du eingibst; das Lesen einer .dmon-Datei wird nicht geprüft): Ein Word, Dword oder Qword wird abgelehnt (mit Ton und dem Grund in der Statuszeile), wenn ein Label darin läge (ein Label am ersten Byte ist in Ordnung), wenn eine andere Markierung von dir überdeckt würde oder wenn ein Feld des Dateiformats darin liegt; ascii und UTF-16 enden vor dem nächsten Label oder der nächsten Markierung von dir. Der Eintrag, den du neu markierst, darf ersetzt werden; ein Lauf aus B/W/D/Q endet vor einer Markierung von dir, die er nicht selbst macht.
- Dismonite: Ein Klick in den Gutter (die Spalte mit den Adressen) setzt einen Haltepunkt auf diesen Eintrag oder nimmt ihn weg, wie F5.
- Dismonite, DOS-Programme (MZ): **manuelles Markieren**. Menü DOS > Manual marking (im `.dmon` als `manual` gespeichert): Das Programm markiert den Code, der *sicher* ist, selbst - alles, wohin Ablauf, Calls und Jumps vom Einstiegspunkt, von deinem markierten Code und von den Wörtern führen, die du als Offset auf Code bezeichnet hast - und macht das nach jeder Entscheidung von dir neu (was du zurücknimmst, geht wieder weg). Sonst wird nichts analysiert; was übrig bleibt (was nur über eine Tabelle oder einen indirekten Sprung erreichbar ist, Daten, der Rest), ist deine Sache: **Strg+F5** / **Strg+Umschalt+F5** springen zur nächsten / vorigen Stelle, an der du entscheiden musst, die Statusleiste zählt sie. **C** markiert Code (seine Calls und Jumps werden sofort verfolgt), **L** / **Umschalt+L** / **X** sagen, dass das Wort am Cursor ein Offset auf Code / auf Daten / eine Zahl ist (gespeichert als `ref <Offset> word code|data|number`; ein Byte wird dabei zum Wort); die Statuszeile sagt sofort, was am Ziel steht: Anfang eines Befehls, Anfang von Daten, noch nicht markiert, mitten in einem Befehl oder Datenfeld (dort kann kein Label stehen), außerhalb des Segments oder der Datei. **Entf** nimmt zuerst die Entscheidung zurück, dann die Markierung des Wortes. Was die Befehle des Analyze-Menüs markieren (Tabellen, Strings), sind nur Vorschläge mit orangen Bytes, bis du sie annimmst (**Strg+Y** den am Cursor, DOS > Accept all suggestions). DismoniteC folgt dem sicheren Code eines Dokuments mit `manual` genauso.
- Dismonite: **Strg+F4** / **Strg+Umschalt+F4** (Menü Go) springen zur nächsten / vorigen Stelle, an der Code und Daten wechseln: vorwärts zum Anfang des nächsten Abschnitts aus Einträgen der anderen Art (Code: Befehle, Daten: alles andere), rückwärts zum Anfang des Abschnitts, in dem du stehst, oder - an dessen Anfang - des Abschnitts davor.
- Dismonite: **Entf** nimmt die Markierung des Eintrags unter dem Cursor zurück (Menü Data > Unmark this item): die eigene oder die der Analyse; die Bytes sind wieder einzelne, unmarkierte Bytes, Namen und Kommentare bleiben. Ein Lauf, zu dem der Eintrag gehört, wird aufgelöst, seine übrigen Einträge bleiben. Der Cursor geht danach zum nächsten Eintrag, so dass sich mehrere Markierungen hintereinander zurücknehmen lassen (nach dem Zurücknehmen einer Entscheidung über eine Adresse bleibt er stehen: das nächste Entf nimmt die Markierung des Wortes zurück).
- Dismonite, DOS-Programme (MZ): Die Analyse weiß, wie ein DOS-Programm endet. Nach `mov ah,4Ch` / `int 21h` (auch AH = 00 und 31,
  `int 20h`, `int 27h`) folgt kein Code mehr - was dort steht (die Optionstabelle eines Compilers), wird nicht mehr als Code
  gelesen, auch nicht vom Code-Lauf des Benutzers (C). `mov dx,offset` / `mov ax,25xxh` / `int 21h` (Interruptvektor setzen)
  macht den Handler zu Code.
- Dismonite, DOS-Programme: Zeigertabellen. Folgen von mindestens 6 Wörtern (Sätze von 2 bis 6 Bytes: ein Zeiger und ein Schlüssel oder
  Flags) in den Bytes, die kein Code sind, deren Werte auf den Anfang von Code im selben Segment zeigen - 90 % davon hinter einem
  `ret`/`jmp` oder bei bekanntem Code, und sauber decodierbar -, werden zu Wort-Einträgen, die Adressen sind: `dw J0000_01F5`, mit Labels
  an den Zielen, deren Code verfolgt wird; 4 und 5 Einträge, wenn alle auf bekannten Code hinter einem `ret`/`jmp` zeigen. Auch von dir
  markierte Wörter (W), die auf so eine Stelle zeigen, sind Adressen (eine Tabelle mit 3 Einträgen). Tabellen, die der Code benutzt
  (`jmp [cs: 0x2355+bx]`, auch `call`), findet die Analyse an diesem Befehl: ihre Wörter sind Adressen, solange sie auf sauber decodierbaren
  Code zeigen und nahe bei den anderen bleiben (Case-Labels); ungenutzte Plätze (0) davor oder dazwischen werden übersprungen. Teil von „Analysieren“ (Menüpunkt
  *Find tables of pointers to code (DOS)*) und „Neu analysieren“ (nicht gespeichert). TPC.EXE: Von den Code-Labels seiner Quelle sind
  nach der automatischen Analyse 85 % (vorher 37 %) Code, mit einer `.dmon` des Benutzers 90 % (vorher 63 %). Der Export schreibt `dw Label`.
- Asmonite: `dw Label` in einem Quelltext mit `segment`-Zeilen (MZ) ist der Offset des Labels in seinem Segment (vorher: der Dateioffset).
- Asmonite: `call Name(Arg, ...)` (auch `call cdecl name(...)`, `call [Import](...)`) legt die Argumente von rechts nach links ab,
  ruft auf und räumt bei `cdecl` auf; eine `func` gibt Konvention und Argumentzahl vor. Argumente: Register, Zahl, Label,
  Parameter oder Local (Byte/Word aufgefüllt, Feld = Adresse), `&local`, `[ebx+4]`; für eine Adresse oder ein Byte/Word dient das
  erste von eax/ecx/edx, das die Argumentliste nicht nennt, als Register. Beispiele `examples/func/func_call*.asm`.
- Dismonite: Solange das Programm angehalten ist (Win32), zeigt die Maus über einem `[ebp+x]`-Operanden (oder seinem
  Kommentar `arg1` / `loc1`) den Wert: `loc1: dword 0x0000000A  10`; die Größe kommt vom Größenwort oder vom Register, ein
  Operand mit Indexregister zeigt die ersten Bytes des Feldes; ein Zeiger auf einen Text ergänzt `-> "Text"`.
- Asmonite: Solange das Programm angehalten ist, zeigt die Maus über einem Wort im Quelltext den Wert: Parameter und
  Locals einer `func` (mit Größe und Feldgröße) und Labels von Daten (`db`, `dw`, `dd`, `resb` ...): `byte`, `word`, `dword`
  (hex und dezimal), `qword`, Text als `pchar "..."`, sonst die ersten Bytes; ein Dword, das auf einen Text zeigt, ergänzt `-> "Text"`.
- Asmonite: Im Debugger sind `begin` und `end` einer `func` je ein Schritt (Einzelschritt und Prozedurschritt führen den
  ganzen Prolog bzw. Epilog aus); allgemein sind aufeinanderfolgende Befehle einer Quellzeile ein Schritt.
- Dismonite: In einer Funktion, die mit `push ebp / mov ebp,esp` beginnt (ein Call-Label, Ende beim nächsten), benennt der
  Kommentar eines Befehls mit `[ebp+x]` den Platz: `arg1` ([ebp+8], [ebp+0xC] = `arg2` ...) und `loc1`, `loc2` ...
  (die benutzten Plätze unter ebp, der nächste zuerst; `[]` wenn ein Indexregister dazukommt); der erste Befehl zeigt die
  Zusammenfassung (`2 args, 3 locals`, die Argumente auch aus `ret N`). Nur Kommentare: der Export ergibt dieselben Bytes.
- Asmonite: `func Name(Parameter) [cdecl|stdcall] [uses Register]` / `var` / `begin` / `end` schreibt den Stackframe:
  Namen für Parameter (`[ebp+8]` ...) und Lokale (`[ebp-4]`, Felder `buf:16`), Prolog und Epilog (auch bei jedem `ret`),
  `uses` rettet Register. Nur `.arch i386`; Beispiele in `examples/func/`, Hilfethema `func`.
- Dismonite: Ein Code-Lauf (C) übernimmt einzelne Bytes, die der Benutzer als Byte markiert hat (vorher hielt ein solches Byte den
  Lauf sofort an); andere Elemente des Benutzers (Word, Dword, Text ...) und die Dateistrukturen halten ihn weiter an.
- Dismonite: Alt+E exportiert die `.asm`, Alt+X beendet das Programm.
- Dismonite: die Taste **F** folgt dem Label der Zeile zu seinem Ziel (wie Strg+Klick; Alt+Links kommt zurück).
- Dismonite: Suchen (Strg+F) schlägt den Namen des Labels vor, wenn der Cursor auf einer Labelzeile oder auf einem Befehl mit Label (`call C00401234`) steht.
- Dismonite: Beim Öffnen läuft jetzt die Standardanalyse automatisch (nach dem Anwenden der `.dmon`; Fortschrittsfenster mit
  Abbrechen): Entry Point und Exporte, Relokationen, Konstanten, Call- und Sprungziele bis nichts Neues kommt, Strings.
  Menü Analyze: **Re-analyze** (die Marken der Analyse neu, die des Benutzers bleiben), **Analyze automatically when a file
  is opened** (an) und **Follow new targets automatically after marking code** (aus; die Rückfrage nach einem Code-Lauf hat
  einen Knopf „Yes to All“). Die `.dmon` merkt sich auch die Stelle des Cursors (`cursor <Offset>`).
- Dismonite: Die Analyse ist dort viel schneller, wo Startpunkte scheitern: asmoc.exe 40 s -> 5 s (ein gescheiterter
  Relokationspunkt verfolgt die wartenden Stränge nicht mehr weiter), und die Zeilenzahlen des Dokuments werden einmal je
  Analyseschritt gezählt.
- Dismonite: Ein Befehl, dessen letzter Operand eine Zahl von 0x20 bis 0x7E ist, zeigt das Zeichen im Kommentar
  (`cmp al,0x41   ; 'A'`); nicht bei `add`/`sub` des Stackpointers, Schiebebefehlen, `ret`, `int`, `in`/`out`.
- Dismonite: Ist das Programm im Debugger angehalten, zeigt die Maus über einem Namen (Label im Code oder seine
  eigene Zeile) den Wert der Variablen in einer Zeile: `byte`, `word`, `dword` (hex und dezimal), `qword`,
  `pchar "..."`, `pwchar "..."`, nicht markierte Daten als 8 Bytes; ein Zeiger auf einen String des Programms
  ergänzt `-> "Text"`.
- Dismonite: Code, der ein Label auf einen ASCII- oder UTF-16-String benutzt, zeigt dessen ersten 20 Zeichen im
  Kommentar (`push msg   ; "Hello, this is a lon..."`); auch bei ARM-Literalen und bei einer Konstante, die die
  Adresse eines Strings ist.
- Dismonite: die automatischen Sprunglabels (`J00401234:`, meist lokale Sprünge) stehen im Fenster und im
  `.asm`-Export zwei Zeichen links vom Code (zwei Leerzeichen vor dem Label); so fallen Calls und Datenlabels auf.
- Dismonite: Speicher ohne Dateibytes (`.bss`, das Ende einer Section mit größerer virtueller Größe) folgt der Datei als
  Nullbytes: Er hat Adressen, Labels `V00xxxxxx`, Zeilen `resb 8` / `resd 1` (eine je Abschnitt zwischen zwei Labels)
  und die Typen B, W, D, Q gehen dort. Namen und Typen des Anwenders stehen wie überall nach Offset im `.dmon`.
  Der `.asm`-Export schreibt ihn als `section 0x... nobits` mit `resb`-Zeilen und Labels, der Export ergibt also
  weiter die Datei; Statuszeile und die Prüfung der `.dmon`-Datei zählen die Bytes der Datei.
- Asmonite: `section <rva> nobits` (flache Quelltexte): `resb` darin schreibt am Ende der Ausgabe keine Dateibytes;
  seine Labels haben Adressen.
- Asmonite: `resb`, `resw`, `resd`, `resq` reservieren nicht initialisierte Daten. Mit `.format pe` dürfen sie am
  Ende einer Section stehen (`.code`, `.data`); der Platz steht nicht in der Datei (VirtualSize größer als
  RawSize), die Labels davor sind normale Adressen. Ohne `.format pe` schreiben sie Nullbytes.
- Dismonite: Nach einem Code-Lauf (C) können die Calls und Sprünge darin zu Stellen führen, die noch kein Code
  sind. Dismonite fragt, ob dem Code von dort aus gefolgt werden soll (dieselbe Analyse wie „Follow code from the
  entry point“, mit den C- und J-Labels als Startpunkten); auch im Menü Analyze > Follow code from the call and
  jump targets.
- Dismonite: Die Tasten C, B, W, D, Q markieren einen **Lauf**: Code ab dem Cursor, Befehl für Befehl (keinem
  Sprung wird gefolgt), bis `ret`, einem unbedingten `jmp`, einem Befehl, der nicht decodiert (oder den kein
  Compiler schreibt) oder einem Element des Dateiformats; bei B, W, D, Q Byte, Word, Dword oder Qword bis zum
  nächsten Label. Die `.dmon`-Datei bekommt dafür eine Zeile `run <Adresse> <Art> [<Ende>]`; beim Lesen werden
  die Elemente neu gebildet. Umschalt+C, B, W, D, Q setzen nur ein Element (eine Zeile `item`, wie früher C, B,
  W, D, Q). Ein von Hand gesetztes Element in einem Lauf löst den Lauf auf: seine Elemente werden einzeln
  gespeichert.
- Dismonite decodiert 32-Bit-Code mit dem x64-Decoder in seinem 32-Bit-Modus: `cmovcc`, `bswap`, `cpuid`,
  `rdtsc`, x87, MMX und SSE sind jetzt Befehle (vorher Bytes). notepad_32bit.exe: 3.705 -> 40.264 Befehle
  gefunden.
- Asmonite (`.arch i386`) assembliert `cmovcc`, `bswap`, `cpuid`, `rdtsc`, `ud2`, `pause`, `int3`, `fwait`,
  `nop dword [eax]`, `lock cmpxchg`, `xadd`, x87, MMX und SSE; `add eax,12` nimmt die kurze Form `83 C0 0C`.

### Geändert
- Dismonite: Die automatischen Labelnamen zeigen, was auf ein Label zeigt: `C00401234` (ein `call`),
  `J00401234` (ein Sprung: `jmp`, `jcc`, Einträge einer Sprungtabelle), `L00401234` (nur Daten: Zeiger,
  Speicheroperanden, Konstanten). Ein Aufruf geht vor einem Sprung. Die Adresse bleibt, der Buchstabe kann
  sich ändern, wenn die Analyse mehr findet. Der Export (`.asm`) benutzt dieselben Namen.

### Behoben
- Dismonite: Beim Markieren von ascii (oder Word, Dword, Qword) konnte ein Label überdeckt werden, das ein Zeiger hinter dem Eintrag erzeugte: Die Labels der Einträge in einem Fenster von 4 KB wurden vor der Prüfung freigegeben. Die Regeln sehen die Labels jetzt so, wie sie sind.
- Dismonite, DOS-Programme: Die Analyse folgte einem `call` oder `jmp`, der im Segment überläuft, zur falschen Stelle (`call -0x85E7` wird als `+0x7A19` geschrieben; das Label zeigte das richtige Ziel, der Code wurde 64 KB weiter markiert). Sie folgt jetzt dem richtigen Ziel, auch einem Sprung vorwärts um mehr als 32 KB (als negative Zahl geschrieben). Manuelles Markieren: ein bis drei Nops (0x90) zwischen anderen Dingen sind keine Stelle, an der du entscheiden musst.
- Disassembler (16-Bit-Code): `ror` mit Zähler 1 oder CL (`D0`..`D3 /1`) wurde als `ror ax,imm8` gelesen und nahm ein Byte zu viel: `D1 C8` wurde `ror ax,0xAB`, der Befehl danach ging verloren. Gefunden beim Vergleich von TPC.EXE mit dem TASM-Listing.
- Asmonite (i386): Eine als 0x80..0xFF geschriebene Zahl wurde als vorzeichenerweitertes Byte codiert, das ist ein anderer
  Wert: `push 0x80` wurde `6A 80` (= 0xFFFFFF80), `cmp ebx,0xC8` wurde `83 FB C8`, ebenso `or edx,0x80`, `sub ecx,0x90`,
  `imul eax,ebx,0x80`. Jetzt gilt der 32-Bit- (bzw. 16-Bit-)Wert (`push 0x80` = `68 80 00 00 00`); die kurzen Formen bleiben
  für 0..127 und die negativen Bytes. (Aufgefallen bei `CreateFileA(..., 0x80, ...)`: Flags 0xFFFFFF80.)
- Dismonite / der Disassembler: Das Byte von `83 /x`, `6A` und `6B` ist eine vorzeichenerweiterte Zahl und wird jetzt so
  geschrieben: `and cx,0xFFFE`, `push 0xFFFFFF80`, `cmp eax,0xFFFFFFFF` (vorher `and cx,0xFE`, das der Assembler als 0x00FE
  liest, also ein anderer Wert). Der Assembler führt so eine Zahl (auch `-2`) wieder auf die kurze Form zurück, Exporte ergeben
  also dieselben Bytes.

## 0.5.0 – 2026-10-14

### Neu
- **F1-Hilfe für x64-Code** (Deutsch und Englisch): `movsxd`, `cdqe`/`cqo`, `syscall`/`sysret` und zwei Übersichten,
  die von selbst erscheinen: `rip` (Adressieren relativ zu rip, `[rip+...]` oder `[rel label]`) und `x64` (der
  64-Bit-Modus in Kürze: Register und ihre Teile, REX, was weggefallen ist, die Aufrufkonventionen von Windows und
  Linux) bei jedem Befehl mit einem 64-Bit-Register.
- **F1-Hilfe für weitere x86-Befehle** (Deutsch und Englisch): `cmovcc`, `bswap`, `xadd`, `cmpxchg`/`cmpxchg8b`,
  `cpuid`, `rdtsc`, `pause`, `ud2`, `int3`, `sysenter`/`sysexit`, `popcnt`/`lzcnt`/`tzcnt` (86 -> 97 Abschnitte).
- Beispiel `window_i386.asm` (i386, `.format pe gui`): ein Fenster mit Menüleiste (File > Exit), einer Eingabezeile,
  einem Button und einem Label; der Button zeigt den Text der Eingabezeile auf dem Label. Fensterklasse,
  Fensterprozedur (WM_CREATE, WM_COMMAND, WM_DESTROY) und Nachrichtenschleife sind ausgeschrieben und
  kommentiert. Test: `guitest.ps1` (in `run_tests.bat`) benutzt es auf einem eigenen Desktop: Steuerelemente,
  Button, File > Exit.
- **Fenster "Debug targets"** (Debug > Debug targets..., in Asmonite und Dismonite): alle Ziele an einer Stelle -
  Windows i386, Windows x64, Windows on ARM (ARM32 und ARM64), DOS (QEMU), ARM Linux (QEMU). Beim Öffnen ist der
  Eintrag gewählt, der zum Programm passt (aus seinem `.arch`, in Dismonite aus der Datei); die Liste zeigt, wie
  jedes Ziel erreicht wird (dieser Computer, Host und Port, ssh). Es ersetzt die Menüpunkte "Debug target Windows
  on ARM", "Debug target x64 computer" und "DOS Boot Floppy" (die Boot-Diskette wählt man dort). Die
  Einstellungen in den ini-Dateien bleiben. Test: `targettest.ps1` (in `run_tests.bat`, beide Programme,
  eigener Desktop).
- Asmonite schreibt beim Start einer Debug-Sitzung die Zeile `Target: ...` (z. B. `Target: Windows x64 on this
  computer`) in das Ausgabefenster; Help > Asmonite on Discord öffnet in beiden Programmen den Discord-Kanal.
- Beispiel `window_x64.asm`: dasselbe Fenster für x64 (Shadow Space, rcx/rdx/r8/r9, WNDCLASS mit 72 Bytes), gleich getestet.
- Die Beispiele sind nach System sortiert: `examples/dos`, `examples/windows_intel`, `examples/windows_arm` (vorher `examples/asmonite`).
- F1-Hilfe für ARM64 (`help/de|en/a64.md`): die häufigen Befehle, Register (xzr, sp, lr, x18) und Bedingungen.
- Beispiele `messagebox_i386.asm`, `messagebox_x64.asm`, `messagebox_arm32.asm`, `messagebox_arm64.asm` in
  `examples/windows_intel` und `examples/windows_arm`: eine Message Box (`.format pe gui`, Importe aus zwei DLLs), um zu sehen, wo die Fenster
  eines debuggten Programms erscheinen (auf dem Desktop des Rechners, auf dem das Programm läuft).
- **x64-Programme auf einem anderen Rechner**: Asmonite und Dismonite debuggen x64-Programme an
  `asmodbgx64.exe --listen` auf einem Intel/AMD-Windows-Rechner (z. B. von einem Windows-on-ARM-Rechner aus):
  Debug > Debug target x64 computer... (dieser Rechner oder direkt: Host, Port, Code; „Search LAN“ und „Test
  connection“ wie bei ARM). Das Programm wird über die Verbindung kopiert und dort gestartet, seine Ausgabe
  kommt zurück. Die Firewall dieses Rechners muss TCP-Port 23457 durchlassen. Test: `x64dbgtest` (Remote-Teil
  auf diesem Rechner).
- **Das Ziel Windows on ARM wählt sich selbst**: auf einem Windows-on-ARM-Rechner nehmen Asmonite und Dismonite
  „Dieser Computer“ (asmodbg.exe als Kindprozess, ohne ssh, ohne Code), wenn noch kein Ziel gewählt war, und auch,
  wenn der Host in den Einstellungen dieser Rechner ist. Antwortet der gewählte Server nicht, sagen sie warum und
  bieten an, direkt hier zu debuggen und das zu merken.
- **`.format pe` mit `.arch thumb`**: Windows-Programme für ARM 32 Bit (PE32, Machine ARMNT, Einsprungpunkt mit
  Thumb-Bit); `.format pe` geht damit für alle vier Arten: i386, x64, thumb und arm64. Code, Daten und Importe
  liegen in einem Abschnitt, der Code ist pc-relativ.
- Thumb: `adr rd, label` und `ldr rt, label` (der Abstand zum pc wird ausgerechnet, schmale oder breite Form);
  `rva label + zahl`; ein Label vor `db`/`dw`/`dd` braucht keinen Doppelpunkt.
- Beispiele `hello_i386.asm`, `hello_x64.asm`, `hello_arm32.asm`, `hello_arm64.asm` in `examples/windows_intel` und `examples/windows_arm`.
- **Asmonite debuggt ARM32-Programme (Thumb-2)** auf einem Windows-on-ARM-Rechner (asmodbg.exe, dieselben Ziele
  wie bei ARM64: ssh, direkt oder dieser Rechner): F9 und F8/F7 nach Quelltextzeilen, Haltepunkte, Ausführen bis
  zur Zeile, Register, Stack und Speicher. Test: `run_tests.bat thumbdbgtest` (nur wenn genannt; ssh zum Host winarm).
- Die PE-Prüfung kennt ARM32 (Machine 0x1C4): die Importe werden auf diesem Rechner nicht nachgeschlagen, und eine
  Warnung kommt, wenn der Einsprungpunkt das Thumb-Bit nicht hat.

### Behoben
- **Asmonite und Dismonite froren bei einem Halt eines Programms mit Fenster ein** (z. B. `window_i386.asm`
  bei `CreateWindowExA`): Das IDE-Fenster nach vorn zu holen wartete im Hauptthread auf das angehaltene Programm
  (`SetForegroundWindow`, `AttachThreadInput`). Das macht jetzt ein eigener Thread (`IdeFront.pas`). Auch die
  Meldungen des Win32-Debugger-Threads werden in eine Warteschlange gelegt und warten nicht mehr auf den
  Hauptthread.
- `.format pe` für x64 und ARM64 mit mehr als einer DLL: die Import-Adresstabellen lagen nicht immer auf
  8 Byte ausgerichtet (das Verzeichnis hat 20-Byte-Einträge); `ldr x16, [x16, :lo12:name]` ließ sich dann nicht
  kodieren. Sie sind jetzt auf 8 ausgerichtet.

## 0.4.0 – 2026-10-13

### Behoben
- Eine von Hand geschriebene PE-Datei (`org`, `db`, keine `section`-Zeilen) hatte Dateioffsets als
  Adressen in Zeilenkarte und Labels, der Debugger fand deshalb keine Quelltextzeile: Sie kommen
  jetzt aus der Sektionstabelle der Datei. Haltepunkte auf `db`-Zeilen in ausführbaren Sektionen
  gehen auch in den x64- und ARM64-Debuggern.

### Neu
- **Ressourcen von PE-Dateien in Dismonite**: Das Ressourcenverzeichnis (Data Directory 2) wird
  gelesen: Der Baum aus Typen, Namen und Sprachen bekommt seine Felder und Überschriften,
  Ressourcennamen (gezählte UTF-16-Texte) werden als Texte markiert. Die RT_STRING-Blöcke (16
  gezählte Zeichenketten: Längenwort, Zeichen, kein Abschluss) werden Zeichenkette für
  Zeichenkette markiert: `dw` Länge und `du` Text, jede mit dem Label `str_<id>` (id = (Block - 1) *
  16 + Index; dcc32.exe: 477 Zeichenketten, die Compilermeldungen). Andere Ressourcen bekommen
  eine Überschrift und ein Label `res_<Typ>_<Name>`. Eine Konstante vor einem Aufruf, der eine
  Meldung lädt (`push 0x82` / `mov eax, 0x20` vor einer Funktion, die `LoadStringA` erreicht;
  durch Zählen gefunden: mindestens 4 Aufrufe, davon 3 von 5 mit einer solchen Konstante), bekommt in
  der Codezeile den Hinweis `=str_130 "Internal error: %s%d"`. Test: `exptest` (dcc32.exe: Export
  gibt die Datei wieder, 477 Zeichenketten, Hinweise).
- **Sprunghinweis im Debugger von Dismonite**: Steht das Programm vor einem Sprung, den es gleich
  ausführt, sagt die Zeile die Richtung ("jump up to L00401520", "jump down to 0x401580", am rechten
  Rand der Zeile und in der Statuszeile). Ein bedingter Sprung zeigt es nur, wenn die Bedingung
  erfüllt ist (Flags, ecx/rcx bei `loop`/`jecxz`, cpsr, Register bei `cbz`/`tbz`), ein
  unbedingter immer; ein nicht genommener Sprung, Aufrufe und indirekte Sprünge zeigen nichts. Für
  x86, x64, ARM, Thumb und ARM64. Tests: `dbgtest`, `x64dbgtest`, `a64dbgtest`.
- **Export von x64- und ARM64-Programmen in Dismonite**: Der Code wird als Befehle geschrieben (mit
  Labels bei Sprüngen, Aufrufen und rip-relativen oder `adrp`-Adressen), nicht als `db`-Bytes; jeder
  Befehl wird wieder übersetzt und mit den Bytes der Datei verglichen, und was nicht dieselben Bytes
  gibt, bleibt `db` mit dem Befehl als Kommentar (kernel32: 49 von 200000 Zeilen).
  - Für Kodierungen, die der Text nicht sagen kann, hat der x64-Assembler Präfixwörter, die der Export
    schreibt: `enc.load` / `enc.store` (von den beiden Kodierungen einer Registerkopie die mit dem
    Register im `reg`- / im `rm`-Feld, `mov rcx, rbx` = 48 8B CB / 48 89 D9), `rex` und `rex.w` (ein REX-Präfix, das nichts ändert,
    `48 FF 15`), `enc.alt` (von gleich langen nicht die erste: `66 83 E8 2D` für `sub ax, 0x2d`);
    `short +18` und `near -7` (eine Zahl mit Vorzeichen nach `short`/`near`) sind Verschiebungen vom
    Ende des Befehls; `[0+rax+rax]` behält sein Verschiebungsbyte 0 (das lange `nop`).
  - Test: `exptest` (hello64, find, where, ipconfig, kernel32 von x64 und msvcrt von ARM64 werden
    wieder zur selben Datei; die letzten drei aus dem Ordner sandbox nur, wo die Dateien liegen).
- **ARM64-Assembler in Asmonite**: `.arch arm64` übersetzt A64-Befehle (Ganzzahl, Laden und Speichern,
  Sprünge, FP, NEON, Atomics, Crypto, System); `.format pe` schreibt damit eine PE32+-Datei für
  Windows on ARM64 (Machine 0xAA64; läuft auf Windows 10 ARM64).
  - `src/assembler/asm_a64.pas` hat keine eigene Tabelle: `dis_a64` ist von Hand geschrieben, also dient
    er als Orakel. Eine Liste von Seed-Wörtern (`asm_a64_seed.inc`, eines je Form eines Befehls, gemacht
    von `tests/a64seedgen.dpr` aus echtem Code, Zufallswörtern und ihren Nachbarn) wird durch Kippen
    jedes der 32 Bits untersucht: Registerfelder, die übrigen Bits nach den Operanden gruppiert, die sie
    ändern, und der Opcode. Der Text wird genauso in Tokens zerlegt, die Register kommen in ihre Felder,
    jede Gruppe der übrigen Bits wird gelöst (alle Werte, oder als lineare Funktion bei Sprungweiten
    und `mov`-Immediates, mit den Kontext-Bits) und das Ergebnis wird wieder dekodiert und muss
    denselben Text geben. Aliase (lsl, ubfx, cmp, cset, mov ...) brauchen nichts Eigenes.
  - Syntax wie der Decoder sie schreibt (capstone), `#` darf fehlen, `lr`/`fp`, ein Label als Ziel von
    Sprung, `adr`, `ldr` (literal); `adrp x0, name` mit `add x0, x0, :lo12:name`; `dq`.
  - Test: `a64asmtest` (die 1656 Fälle von `a64test`, die ganze ntdll von Windows 10 ARM64: 280000
    Befehle, Zufallswörter) und `exptest` (Quelltexte; `tests/pe_arm/a64asm_hello.asm` ist ein Programm,
    das Windows on ARM64 ausführt).
- **x64-Assembler in Asmonite**: `.arch x64` übersetzt x64-Befehle (REX, 64-Bit-Operanden, r8..r15,
  rip-relative Adressen, SSE bis SSE4.2, x87); `.format pe` schreibt damit eine PE32+-Datei (Machine
  0x8664, Image Base 0x140000000, Importeinträge mit 8 Bytes), die Windows ausführt.
  - `src/assembler/asm_x64.pas` ist die andere Richtung von `dis_x64`: Seine Tabelle der Kodierungen
    (`asm_x64_tab.inc`, geschrieben von `tests/x64tabgen.dpr`) wird dem Decoder durch Ausprobieren
    abgelesen (jeder Opcode mit jedem Präfix und REX.W), und jedes Ergebnis wird wieder dekodiert und
    muss derselbe Befehl sein. Die kürzeste Kodierung gewinnt. Syntax wie der Decoder sie schreibt
    (NASM-artig: `mov rax, [rbx+rcx*4+0x10]`, `call [printf]`, `dword [rax]`, `lock xadd`,
    `rep movsb`, `jmp short`); ein Label als Adresse eines Speicheroperanden ist rip-relativ, `[rel
    adresse]` auch; `dq` schreibt 64-Bit-Zahlen und -Adressen, `.imagebase` nimmt 64 Bit. Nicht
    übersetzt: AVX.
  - Die PE-Prüfung von Asmonite liest auch PE32+-Dateien (Header, Abschnitte, Importtabelle); die
    Funktionen der DLLs werden dafür nicht nachgeschlagen. `tests/pe_x64/hello64.asm` ist ein Programm,
    das Windows ausführt.
  - Debugger: F9 auf einem x64-Programm führt es mit Quelltextzeilen unter dem Debugger aus
    (Haltepunkte, Einzelschritt, Schritt über, bis Cursor, Pause, Register rax..r15, rip und die
    Flags, 64-Bit-Stack und -Speicher). Er nutzt dasselbe Hilfsprogramm wie Dismonite:
    `asmodbgx64.exe` (Ordner `armserver` neben dem Programm) als Kindprozess. ARM64-Programme
    (`.arch arm64`) werden ebenso auf einem Windows-on-ARM-Rechner debuggt (`asmodbg64.exe`: ssh,
    direkt oder, auf einem solchen Rechner, lokal); das Ziel stellt *Debug > Debug target Windows on
    ARM...* ein (der Dialog von Dismonite, Einstellungen in `Asmonite.ini`, beim ersten ARM64-Lauf
    gefragt). Register x0..x30, sp, pc, cpsr und N Z C V. Noch nicht: Tastatureingabe für das
    Programm. Tests: `x64dbgtest` und `a64dbgtest` (Zeilenmodus).
  - Test: `x64asmtest` (jeder Text der 1124 Fälle von `x64test` wird wieder derselbe Befehl; mit einer
    DLL als drittem Parameter alle ihre Befehle: kernel32, ntdll, user32, ucrtbase, msvcrt, combase:
    2,8 Millionen, alle zurück) und die Quelltexte in `exptest`.
- **ARM64-Programme in Dismonite**: eine PE-Datei für ARM64 (Machine 0xAA64) wird disassembliert und debuggt.
  - Decoder `src/assembler/dis_a64.pas` (A64): Ganzzahlbefehle mit den üblichen Aliasen (mov, cmp, cset,
    ubfx, ...), Sprünge, Laden und Speichern (Paare, exklusiv, Atomics LSE, Speicher kopieren/setzen,
    Memory Tagging), skalare Gleitkommabefehle, Advanced SIMD (NEON, auch Skalarprodukt, komplexe und
    Elementformen) und die Crypto-Erweiterungen (AES, SHA-1/256/512, SHA-3, SM3, SM4); SVE und SME
    bleiben Daten. Der Text ist der von capstone: `tools/a64_check.py` vergleicht ganze Dateien (ntdll,
    kernel32, ucrtbase, msvcrt von Windows auf ARM64: 710000 Befehle, alle gleich) und Zufallsworte; der Test
    `a64test` hat 1700 Fälle (`tools/gen_a64_cases.py`). Die Namen der Systemregister kommen aus
    `tools/gen_a64_sysregs.py`.
  - Adressen wie bei x64: 16 Stellen, `L0000000140001000`, das Dokument behält die unteren 32 Bit. Die
    Analyse folgt `b`, `bl`, `b.cond`, `cbz`, `tbz`; `adr` zeigt das Label dessen, worauf es zeigt, als
    Hinweis, ein `ldr` (literal) macht sein Wort zu Daten. Der Export schreibt den Code als Befehle (siehe
    oben), `.imagebase` eines 64-Bit-Images mit allen Bits.
  - Debugger: Back-End `DbgGdbA64.pas` (wie `DbgGdbArm` für ARM32): `asmodbg64.exe` auf einem Windows-auf-
    ARM64-Rechner über ssh, direkt (`asmodbg64.exe --listen`, gleicher Anmeldecode) oder, wenn Dismonite
    auf so einem Rechner läuft, als Kindprozess; die Einstellungen von *Debug > Debug-Ziel Windows on ARM*
    gelten für beide. Register X0..X28, FP, LR, SP, PC, CPSR und die Flags, Stack aus Qwords, Speicher
    mit 64-Bit-Adressen; Step Over führt ein `bl`/`blr` bis zum Befehl dahinter aus. Test: `a64dbgtest`
    (nur wenn genannt; `src/armserver/build64.bat`, ssh-Host `winarm`).
- **x64-Programme in Dismonite**: eine PE-Datei für x64 (Machine 0x8664) wird disassembliert und debuggt.
  - Decoder `src/assembler/dis_x64.pas`: REX, 64-Bit-Operanden, rip-relative Adressen, r8..r15,
    Ganzzahlbefehle, x87, SSE bis SSE4.2 und AES; VEX/EVEX (AVX) werden noch nicht decodiert und bleiben
    Daten. Geprüft gegen capstone mit `tools/x64_check.py` (ntdll, ucrtbase, mshtml, libclang: alle
    Befehle gleich bis auf einige Schreibweisen von capstone) und durch den Test `x64test` (1124 Fälle).
  - Adressen: das Dokument behält die unteren 32 Bit einer Adresse (ein Image ist kleiner als 4 GB);
    `ImageBase64`, `AddrText` und die `*64`-Funktionen geben die ganze. Adressspalte, Labels
    (`L0000000140001000`), Register, Stack und Speicheransicht zeigen 16 Stellen. Ein relozierter
    64-Bit-Zeiger (`dq`) zeigt sein Label.
  - Debugger: `asmodbgx64.exe` (neu, `src/armserver/asmodbgx64.c`, `buildx64.bat`, llvm-mingw
    `x86_64-w64-mingw32`) wird als Kindprozess auf diesem Rechner gestartet, wie `asmodbg` auf dem
    ARM-Rechner: ein 32-Bit-Programm kann einen 64-Bit-Prozess nicht mit der Win32-Debug-API debuggen.
    GDB-Protokoll mit den amd64-Registern, Haltepunkt `int3`, Einzelschritt über das Trap-Flag.
    Back-End `DbgGdbX64.pas`; Register RAX..R15, RIP, EFLAGS, Stack aus Qwords und Speicheransicht mit
    64-Bit-Adressen. Tests: `python tools/asmodbgx64_test.py` (Server), `x64dbgtest` (Debugger von
    Dismonite, 29 Prüfungen).
  - `asmodbg` und `asmodbg64` nennen `asmodbgx64`, wenn sie ein x64-Programm bekommen.
- `asmodbg64.exe`: der Debug-Server für native ARM64-PE-Programme (Windows on ARM64), eine Portierung von
  `asmodbg` (Quelltext `src/armserver/asmodbg64.c`, `build64.bat` mit llvm-mingw `aarch64-w64-mingw32`).
  Register in der Reihenfolge des aarch64-Ziels von GDB (x0..x30, sp, pc, cpsr, v0..v31, fpsr, fpcr),
  Einzelschritt über PSTATE.SS, Haltepunkt `BRK #0xF000`. Test: `tools/asmodbg64_test.py` (Sitzung mit
  einem C-Programm und mit dem ARM64-Hello-World `tests/pe_arm/pe_arm64_hello_world.asm`, dessen Code als
  `db` geschrieben ist). Dismonite kann ihn noch nicht benutzen (kein A64-Disassembler, keine 64-Bit-Register).

- Dismonite auf Windows on ARM: das Ziel „Dieser Rechner ist der Windows-on-ARM-Rechner“ (*Debug > Debug
  target Windows on ARM*, `[WinArm] Mode=local`). Dismonite läuft dort selbst (als emuliertes x86-Programm)
  und startet `asmodbg.exe` (Ordner `armserver\`) als eigenen Kindprozess, `--once 127.0.0.1:<freier Port>`,
  mit dem Ordner des Programms als Arbeitsordner: kein ssh, kein Kopieren, kein Anmeldecode, keine
  Firewallregel, kein offener Port außer der Loopback-Adresse. Ein Server, der sofort endet, sagt warum
  („this is an ARM64 program: use asmodbg64“, „the program was not found“) statt einer gescheiterten
  Verbindung. Test: `python tools/winarm_local_test.py` baut `winarmdbgtest.exe`, kopiert es mit dem Server
  auf den ARM-Rechner und startet es dort per ssh (`winarmdbgtest <dir> <work> local`: 18 Prüfungen,
  Entry-Stopp, Schritte, Haltepunkt, Ausgabe, Exit-Codes).

### Geändert
- `asmodbg` und `asmodbg64` sehen vor dem Start in das Feld Machine des Programms und sagen, was nicht
  stimmt: „this is an ARM64 program: use asmodbg64“, „this is a 32-bit ARM program: use asmodbg“;
  x86-/x64-Programme werden abgelehnt, eine fehlende Datei und eine Datei ohne PE-Format haben je einen
  eigenen Text (vorher „cannot start the program (error 50)“, oder das Programm lief ohne Halt
  durch). Dismonite zeigt den Text als „The program did not start: ...“.

## 0.3.0 – 2026-10-12

### Neu
- `qemu\install_qemu.bat`: `run_freedos.bat` und `run_buster.bat` rufen es auf, wenn QEMU fehlt.
  Auf x64-Windows installiert es wie bisher das getestete QEMU (9.2.0) mit winget, jetzt ohne
  Rückfragen; auf Windows on ARM, wo winget kein ARM64-QEMU hat und dessen x64-Version nicht läuft
  (Windows 10 on ARM emuliert nur 32-Bit-x86), lädt es die neueste native ARM64-Version von
  qemu.weilnetz.de/aarch64, prüft sie gegen ihre `.sha512`-Datei und installiert sie ohne
  Rückfragen nach `C:\Program Files\qemu`. Anderes Windows (32 Bit): ein Hinweis, keine
  Installation. Getestet auf Windows 10 on ARM (QEMU 11.1.0).
- Windows on ARM ohne 32-Bit-ARM (Windows 11 24H2 und neuer, kein `SysArm32`): Der Ein-Zeilen-
  Installer von asmodbg und das ssh-Ziel von Dismonite sagen das deutlich, statt eines Servers,
  der nicht startet.
- „Search LAN“ im Dialog „Debug-Ziel Windows on ARM“: Dismonite fragt das lokale Netz (UDP-
  Broadcast an den Port), welche `asmodbg --listen` es gibt, und trägt Adresse und Port der
  Antwort ein (mehrere: eine Liste zur Auswahl). Der Server beantwortet nur diese eine Anfrage,
  mit Version, Port und Rechnername, nie mit dem Code; `--no-discover` schaltet es ab. Die
  Firewall des ARM-Rechners muss UDP 23457 durchlassen (eine `netsh`-Regel von Hand braucht eine
  zweite Zeile mit `protocol=UDP`).
- Thumb-Assembler `asm_thumb.pas` (der erste Teil des ARM-Assemblers): die Tabellen des
  Thumb-Disassemblers rückwärts. Ein Text, wie der Disassembler ihn schreibt (dazu Großschreibung,
  Dezimalzahlen, `sb sl fp ip`, Bereiche in Registerlisten, `cs`/`cc`), wird gegen die Operanden-Vorlage
  jeder Zeile mit der Mnemonik gehalten, die Platzhalter geben die Bits ihrer Felder zurück, und der Code
  wird zur Kontrolle wieder disassembliert. 16 Bit vor 32 Bit wie GAS (`add.w` lang, `add` nur dann
  lang, wenn keine kurze Form passt); IT-Blöcke wie der Disassembler. Testteil `thumbasmtest`: alle
  16-Bit-Codes, die 586 32-Bit-Wörter und 6 Folgen von `thumbtest`, Zufallscodes jeder Zeile; alles
  kommt zurück, Alias-Codierungen (Don't-care-Bits, `cmp r0, r0` in der High-Register-Form) werden
  getrennt gezählt.
- `.arch thumb` in Asmonite: Dahinter ist jede Zeile, die keine Daten- oder Steuerdirektive ist, ein
  Thumb-Befehl für `asm_thumb`; ein Label braucht seinen Doppelpunkt; Sprungziele dürfen Labels sein
  (`b loop`, `bl func`, `cbz r0, done`), aufgelöst über die zwei Durchgänge des Assemblers; die Adresse
  eines Befehls ist `.imagebase` plus die RVA der `section`-Zeilen. Der Export von Dismonite schreibt
  PE-Programme für Windows on ARM mit `.arch thumb` und ihren Code als Befehle: Jede Zeile wird vorher
  an ihrer Adresse mit ihrem IT-Zustand assembliert und muss die Bytes der Datei ergeben, sonst bleibt
  sie `db` mit dem Befehl als Kommentar (Alias-Codierungen); die Prüfung der ganzen Datei mit dem
  Assembler läuft wie bei x86. `exptest` übersetzt den Export der beiden `tests\pe_arm`-Programme zurück.
- Der Editor von Asmonite färbt die Zeilen nach `.arch thumb` als ARM/Thumb (Register `r0`..`pc`,
  `s0`..`d31`, Befehle mit Bedingung und `.w`, `#`-Konstanten, `@`-Kommentare) und die Zeilen nach
  `.arch i386` oder `.arch x86_real` wieder als x86: Der Prozessor ist der Zeilenzustand, den der
  Editor von Zeile zu Zeile weiterreicht, genau wie im Assembler; die Farben folgen also jeder
  Änderung sofort und brauchen weder Dateiendung noch Raten. Der Menüeintrag „Assembler (x86)“
  unter Syntax heißt jetzt „Assembler“.
- Befehlsinfo (F1) für importierte Funktionen: Eine Zeile, die einen Import benutzt (`call [ExitProcess]`,
  `jmp [X]`, der Eintrag der Importtabelle, sein Label, Thumb `ldr r3, =ExitProcess`), zeigt unter dem
  Befehl die Funktion aus der neuen Datei `help\de\winapi.md`: DLL, Aufrufkonvention, Anzahl und Bytes
  der Parameter, der Aufruf in C-Reihenfolge, jeder Parameter mit Typ und Bedeutung, das Ergebnis, eine
  kurze Erklärung und bei den häufigen ein Beispiel. 205 Abschnitte (A- und W-Form zusammen) für
  kernel32, user32, gdi32, comdlg32, advapi32, shell32, oleaut32, msvcrt und die `api-ms-win-crt-*`-Teile
  der universellen C-Laufzeit: alle Importe der Programme im Repository und die üblichen daneben. Eine
  Funktion ohne Abschnitt zeigt Name und DLL und dass es noch keinen Abschnitt gibt. Geprüft gegen
  `dcc32.exe` (Delphi-Compiler), das Delphi-Programm `asmoc.exe`, das clang-Programm und die Beispiele:
  33 Abschnitte mehr für das, was `dcc32.exe` importiert und noch fehlte (Ressourcen, Laufwerke, Umgebung,
  Zeitzone, Konsolen-Steuerung, GUIDs, ...), jetzt 238 Abschnitte.
- Befehlsinfo (F1) im Editor von Asmonite: Die Zeile des Cursors wird in einem neuen Reiter „Help“ in der Spalte
  rechts neben den Registern erklärt, aus denselben Hilfedateien wie in Dismonite (x86 oder, nach
  `.arch thumb`, `arm.md`; importierte Funktionen aus `winapi.md`: jeder Name der Zeile, der einen Abschnitt
  hat, z. B. `call [ExitProcess]`). Der Text ändert sich auf F1; *Help > Help
  language* schaltet Deutsch/English um (`Asmonite.ini`, `[Help] Language`). Der Hilfe-Code zog von
  `DisHelp.pas` in die gemeinsame Unit `src/HelpText.pas` (Hilfebücher, Markdown nach RTF); `DisHelp` behält,
  was die Zeilen des Disassemblers braucht.
- Asmonite: Ein Quelltext ohne `.format` und ohne `.arch` (und ohne `org`, `section`, `segment`, `codeend`)
  wird als `.arch i386` + `.format pe console` übersetzt: Schon die eine Zeile `mov eax, 1` ergibt ein
  32-Bit-Windows-Programm (das Ausgabefenster sagt es). Was `.arch` oder `.format` nennt oder `org`/`section`
  setzt, bleibt unverändert (DOS-`.COM`, Bootsektoren, von Hand geschriebenes PE, Thumb). Die Regel ist die
  Eigenschaft `DefaultPe` von `TAsmoAssembler` / `TAsmFormatter`, nur Asmonite schaltet sie ein; asmoc und
  die Tests des Kerns übersetzen den Text wie er steht. Für Windows auf ARM folgt der Standard noch.
- Asmonite: Die Hilfe ändert sich nur noch auf F1 (sie folgt weder dem Cursor noch dem Text); F1 erklärt
  auch die Direktiven: neue `help\de\directives.md` / `help\en\directives.md` mit `.arch`, `.format`,
  `.code`/`.data`, `.import`, `.entry`, `.imagebase`, `du`, `rel32`, `codeend`, `section`, `segment`.
- Beispiele für DOS in Assembler: `examples\dos\hello.com.asm` („Hello, World!“ als .COM-Programm, ohne
  Header, `section 0x100`) und `examples\dos\hello_exe.asm` (als .EXE mit von Hand geschriebenem Header,
  ein Segment); beide laufen mit F9 in QEMU mit FreeDOS. Die Kommentare erklären den Unterschied .COM / .EXE.
- Asmonite: Die Hilfe steht in der rechten Spalte neben der Registerliste (Reiter Registers und Help, wie
  bei Dismonite), nicht mehr unter dem Editor; die Schaltfläche x schließt sie, F1 zeigt sie wieder.
- F1 erklärt Fehlermeldungen: auf einer Zeile des Ausgabefensters oder im Editor auf der als fehlerhaft
  markierten Zeile zeigt die Hilfe, was die Meldung des Assemblers oder der PE-Prüfung bedeutet, die
  üblichen Ursachen und eine Lösung (`help\de\errors.md`, `help\en\errors.md`, 32 Abschnitte). Die
  Hilfe folgt einem Klick oder einer Cursortaste im Ausgabefenster.
- Befehlsinfo (F1) für DOS- und BIOS-Interrupts, in Dismonite und Asmonite: Zu einem `int` steht unter dem
  Befehl die Funktion, die er aufruft, aus der neuen Datei `help\de\dos.md` / `help\en\dos.md` (je 154
  Abschnitte): `int 21h` (rund 70 Funktionen: Zeichen, Dateien, Verzeichnisse, Speicher, Programme, Vektoren,
  Zeit), `int 10h` Video, `int 13h` Laufwerke (CHS und LBA), `int 16h` Tastatur, `int 1Ah` Uhr, `int 33h`
  Maus, `int 2Fh`, `int 15h`, `int 14h`, `int 17h`, `int 20h`, `25h`, `26h`, `27h`, `29h`, `11h`, `12h`,
  `24h`, `28h`. Die Funktionsnummer wird in den Befehlen vor dem `int` gefunden (`mov ah, 0x09`,
  `mov ax, 0x4C00`, `xor ah, ah`, `mov al, ...`; über Labels hinweg, bis zu einem Sprung, Aufruf, Rücksprung
  oder einem anderen `int`; ein Befehl, der `ah` anders ändert, gibt auf). Ist sie nicht bekannt, steht die
  Übersicht des Interrupts mit der Liste seiner Funktionen da. Jeder Abschnitt hat Eingabe- und
  Ausgaberegister (mit Carry-Flag und Fehlercodes) und oft ein Beispiel. Bei `int 21h` in `TPC.EXE` und
  `HELLO.EXE` finden 23 von 24 den Abschnitt ihrer Funktion. Die Mausfunktionen wählt `ax`, nicht `ah`.
- Hilfetexte auf Englisch: `help\en\x86.md`, `arm.md` und `winapi.md` sind die Übersetzungen der deutschen
  Dateien mit denselben Abschnitten unter denselben Namen (ein Test vergleicht sie). Dismonite: *Help > Help
  language* schaltet sofort zwischen Deutsch und English um; die Wahl steht in `Dismonite.ini`
  (`[Info] Language=de|en`); ohne Wahl bekommt ein deutsches Windows Deutsch und jedes andere English; fehlt
  die Datei einer Sprache, gilt Deutsch.

### Geändert
- Asmonite: Die Registerliste rechts erscheint nur, solange ein Programm debuggt wird (läuft oder hält an;
  *View > Registers* entscheidet weiter, ob sie gezeigt werden darf); ein Assembler-Fehler zeigt den Reiter
  Output (auch wenn der Reiter Help oder Stack gezeigt wurde oder der Ausgabebereich verborgen war); jede
  neue Zeile in der Ausgabe scrollt sie ans Ende.
- Sprache der Hilfetexte: English, außer die Oberflächensprache von Windows ist Deutsch (vorher: die
  Einstellung für regionale Formate).

### Behoben
- `asmodbg.exe` per Doppelklick (ohne Argumente) gestartet zeigte nur seine Aufrufhilfe und endete,
  obwohl die Readme das Fenster versprach; ohne Argumente läuft es jetzt wie `--listen`.
- Dismonite, Windows on ARM über ssh: Der Tunnel benutzte auch auf diesem Rechner den Port 23456
  und scheiterte, wenn der belegt war; jetzt nimmt er hier einen freien Port (asmodbg auf dem
  ARM-Rechner bleibt bei 23456).

## 0.2.0 – 2026-10-11

### Neu
- Dismonite debuggt 32-Bit-Programme für Windows on ARM (PE, Machine 0x1C4) auf einem echten
  Windows-on-ARM-Rechner, wie ARM-Linux-Programme im QEMU-Gast: Halt am Einsprungpunkt,
  Haltepunkte, Einzelschritt, Step over, Run to cursor, Pause, Stopp, Register, Speicher,
  Programmausgabe, Exit-Code, Exceptions. Neuer Server `asmodbg.exe` (C, ARM32/Thumb-2, mit
  llvm-mingw durch `src/armserver/build.bat` gebaut): Er führt das Programm mit der Win32-Debug-API
  aus und spricht das GDB-Protokoll wie gdbserver; deshalb dient der ARM-Debugger von Dismonite
  (`TArmGdbDebugger`, neu mit dem Ziel `atWinArm`) fast unverändert. Dismonite kopiert das
  Programm (und den Server, wenn seine Version abweicht) per scp, startet den Server per ssh und
  verbindet sich über einen ssh-Tunnel (`-L`): keine Firewall-Regel auf dem ARM-Rechner. Host
  (Vorgabe `winarm`) und Ordner (Vorgabe `asmodbg`, relativ zum Home-Ordner) stehen in
  Dismonite.ini unter `[WinArm]` als `Host=` und `Dir=`. Einzelschritte nutzen das SS-Bit im
  CPSR (per Experiment gefunden: Windows on ARM32 unterstützt es, der Server braucht keinen
  Befehlsdecoder). Tests: `tools/asmodbg_test.py` (Server allein, 27 Prüfungen) und Testteil
  `winarmdbgtest`. `asmodbg --listen` (Server `asmodbg-3`, erster Schritt der Direktverbindung
  ohne ssh): der Server bleibt offen und bedient die Sitzungen nacheinander; eine Sitzung lädt das
  Programm in einen eigenen Ordner hoch (`vFile`), startet es nur von dort (`vRun`) und bekommt
  die Programmausgabe als `O`-Pakete. Nur schlichte Dateinamen. Der Listen-Modus verlangt eine
  Anmeldung: ein 12-stelliger Code (vom Server erzeugt, mit DPAPI neben der EXE gespeichert,
  `asmodbg --show-code` zeigt ihn), Challenge-Response mit HMAC-SHA256 (Windows CNG) in beide
  Richtungen, danach ein MAC an jedem Paket (Integrität, keine Verschlüsselung); vorher wird
  nichts beantwortet, 3 falsche Beweise sperren den Server 10 s. Er lauscht auf allen Adressen
  (Port 23457); winarm braucht eine Firewall-Regel. Der Listen-Modus zeigt ein kleines Fenster
  (Version, ARM32-Prüfung, IP-Adressen, Port, Code, Status, Warnung bei Administratorrechten;
  `--port N`, `--no-window`, `--info`). `asmodbg_test.py` hat jetzt 77 Prüfungen,
  auch die Direktverbindung ohne ssh.
- Dismonite verbindet sich direkt mit `asmodbg --listen` (ohne ssh zum Debuggen): Anmeldung mit
  dem Code (HMAC-SHA256 über die Windows-CryptoAPI), Versionsprüfung, Upload mit `vFile`, Start
  mit `vRun`, Programmausgabe aus den `O`-Paketen. Neu: *Debug → Debug target Windows on ARM…*
  (Direkt oder ssh, Host, Port, Code, Ordner, „Test connection“ mit klaren Fehlermeldungen); der
  Dialog öffnet sich selbst beim ersten Start eines Windows-on-ARM-Programms. ini `[WinArm]`
  `Mode`, `Port`, `Code` (mit DPAPI geschützt). `winarmdbgtest` führt alle Tests auch direkt aus
  (39 Prüfungen). `asmodbg.exe` liegt im Release-ZIP unter `armserver\`; die Einrichtung auf
  frischen Rechnern (Server starten, Firewall, Dialog) steht in der README des ZIPs.
  Einzeiler für den ARM-Rechner: `powershell -NoProfile -Command "irm
  https://asmonite.com/downloads/install-asmodbg.ps1 | iex"` (`tools/install-asmodbg.ps1`, von
  `tools/release.py` mit `asmodbg.exe` nach `html/downloads/` gelegt, Prüfsumme der EXE im Skript;
  läuft nicht als Administrator, ersetzt einen älteren Server und startet ihn). Der Dialog zeigt
  die Zeile mit der Schaltfläche „Copy the line“.
- Dismonite: Der Debugger zeigt Stack, Speicher und die Ausgabe des Programms, alles zugleich mit
  den Registern: Register und Stack rechts neben dem Code, Speicher und Ausgabe darunter. Der
  Stack: 32 Einträge ab dem Stackzeiger, mit dem Label, auf das ein Wert zeigt (Doppelklick springt
  hin). Der Speicher: 16 Zeilen ab einer Adresse, einem Label, einem Register oder (DOS)
  Segment:Offset; geänderte Werte sind rot. Die Ausgabe: was das Programm in diesem Lauf
  geschrieben hat (Windows: seine Konsole, DOS: der Bildschirm, ARM: stdout). Jede Anzeige lässt
  sich im Debug-Menü abschalten; sie erscheinen mit der ersten Debug-Sitzung.
- Dismonite liest 32-Bit-Programme für Windows on ARM (Machine 0x1C4): Header, Imports und
  Exporte wie bei i386, den Einsprungpunkt ohne das Thumb-Bit (Label `start` bei 0x401000 für
  `AddressOfEntryPoint` 0x1001) und den Thumb-2-Code: Die Analyse folgt ihm ab Einsprungpunkt und
  Exporten, IT-Blöcke erscheinen mit ihren Bedingungen, `adr`/`ldr [pc]` bekommen den Import oder
  das Label, auf das sie zeigen, als Hinweis. Der Export schreibt Thumb-Code als Bytes mit dem
  Befehl als Kommentar und ergibt so wieder dieselbe Datei. Gleitkommabefehle (VFP: `vldr`, `vmov`,
  `vadd.f64`, `vpush`, `vmrs`, ...) dekodiert es, NEON-Befehle noch nicht. Neuer tabellengetriebener
  Decoder `dis_thumb` (alle 16-Bit-Codes und die
  Thumb-2-Befehle so, wie capstone sie schreibt; `tools/thumb_check.py`, Testteil `thumbtest`).
- Dismonite: ARM-Linux-Programme dürfen ARM- und Thumb-Code mischen (wie GCC sie erzeugt): jede Stelle
  hat ihre Art (neue Art „thumb“, Taste T). Die Analyse folgt dem Einsprungpunkt und den Funktionen der
  Symboltabellen in ihrer Art (Bit 0), wechselt sie bei blx und nutzt die Mapping-Symbole ($a, $t, $d)
  und .plt; der Debugger erkennt Thumb-Code am T-Bit (Haltepunkte, Step Over). ARM-Programme lassen
  sich jetzt als .asm exportieren (Code als Bytes mit dem Befehl als Kommentar). Neues Testprogramm
  hallo-thumb.
- Dismonite: ARM- und Thumb-Code hat eigene Farben: Register r0..pc, s0..s31, d0..d31, Zahlen nach #,
  Befehle auch mit Bedingung (addeq, vmoveq.f64).
- Dismonite: Befehlsinfo (F1): rechts der Befehl der aktuellen Zeile erklärt (Syntax, Flags, ein
  Beispiel), aus der Hilfedatei `help\de\x86.md` (vorerst Deutsch); sie folgt dem Cursor (Help > Info
  follows the cursor). Beim Debuggen ist sie ein zweiter Reiter neben den Registern. Alle Befehle, die
  der Disassembler dekodiert (x87: ein Abschnitt); ARM und Thumb in `help\de\arm.md` (`addeq`, `bne`,
  `vmoveq.f64` finden ihren Befehl und zeigen die Bedingung dazu).
- Dismonite: Nullbytes vor einer Struktur sind ebenfalls eine Zeile (`org`/`align`), nicht nur vor dem
  PE-Header, einer Section und am Dateiende: z. B. bis `e_lfanew` bei einem DOS-Header ohne Stub oder
  zwischen dem Code und den Imports derselben Section.
- Release-ZIP: `examples\winarm\pe_arm32_hello_world.exe` (mit ihrer `.asm`), ein Programm für
  Windows on ARM zum Ausprobieren des ARM-Debuggers von Dismonite mit asmodbg.

### Behoben
- Dismonite: Datei > Öffnen versprach Programme ohne Endung (ARM-Linux) unter „Programs", aber der
  Dialog des heutigen Windows findet mit dem Filter `*.` keine. Sie stehen jetzt unter „All files (also
  programs without extension)", und Dismonite merkt sich den zuletzt gewählten Dateityp
  (`Dismonite.ini`).
- Dismonite: Der letzte Befehl einer Section wurde nicht als Code erkannt, wenn er mit dem Byte 00
  einer Adresse endete (`call [ExitProcess]` am Ende von `demo.exe`).
- Dismonite: Die Registerliste behielt nach dem Öffnen einer anderen Datei die Werte der letzten
  Debug-Sitzung; ihre Kopfzeile zeigte „Regi…“ statt „Register“.
- Dismonite: Die letzte Zeile, die ein Programm schrieb, wurde sofort durch „Program exited with
  code 0“ ersetzt (ARM-Programme schreiben ihre Ausgabe erst am Ende); die Ausgabe-Anzeige behält
  alle Zeilen.
- Das DOS-Beispiel `HELLO.EXE` passte nicht zu seinem Quelltext `HELLO.PAS` (ein älteres, mit
  Turbo Pascal 6 übersetztes Programm). Beide liegen jetzt in `examples/dos`: `HELLO.PAS` zählt
  hoch, `HELLO.EXE` ist ihre Übersetzung mit Turbo Pascal 7, von den Tests geprüft.

## 0.1.0 – 2026-10-09 (Testpaket, Git-Tag v0.1.0)

Die erste Version.

### Asmonite (Editor, Assembler, Debugger)
- Editor mit Syntax-Hervorhebung für x86-Assembler, C und Pascal; Rückgängig/Wiederholen,
  Suchen und Ersetzen (Strg+F, F3, Strg+H), Gehe zu Zeile (Strg+G).
- Assembler für den i386: `.format pe` (Header und Importtabelle werden erzeugt) oder jedes
  Byte im Quelltext; Labels, `.imagebase`, `org`, `align`, `rva`.
- Prüfung der erzeugten PE-Datei vor dem Start (Header, Sections, Importe).
- Win32-Debugger: Haltepunkte (sie wirken auch, während das Programm läuft), Step Over/Into,
  Run to Cursor, Pause, Ausführungsstelle zeigen;
  Register, Stack und Speicher; die Ausgabe des Programms im Ausgabefenster.
- DOS-Programme in QEMU mit FreeDOS (nicht mitgeliefert: `qemu\run_freedos.bat` lädt die
  FreeDOS-Diskette und bietet die Installation von QEMU an); dasselbe Programm startet im
  laufenden QEMU erneut.

### Dismonite (Disassembler und Debugger)
- Windows- (PE), DOS- (MZ) und ARM-Linux-Programme (ELF); die Strukturen des Dateiformats
  (Header, Sections, Importe, Exporte, ELF-Program-Header und -Symbole) mit den Namen
  ihrer Felder.
- Analyse ab Einsprungpunkt, Exporten und Relokationszielen.
- Labels statt Adressen; Strg+Klick springt zum Ziel, Alt+Links zurück.
- Markierungen und Kommentare werden in `<programm>.dmon` gespeichert.
- Export als `.asm` mit Labels, den der Asmonite-Assembler wieder zur selben Datei übersetzt.
- Debugger: Haltepunkte, Step Over/Into, Run to Cursor, Pause, Register; Parameter für das
  Programm (Debug > Parameters, in der `.dmon` gespeichert). Wo das Programm anhält, wird Code.
  Windows-Programme direkt, DOS-Programme in QEMU mit FreeDOS, ARM-Linux-Programme über
  gdbserver in Raspberry Pi OS unter QEMU (Dismonite startet den Gast auf Wunsch).

### QEMU-Gäste (Ordner qemu)
- `run_freedos.bat`: FreeDOS; lädt die Bootdiskette (720 KB).
- `run_buster.bat`: Raspberry Pi OS (ARM) zum Debuggen von ARM-Programmen; lädt etwa 440 MB
  und richtet den Gast ein (ssh, gdbserver, Tastatur wie in Windows).
- Beide bieten an, QEMU mit winget zu installieren; `-h` zeigt die Optionen.

### asmoc
- Der Assembler auf der Kommandozeile.

### Bekannte Grenzen
- Keine x87-Gleitkommabefehle im Assembler; der Disassembler zeigt sie ohne Namen.
- Die Unterschiede zu NASM stehen in docs/de/nasm-unterschiede.md.
