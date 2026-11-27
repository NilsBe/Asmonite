# Die Konsole

Die Konsole ist eine kleine Shell auf dem Board, kein Interpreter. Asmonite schreibt sie in den Flash des Boards
(**Prepare Board...** im Board Manager, siehe [board-manager.md](board-manager.md)). Ab dann meldet sich das Board an
seinem seriellen Port mit einem Prompt `>`, wie ein kleiner Rechner: Es hat Dateien im Flash, startet Programme über
ihren Namen, verbindet sich mit dem WLAN und antwortet im Netz. Die Konsole bleibt im Flash und ist nach jedem
Programm und jedem Reset wieder da. Sie ist klein: beim ESP32 etwa 16 KB.

Asmonite selbst arbeitet über sie: F9 bringt dein Programm über die Konsole ins RAM des Boards, der Debugger hält es
dort an, und der Board Manager zeigt die Dateien und das WLAN, indem er die Konsole fragt.

## Eine Sitzung

Auf einem ESP32, im Reiter **Serial** von Asmonite oder in jedem Terminalprogramm (115200 Baud). Netz, Adresse, Name
und MAC sind hier ersetzt.

```text
> info
Chip: ESP32 (Xtensa LX6), core at 160 MHz
Flash: 4 MB (JEDEC id 68 40 16)
MAC of the station: xx:xx:xx:xx:xx:xx
Console: Asmonite console 2
> ls
  help.txt                 960
  hello                   3424
  blink                   3776
  ping                   42400
  setclock               11424
5 file(s), 61984 bytes
> df
5 file(s), 69632 bytes in use, 2019328 bytes free
> run hello
Running hello
Hello, world!

Program ended (code 0).
> run blink
Running blink
blink: the LED of the board, every half second (Ctrl+C ends it)
Program stopped (Ctrl+C).
> setclock 240
the core runs at 240 MHz now, also after this program (until a reset)
> wlan
WiFi network: HomeNet (WPA2)
The WiFi is on and connected.
> name
The name of the board: esp32-lab (esp32-lab.local)
> boot
No autostart.
```

`hello`, `blink`, `ping` und `setclock` sind keine Befehle der Konsole: Es sind Programme in ihrem Flash, von Asmonite
aus aBelle (eine Python-ähnliche Programmiersprache) übersetzt. `setclock 240` startet das Programm `setclock` mit dem
Argument `240`.

## Konsole oder REPL?

MicroPython, CircuitPython oder Espruino bringen einen Interpreter auf das Board: An ihrem Prompt (dem REPL) tippst du
Zeilen in Python oder JavaScript, und das Board führt sie sofort aus. Die Konsole von Asmonite ist dagegen eine Shell:

| | Ein REPL (MicroPython) | Die Konsole von Asmonite |
|---|---|---|
| Was du tippst | Zeilen einer Programmiersprache | Befehle mit Argumenten: `ls`, `run blink`, `wlan set` |
| Was läuft | der Interpreter liest dein Programm, während es läuft | dein Programm, für den Chip übersetzt (aBelle oder Assembler), mit dem vollen Tempo des Kerns |
| Dateien | meist über ein Werkzeug am PC (mpremote, Thonny) | `ls`, `cat`, `rm`, `df` auf dem Board; hoch- und herunterladen im Board Manager |
| Programme | Skripte, die der Interpreter ausführt | Dateien, die neue Befehle sind: `name argumente` |
| Platz auf dem Board | die Firmware mit dem Interpreter (einige hundert KB bis über 1 MB) | die Konsole, beim ESP32 etwa 16 KB; dein Programm kommt dazu |
| Debuggen | `print` | Breakpoints, Schritte, Register und Variablen in Asmonite, über dasselbe USB-Kabel |

## Die Befehle

| | Befehl | Was er tut |
|---|---|---|
| Dateien | `ls` | die Dateien mit ihrer Größe |
| | `cat name` | zeigt eine Datei |
| | `rm name` | löscht eine Datei |
| | `df` | der Platz im Flash |
| | `format` | ein neues, leeres Dateisystem (alle Dateien gehen verloren) |
| Programme | `run name` | startet ein Programm |
| | `name argumente` | dasselbe, mit Argumenten: Jedes Programm im Flash ist ein Befehl |
| | `boot name` | startet das Programm nach jedem Reset (`boot` allein: welches) |
| | `noboot` | kein Programm nach einem Reset |
| Netz | `wlan` | das WLAN: `wlan set` (Netz und Passwort), `wlan on`, `wlan off`, `wlan clear`, `wlan scan` |
| | `name` | der Name des Boards im Netz, `name.local` (`name set`, `name clear`) |
| | `passwd` | das Passwort für telnet (`passwd set`, `passwd clear`) |
| System | `info` | der Chip, sein Takt, der Flash, die MAC, die Version der Konsole |
| | `reset` | startet den Chip neu |
| | `help` | die Liste der Befehle (die Datei `help.txt` auf dem Board) |

