# Der Board Manager

Der Board Manager ist die Zentrale für deine Boards. Hier bereitest du ein neues Board vor, legst Dateien und
Programme darauf, stellst das WLAN und den Takt ein und siehst, was Asmonite über das Board weiß. Du öffnest ihn über
**Board > Board Manager**. Steckst du ein Board zum ersten Mal ein, öffnet er sich von selbst.

Er arbeitet mit dem ESP32, dem ESP32-S3, dem ESP32-C3, dem ESP32-S31, dem Raspberry Pi Pico und dem Pico 2 (mit und
ohne W), jeweils über das USB-Kabel des Boards. Bei jedem Board zeigt er nur, was mit ihm geht.

## Ein neues Board in drei Schritten

1. **Einstecken.** Einen Pico oder Pico 2 steckst du beim ersten Mal mit gedrückter Taste **BOOTSEL** ein (ein neues,
   leeres Board braucht sie nicht); Windows zeigt dann ein Laufwerk `RPI-RP2` oder `RP2350`. Ein ESP-Board steckst du
   einfach ein.
2. **Prepare Board...** klicken. Asmonite schreibt seine Konsole in den Flash des Boards, legt ein Dateisystem an,
   wenn es noch keins gibt, und bringt bei einem ESP-Board das WLAN-Paket mit. Beim ESP32 dauert das etwa eine
   halbe Minute. Kommt ein ESP32 nicht von selbst in seinen Download-Modus, bittet Asmonite dich, **BOOT** gedrückt zu
   halten.
3. **Fertig.** Der Board Manager zeigt jetzt die Dateien des Boards. Ab jetzt startet F9 deine Programme auf dem Board,
   und der Debugger läuft über dasselbe Kabel.

Die Konsole bleibt im Flash und ist nach jedem Reset wieder da. Bringt ein neueres Asmonite eine neuere Konsole mit,
sagt es die Zeile *Console*; **Prepare Board...** schreibt sie dann neu, deine Dateien bleiben.

## Das Fenster

| Wo | Was |
|---|---|
| links oben | die angesteckten Boards; **Scan** sucht neu |
| links unten | ein Foto des gewählten Boards |
| rechts oben | was Asmonite über das Board weiß (die Infozeilen, siehe unten) |
| rechts darunter | die Dateien auf dem Board |
| unten | die Knöpfe für das Board |

Beim Öffnen liest der Board Manager nur, was das Board nicht stört: was Windows über das USB-Gerät sagt und was die
Konsole von Asmonite meldet. Ein laufendes Programm hält er nur an, wenn du etwas tust, wofür er die Konsole braucht;
dann fragt er vorher.

## Die Infozeilen

Ein Rechtsklick auf eine Zeile zeigt, was mit ihr geht; ein Doppelklick wählt den ersten Punkt. **Copy Line** und
**Copy All** kopieren eine Zeile oder alle.

| Zeile | Was sie sagt | Rechtsklick |
|---|---|---|
| *Console* | die Version der Konsole auf dem Board und die dieses Asmonite („v5 (current: v5)“) | bei einer älteren: **Prepare Board...** schreibt die aktuelle |
| *CPU clock* | der Takt des Kerns | **Set the Clock...**: ein Takt aus der Liste des Boards, bis zum nächsten Reset (siehe [takt.md](takt.md)) |
| *WiFi* | aus, verbindet sich oder verbunden; Adresse und Name im Netz | **Set Network...**, **WiFi On**, **WiFi Off**, **Forget Network...**, **Set mDNS Name...** |
| *WiFi service* | die Version des WLAN-Pakets (ESP-Boards) | **Install WiFi...** schreibt das aktuelle |
| *telnet* | ob ein Passwort für telnet gesetzt ist | **Set Password...**, **Clear Password...** |

**Set Network...** listet die Netze, die dieser PC sieht, beim ESP32-C3, ESP32-S31 und Pico W auch die, die das Board
sieht; **From Windows** trägt das Passwort ein, das Windows für dieses Netz gespeichert hat.

**Set the Clock...** nutzt das Programm `setclock` auf dem Board. Fehlt es, kompiliert Asmonite
`examples/<board>/setclock.abel` und lädt es vorher hoch (nach Rückfrage). Ein Takt, bei dem das WLAN nicht läuft,
schaltet vorher das WLAN aus (auch nach Rückfrage).

## Dateien und Programme

Ein Rechtsklick auf eine Datei zeigt, was mit ihr geht:

| Punkt | Was er tut |
|---|---|
| **Run** (Enter, Doppelklick) | startet ein Programm; das Fenster schließt sich, der Reiter Serial zeigt, was es schreibt |
| **Open in Editor** (Enter, Doppelklick) | öffnet eine Textdatei im Editor (eine Kopie: eine Änderung bleibt auf dem PC) |
| **Autostart** / **No Autostart** | das Programm startet nach jedem Reset (die Spalte *After a reset*) |
| **Download...** | holt die Datei auf den PC |
| **Delete** (Entf) | löscht sie |
| **Upload File...** | legt eine Datei vom PC auf das Board (auch auf der leeren Liste) |
| **Refresh** (F5) | liest die Liste neu |

Dateien aus dem Explorer, auf das Fenster gezogen, lädt der Board Manager auf das Board. **Examples...** öffnet ein
Beispiel für das gewählte Board: aus `examples\common` (für jedes Board), aus dem Ordner des Boards oder die Übersicht
der Beispiele. Asmonite öffnet es im Editor und stellt bei aBelle **Project > aBelle for** auf das Board des Reiters Serial: F9
startet es dann dort.

