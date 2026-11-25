# Beispiele

Die Beispiele von Asmonite. Jedes hier ist noch einmal durchgesehen und auf den Boards getestet, für die es gedacht
ist; weitere folgen nach und nach. Die meisten sind in aBelle; von den Beispielen in Assembler sind die ersten drei
hier (siehe am Ende), die anderen kommen Board für Board.

`common/` enthält Programme, die auf jedem Board laufen (ESP32, ESP32-S3, ESP32-C3, ESP32-S31, Raspberry Pi Pico und
Pico 2, auch mit WLAN); Asmonite übersetzt sie für das Board, das du benutzt. Was sie mit `include` einbinden
(`console.abel`, `net.abel`), ist die Bibliothek von aBelle in [`abelle/lib`](../abelle/lib): `common/` für jedes
Board, `<board>/` für eines; in der ZIP-Datei liegt sie neben den Compilern. `<board>/` enthält Programme nur für ein
Board, weil sie seine Hardware nutzen (Pins, Sensoren, sein Display).

So startest du eines: F9 übersetzt es für das Board im Tab Serial und lässt es laufen. Oder du lädst es im Board
Manager hoch (oder mit Project > Compile and Upload) und tippst seinen Namen in die Konsole des Boards; Argumente gehen
nur dort, nach dem Namen: `ping 192.168.1.20`, nicht `run ping 192.168.1.20`.

<!-- EXAMPLES_BEGIN: made from catalog.txt by tools/examples_build.py, change it there -->

## Erste Schritte

- `common/hello.abel`: **Hello, world.** Schreibt „Hello, world!“ über die serielle Ausgabe des Boards.
- `common/blink.abel`: **Blinken.** Lässt die LED des Boards blinken; vorher oben `LED_PIN` für dein Board setzen.
- `common/runs.abel`: **Eine Zahl, die bleibt.** Zählt, wie oft es gelaufen ist, in der Datei `runs.txt` auf dem
  Board (`file_size`, `file_read`, `file_write`); die Zahl bleibt auch ohne Strom. `cat runs.txt` in der Konsole
  zeigt sie, `rm runs.txt` fängt neu an.

## Das Netz, von unten nach oben

Für die Boards mit WLAN. Außer `scan` brauchen sie ein Netz: einmal `wlan set` in der Konsole.

- `common/scan.abel`: **WLAN-Netze in der Nähe.** Signal, Kanal, Schutz, BSSID und Name jedes Netzes, das das Board
  hört; ein Scan hört nur zu und braucht kein Netz.
- `common/arpscan.abel`: **Wer ist im Netz?** Fragt jede Adresse seines /24-Netzes per ARP und listet die Geräte, die
  antworten, mit ihrer MAC.
- `common/ping.abel`: **Ping.** Pingt den Router und einen Server im Internet (je vier Echo-Anfragen, ICMP) und zeigt
  die Zeiten wie der Ping eines PCs; mit einem Argument (`ping 192.168.1.20` oder `ping example.com`) diesen Host.
- `common/pingled.abel`: **Die LED blitzt bei jedem Ping.** Das Board beantwortet die Pings, und seine LED blitzt bei
  jedem auf; die Adresse, die es zeigt, vom PC oder Handy aus pingen. Vorher oben `LED_PIN` für dein Board setzen.
- `common/wol.abel`: **Wake-on-LAN.** Schickt das Magic Packet (ein UDP-Broadcast), das einen PC aus dem Schlaf oder
  aus dem ausgeschalteten Zustand startet (oben in `pc_mac()` die MAC des PCs setzen, oder `wol 02:00:00:12:34:56`);
  mit der Adresse des PCs nach der MAC wartet es danach, bis der PC auf einen Ping antwortet. Board und PC müssen im
  selben Netz sein.
- `common/httpget.abel`: **Eine Webseite holen.** Über TCP, wie ein Browser sie anfragt: die Statuszeile und die
  Kopfzeilen der Antwort, der Titel der Seite, ihre Bytes und die Zeit (`httpget` fragt example.com, `httpget
  neverssl.com/` oder `httpget http://192.168.1.20:8080/status` eine andere Adresse); nur http.
- `common/httpsget.abel`: **Eine Webseite über HTTPS.** Wie `httpget`, aber verschlüsselt, mit dem TLS 1.3 von aBelle
  (ChaCha20-Poly1305, X25519; der Handshake dauert auf einem ESP32 etwa 2 s): `httpsget` fragt example.com, `httpsget
  www.wikipedia.org/` einen anderen Server. Das Zertifikat des Servers wird noch nicht geprüft: verschlüsselt, aber
  nicht sicher gegen jemanden, der sich als der Server ausgibt. Noch nicht auf dem ESP32-C3 (zu groß für seinen RAM).

## Takt und Tempo

Wie schnell das Board rechnet, und der Takt seines Kerns, von einem Programm gesetzt. Was dahintersteckt: [Den Takt
des Kerns ändern](../docs/de/takt.md).

- `common/bench.abel`: **Wie schnell ist das Board?** Vier kleine Aufgaben (das Sieb des Eratosthenes, CRC-32,
  Divisionen, Aufrufe einer Funktion), auf jedem Board dieselbe Arbeit, mit der Zeit für jede und der Summe; es läuft
  auch unter Windows, als Maßstab.
