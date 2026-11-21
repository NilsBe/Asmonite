# Beispiele

Die Beispiele von Asmonite, in Assembler und in aBelle. Jedes hier ist noch einmal durchgesehen und auf den Boards
getestet, für die es gedacht ist; weitere folgen nach und nach.

- `common/`: Programme in aBelle, die auf jedem Board laufen (ESP32, ESP32-S3, ESP32-C3, ESP32-S31, Raspberry Pi
  Pico und Pico 2 (W)); Asmonite übersetzt sie für das Board, das du benutzt. Was sie mit `include` einbinden
  (`console.abel`, `net.abel`), ist die Bibliothek von aBelle in [`abelle/lib`](../abelle/lib): `common/` für jedes
  Board, `<board>/` für eines; in der ZIP-Datei liegt sie neben den Compilern.
  - `common/hello.abel`: schreibt „Hello, world!“ über die serielle Ausgabe des Boards (F9).
  - `common/blink.abel`: lässt die LED des Boards blinken; vorher oben `LED_PIN` für dein Board setzen.
  - `common/runs.abel`: zählt, wie oft es gelaufen ist, in der Datei `runs.txt` auf dem Board (`file_size`,
    `file_read`, `file_write`); die Zahl bleibt auch ohne Strom. `cat runs.txt` in der Konsole zeigt sie,
    `rm runs.txt` fängt neu an.
  - `common/scan.abel`: die WLAN-Netze in der Nähe des Boards (Signal, Kanal, Schutz, BSSID, Name); für die Boards
    mit WLAN.
  - `common/arpscan.abel`: wer ist im Netz: fragt jede Adresse seines /24-Netzes per ARP und listet die Geräte, die
    antworten, mit ihrer MAC; das Board braucht ein Netz (`wlan set` in der Konsole).
  - `common/ping.abel`: pingt den Router und einen Server im Internet (je vier Echo-Anfragen) und zeigt die Zeiten
    wie der Ping eines PCs; mit einem Argument (`run ping 192.168.1.20` oder `run ping example.com`) diesen Host.
  - `common/pingled.abel`: die LED des Boards blitzt bei jedem Ping auf, den es beantwortet; die Adresse, die es
    zeigt, vom PC oder Handy aus pingen. Vorher oben `LED_PIN` für dein Board setzen; das Board braucht ein Netz
    (`wlan set` in der Konsole).
- `<board>/`: Programme nur für ein Board, weil sie seine Hardware nutzen (Pins, Sensoren, seine LED).
  - `esp32s31/rgbblink.abel`: lässt die RGB-LED des ESP32-S31-Boards (eine WS2812 an GPIO 60) über `rgb()` seiner
    Konsole blinken; oben `COLOUR` für die Farbe setzen.

Englisch: [README.md](README.md).