Aus dem Editor kommen Programme so auf das Board:

| Im Editor | Was passiert |
|---|---|
| F9 | das Programm läuft im RAM des Boards, ohne eine Datei anzulegen |
| **Project > Compile and Upload** (Ctrl+Shift+F9) | das Programm kommt als Datei auf das Board (Name der Quelle ohne Endung) |
| **Debug > Upload and Run** (Shift+F9) | dasselbe, und die Konsole startet es danach |

## Die Knöpfe

| Knopf | Was er tut |
|---|---|
| **Prepare Board...** | die Konsole in den Flash, das Dateisystem, das WLAN-Paket (siehe oben) |
| **Reset** | startet das Board neu und hält es in der Konsole, auch wenn ein Programm im Autostart steht |
| **Chip Details** | ESP-Boards: Chip, Revision, MAC, Quarz, Flash (und PSRAM) über das Boot-ROM; das Board startet dafür neu |
| **Install WiFi...** | schreibt das WLAN-Paket neu (selten nötig) |
| **Format...** | ein neues, leeres Dateisystem; alle Dateien gehen verloren |
| **Erase Flash...** | löscht den ganzen Flash wie bei einem neuen Board; danach wieder **Prepare Board...** |
| **Examples...** | ein Beispiel für dieses Board öffnen |

Welche Knöpfe ein Board bekommt:

| Board | Knöpfe |
|---|---|
| ESP32, ESP32-S3 | **Reset**, **Chip Details**, **Prepare Board...**, **Install WiFi...**, **Format...**, **Erase Flash...** |
| ESP32-C3, ESP32-S31 | wie beim ESP32, sobald die Konsole läuft; ohne sie **Reset**, **Chip Details**, **Prepare Board...**, **Erase Flash...** |
| ESP32-S3 oder ESP32-C3, noch nicht erkannt (dieselbe USB-Kennung) | **Chip Details**, **Prepare Board...** |
| Pico, Pico 2 mit der Konsole | **Reset**, **Prepare Board...** (eine neue Konsole, ohne BOOTSEL), **Format...** |
| Pico im USB-Boot (BOOTSEL) | **Prepare Board...**, **Start Program** (verlässt den USB-Boot), **Erase Flash...** |
| Pico 2 im USB-Boot (BOOTSEL) | **Prepare Board...**, **Arm Cores...**, **RISC-V Cores...** |
| Klon „Pico W-2023“ (RP2040 mit ESP8285) | wie der Pico, dazu **Install WiFi (ESP8285)...** (das Board dafür mit gehaltener BOOT-Taste einstecken; die Rückfrage sagt wie) |
| ein Board, das Asmonite nicht kennt | keine Knöpfe; nur, was Windows über es sagt |

## Pico 2: Arm- oder RISC-V-Kerne

Der RP2350 des Pico 2 hat zwei Arm-Kerne und zwei RISC-V-Kerne; das Boot-ROM startet die, für die das Programm im
Flash ist. **RISC-V Cores...** und **Arm Cores...** schalten einen Pico 2 im USB-Boot um: Der Board Manager schreibt
das Beispiel `blink` der anderen Kerne als UF2-Datei auf sein Laufwerk, die LED blinkt. Die Konsole ist ein
Arm-Programm: **Prepare Board...** bringt sie und die Arm-Kerne zurück.

## Wenn etwas nicht klappt

| Was du siehst | Was hilft |
|---|---|
| „The Asmonite console does not respond“ | Ein Programm läuft, das Strg+C nicht anhält: **Reset**. Oder es ist keine Konsole im Flash: **Prepare Board...** |
| „The flash is empty (no console)“ | **Prepare Board...** |
| „No file system yet“ | **Format...** legt eins an |
| Die Zeile *Console* sagt „older version“ | **Prepare Board...** schreibt die aktuelle; die Dateien bleiben |
| Ein ESP32 kommt nicht in den Download-Modus | **BOOT** gedrückt halten, bis Asmonite weitermacht |
| Ein Pico erscheint nicht in der Liste | Ein Datenkabel nehmen (kein reines Ladekabel); ohne Konsole mit gedrückter **BOOTSEL** einstecken |
| Das WLAN fehlt nach einem Reset noch | Die Adresse kommt ein paar Sekunden später: **Refresh** (F5) |

Mehr zu den einzelnen Boards: [esp32.md](esp32.md), [esp32s3.md](esp32s3.md), [esp32c3.md](esp32c3.md),
[riscv-pico2.md](riscv-pico2.md) (Pico und Pico 2), [t-picoc3.md](t-picoc3.md); alle Boards im Überblick:
[boards.md](boards.md).

## Was sich Asmonite merkt

Asmonite merkt sich die Boards, die es gesehen hat, im Abschnitt `[Boards]` der Datei `Asmonite.ini` (an ihrer
USB-Seriennummer). Nur ein Board, das noch nicht darin steht, öffnet den Board Manager von selbst, auch beim Start von
Asmonite; liegt Asmonite im Hintergrund, blinkt es in der Taskleiste. Grenze: Zwei ESP32-DevKits mit dem
USB-Seriell-Chip CP2102 haben dieselbe Seriennummer („0001“); das zweite gilt darum schon als gesehen.