- `esp32/clockspeed.abel`, `esp32s3/clockspeed.abel`, `esp32c3/clockspeed.abel`, `pico/clockspeed.abel`,
  `pico2/clockspeed.abel`: **Dieselbe Arbeit bei jedem Takt.** Misst die Zeit einer Schleife bei jedem Takt des
  Kerns; `cpu_clock` aus `cpuclock.abel` setzt den Takt (ESP32 1 bis 240 MHz, ESP32-S3 10 bis 240 MHz, ESP32-C3 10
  bis 160 MHz, Pico 48 bis 133 MHz, Pico 2 48 bis 150 MHz). Am Ende stellt es den Takt wieder ein, den es vorgefunden
  hat.
- `esp32/slowclock.abel`, `pico/slowclock.abel`, `pico2/slowclock.abel`: **Blinken bei wenigen kHz.** Die LED blinkt
  einmal je Sekunde, auch wenn `cpu_clock_khz` den Kern auf etwa 5 kHz (ESP32) oder 1 kHz (Pico, Pico 2) bringt; das
  Programm zählt dafür Takte statt Millisekunden. Auf dem ESP32 vorher `wlan off`.
- `esp32/setclock.abel`, `esp32s3/setclock.abel`, `esp32c3/setclock.abel`, `pico/setclock.abel`,
  `pico2/setclock.abel`: **Den Takt der Konsole setzen.** Der Takt gilt dann für die Konsole und jedes Programm
  danach, bis zum Reset: hochladen, dann `setclock 240` (ESP32, ESP32-S3), `setclock 160` (ESP32-C3), `setclock 133`
  (Pico) oder `setclock 150` (Pico 2) in der Konsole; `setclock` allein zeigt den Takt, `info` und der Board Manager
  zeigen ihn auch.

## Für ein Board

Programme für ein Board, weil sie seine Hardware nutzen: Pins, Sensoren, sein Display.

- `esp32/bme280.abel`: **Der Sensor BME280.** Temperatur, Luftdruck und Luftfeuchte eines Sensors BME280 (oder
  BMP280, ohne Feuchte) am I2C-Bus, alle zwei Sekunden (SDA an GPIO 21, SCL an GPIO 22; I2C von Hand über die Pins);
  `bme280 5` in der Konsole misst fünfmal.
- `esp32/bme280_sleep.abel`: **Messen im Light Sleep.** Dieselben Messungen alle zehn Sekunden, dazwischen der ESP32
  im Light Sleep (wach etwa 10 ms der zehn Sekunden; der RTC-Timer weckt ihn, eine Taste beendet es). Es schaltet
  vorher das WLAN ab: Das übersteht den Schlaf nicht.
- `esp32/bme280_deep.abel`: **Messen im Deep Sleep.** Eine Messung, dann eine Minute Deep Sleep, immer wieder; der
  Chip ist pro Messung etwa 150 ms wach, was es sich merken muss (Anzahl, Zeit, tiefste und höchste Temperatur),
  liegt im langsamen Speicher der RTC. Vorher hochladen und als Autostart-Programm setzen (`boot bme280_deep`); zum
  Beenden BOOT gedrückt halten (oder den COM-Port neu öffnen, oder EN und dann eine Taste), danach `noboot`.
- `esp32/tdisplay.abel`: **Das Display des T-Display.** Das Farbdisplay des LilyGO TTGO T-Display (ST7789V, 240 x
  135): Farbbalken, „Hello, world!“ in einer 5x7-Schrift (ein- bis dreifach vergrößert), die beiden Tasten (GPIO 0
  und 35) mit ihren Zählern; SPI von Hand über die Pins.
- `esp32/tdisplay_spi.abel`: **Das Display über SPI.** Dasselbe Bild über VSPI, die SPI-Einheit des ESP32, mit 40
  MHz: das ganze Bild in 14 ms statt 350 ms von Hand.
- `esp32s31/rgbblink.abel`: **Die RGB-LED.** Lässt die RGB-LED des ESP32-S31-Boards (eine WS2812 an GPIO 60) über
  `rgb()` seiner Konsole blinken; oben `COLOUR` für die Farbe setzen.

## In Assembler

Strg+F9 assembliert eine Datei zum Programm daneben, F9 startet es im Debugger (F5 setzt einen Breakpoint, F8/F7
gehen Schritt für Schritt).

- `windows_intel/demo.asm`: **Von 1 bis 5 zählen.** Zählt von 1 bis 5 und schreibt eine Zeile je Zahl (i386, ein
  Konsolenprogramm für Windows, `printf` aus `msvcrt.dll`).
- `windows_arm/hello_arm32.asm`: **Hello, World auf Windows on ARM.** „Hello, World!“ für Windows on ARM (Thumb-2,
  PE, Machine ARMNT); Dismonite debuggt es auf einem Windows-on-ARM-Rechner (der Debug-Server `asmodbg`, siehe die
  README der ZIP-Datei).
- `dos/hello_exe.asm`: **Eine DOS-.EXE von Hand.** „Hello, World!“ als DOS-Programm (.EXE): der Kopf der Datei von
  Hand geschrieben und erklärt, und was eine .EXE von einer .COM unterscheidet; F9 startet es in QEMU mit FreeDOS
  (vorher einmal `qemu\run_freedos.bat`).

<!-- EXAMPLES_END -->

Englisch: [README.md](README.md).