**Strg+C** hält das laufende Programm an (im Reiter Serial: der Knopf **Stop**); beim ESP32 sogar eine Endlosschleife
mit gesperrten Interrupts. Nach einem Reset wartet die Konsole kurz: Eine Taste im Terminal (oder BOOT) hält sie am
Prompt, auch wenn ein Programm im Autostart steht; **Reset** im Board Manager tut das auch.

## Programme als Befehle

Ein Programm auf dem Board hat keine Endung: Aus `blink.abel` wird `blink`. Ein Wort, das die Konsole nicht kennt,
sucht sie als Datei; gibt es sie, startet sie das Programm, und der Rest der Zeile sind seine Argumente (aBelle:
`args()`). Als Befehl sagt die Konsole nichts davor und danach, nur einen Fehlercode, eine Ausnahme oder Strg+C. So
wächst die Konsole, ohne größer zu werden: Die Netzwerkprogramme der Beispiele (`ping`, `dns`, `ntp` …) und `setclock`
sind solche Programme. Das Programm im Editor kommt mit **Project > Compile and Upload** (Strg+Shift+F9) auf das Board.

In den Flash schreibt ein Programm nur über Dateien. Es kann weder die Konsole noch das Dateisystem beschädigen.

## Was sie im Hintergrund tut

- **Sie antwortet im Netz:** auf Ping und auf `name.local` (mDNS), auf den meisten Boards auch, während ein Programm
  läuft (die Tabelle unten sagt, wo).
- **Sie holt Programme zum Prompt zurück:** Endet ein Programm, mit `exit`, durch eine Ausnahme (die Konsole sagt, wo
  und warum) oder mit Strg+C, ist die Konsole wieder da, mit ihren Dateien und ihrem WLAN.
- **Sie startet ein Programm nach dem Reset,** wenn `boot` eines nennt: für ein Board, das allein läuft.

## Wie du sie erreichst

- **Der Reiter Serial** von Asmonite neben der Ausgabe: Er verbindet sich von selbst mit dem Board.
- **Jedes Terminalprogramm** mit 115200 Baud (PuTTY, der serielle Monitor der Arduino IDE …).
- **Der Board Manager:** dasselbe mit Knöpfen und Menüs (Dateien, Run, Autostart, WLAN, Takt).
- **telnet** über das WLAN: das Programm `telnetd` der Beispiele (ESP32, ESP32-S3, Pico W), mit dem Passwort von
  `passwd`.

## Was einen Reset übersteht

| Bleibt | Ist weg |
|---|---|
| die Dateien, die Konsole selbst | ein Programm, das F9 ins RAM geladen hat |
| das Programm im Autostart (`boot`) | der Takt von `setclock` (wieder der Takt beim Start) |
| das WLAN-Netz und sein Passwort, der Name des Boards | was ein Programm nicht in eine Datei geschrieben hat |

## Welches Board was kann

| | ESP32 | ESP32-S3 | Pico, Pico 2 (W) | ESP32-C3 | ESP32-S31 |
|---|---|---|---|---|---|
| Dateien, Programme, `boot`, `info`, `reset`, `help` | ✓ | ✓ | ✓ | ✓ | ✓ |
| `run name argumente` | – (`name argumente`) | – (`name argumente`) | ✓ | – (`name argumente`) | – (`name argumente`) |
| `wlan`, `wlan scan`, `name` | ✓ | ✓ | ✓ (W) | ✓ | ✓ |
| `passwd` (telnet) | ✓ | ✓ | ✓ (W) | – | – |
| antwortet auf Ping, während ein Programm läuft | ✓ | ✓ | ✓ (W) | ✓ | ✓ |
| `name.local`, während ein Programm läuft | – (am Prompt) | – (am Prompt) | ✓ (W) | ✓ | ✓ |

Ein Pico oder Pico 2 ohne WLAN-Chip hat keine Befehle für das Netz. Alle Einzelheiten je Board:
[boards.md](boards.md), Abschnitt „Was die Konsolen können“.

## Für Programmierer: die Funktionen der Konsole

Ein Programm, das die Konsole startet, kann sie aufrufen: `exit`, `put_char`, `get_char`, `poll_char`, `print`,
`millis`, `file_size`, `file_read`, `file_write`, `flash_read`, `args` (die Picos auch `led` und `wl_call`). In aBelle
bringt `include "console.abel"` sie, dazu `println`, `print_int` und die anderen Ausgaben; das Beispiel
`examples/common/runs.abel` zählt in der Datei `runs.txt`, wie oft es lief. In Assembler sind sie eine Tabelle von
Sprüngen an einer festen Adresse: [esp32.md](esp32.md) (ESP32, `0x4009C800`), [esp32c3.md](esp32c3.md),
[riscv-pico2.md](riscv-pico2.md) (Pico und Pico 2).

## Was sie (noch) nicht hat

- Keine Liste der getippten Zeilen (Pfeil nach oben) und keine Ergänzung mit Tab.
- Keine Skripte, keine Pipes, kein `if` und keine Schleifen am Prompt: Dafür sind Programme da.
- Keine Ordner: Das Dateisystem hat eine Liste von Dateien.
- Keinen Befehl, um eine Datei einzutippen: Dateien kommen vom PC (Board Manager) oder von Programmen (`file_write`).
