# Den Takt des Kerns ändern (aBelle)

Ein aBelle-Programm kann den Takt des Prozessorkerns seines Boards selbst umstellen: schneller, wenn es viel zu
rechnen hat, langsamer, wenn es wenig zu tun hat und weniger Strom ziehen soll. Dafür gibt es zwei Funktionen in der
Datei `cpuclock.abel`:

- `cpu_clock(mhz)` stellt den Takt in ganzen MHz ein, im Bereich, in dem das Board normal arbeitet. `millis()`, das
  Terminal und das WLAN laufen dabei richtig weiter.
- `cpu_clock_khz(khz)` geht bis hinunter zu wenigen kHz. Dort gelten Einschränkungen (siehe unten): Beim ESP32
  schweigt das Terminal, und `millis()` zählt nicht mehr richtig.

Der Takt bleibt nach dem Programm: Die Konsole läuft mit dem Takt weiter, den ein Programm hinterlässt, und jedes
folgende Programm startet damit, bis ein anderes Programm ihn ändert oder das Board neu startet. So stellt man den Takt
der Konsole ein; `info` in der Konsole und die Zeile **CPU clock** im Board Manager zeigen ihn. Ein Programm, das einen
Takt nur für eine Weile braucht, merkt sich am Anfang den vorgefundenen (`cpu_clock(0)`) und stellt ihn am Ende wieder
ein. Nur Takte, bei denen die Konsole nicht mehr erreichbar wäre, behält sie nicht: beim ESP32 unter 1 MHz (dann
40 MHz), beim ESP32-S3 und ESP32-C3 unter 10 MHz (dann 40 MHz), beim Pico und Pico 2 die Takte vom Quarz unter 48 MHz
(dann 48 MHz); der ESP32-S31 behält jeden.

Das geht auf dem **ESP32**, dem **ESP32-S3**, dem **ESP32-C3**, dem **ESP32-S31**, dem **Raspberry Pi Pico** und dem
**Raspberry Pi Pico 2** (auch mit W).

## Ein erstes Beispiel

```
target "esp32"

include "console.abel"
include "cpuclock.abel"

def main():
    print("der Takt jetzt: ")
    print_int(cpu_clock(0))
    println(" MHz")
    cpu_clock(240)
    # ... rechnen, so schnell es geht ...
    cpu_clock(10)
    # ... warten, sparsam ...
```

`include "cpuclock.abel"` steht nach `include "console.abel"`. Asmonite nimmt die Datei des Boards aus
`abelle/lib/<board>/`. Sie ist eine eigene Datei und nicht Teil von `console.abel`, weil aBelle jede Funktion einer
eingebundenen Datei übersetzt: Jedes Programm wäre sonst um mehrere KB größer, auch wenn es den Takt nie ändert.

Fertige Beispiele: `examples/esp32/clockspeed.abel`, `examples/esp32s3/clockspeed.abel`,
`examples/esp32c3/clockspeed.abel`, `examples/esp32s31/clockspeed.abel`, `examples/pico/clockspeed.abel` und
`examples/pico2/clockspeed.abel` lassen dieselbe Arbeit bei jedem Takt laufen und zeigen, wie lange sie dauert.
`slowclock.abel` in den Ordnern des ESP32 und der Picos lässt die LED bei jedem Takt einmal pro Sekunde blinken, bis
hinunter zu 5 kHz (ESP32) bzw. 1 kHz (Pico, Pico 2), und misst die Zeit dabei mit gezählten Takten (siehe
[Zeit ohne `millis()`](#zeit-ohne-millis)); für den ESP32-S3 und den ESP32-C3 gibt es dieses Beispiel nicht, ihr Takt
geht nur bis 10 MHz hinunter, und beim ESP32-S31 nicht, seine RGB-LED braucht einen hohen Takt. `setclock.abel` stellt
den Takt der Konsole ein: hochladen, dann in der Konsole `setclock 240` (ESP32, ESP32-S3), `setclock 160` (ESP32-C3),
`setclock 320` (ESP32-S31), `setclock 133` (Pico) oder `setclock 150` (Pico 2); `setclock` ohne Zahl zeigt den Takt.

## Die Funktionen

### `cpu_clock(mhz)`

| Aufruf | Ergebnis |
|---|---|
| `cpu_clock(0)` | fragt nur: der Takt jetzt in MHz (unter 1 MHz: 0) |
| `cpu_clock(mhz)` mit einem Wert, den das Board kann | stellt ihn ein, gibt den neuen Takt zurück |
| ein anderer Wert | -1, nichts ändert sich |

### `cpu_clock_khz(khz)`

| Aufruf | Ergebnis |
|---|---|
| `cpu_clock_khz(0)` | fragt nur: der Takt jetzt in kHz, auch unter 1 MHz |
| ein Wert im Bereich des Boards | stellt den nächstmöglichen Takt ein und gibt ihn in kHz zurück |
| ein Wert außerhalb | -1, nichts ändert sich |

Ab 1000 kHz (ESP32, ESP32-S31), ab 10000 kHz (ESP32-S3, ESP32-C3) bzw. ab 48000 kHz (Pico, Pico 2) ruft
`cpu_clock_khz` einfach `cpu_clock` mit den ganzen MHz auf; der Wert muss dann einer sein, den `cpu_clock` kann. Darunter teilt die Funktion eine Taktquelle durch eine ganze Zahl
und nimmt den Teiler, der dem gewünschten Wert am nächsten kommt. Deshalb ist der Rückgabewert wichtig: Er sagt, was
wirklich eingestellt ist (beim Pico ergibt `cpu_clock_khz(2500)` zum Beispiel 2400).

Zurück zu einem normalen Takt geht es mit `cpu_clock(mhz)` (oder `cpu_clock_khz` mit einem Wert ab 1 MHz bzw.
48 MHz). Endet das Programm mit einem der tiefen Takte, stellt die Konsole ihren Standardtakt her (siehe oben).

## ESP32

### Die Takte

| Takt | Quelle | mit `cpu_clock` | mit `cpu_clock_khz` | bei laufendem WLAN |
|---|---|---|---|---|
| 240, 160, 80 MHz | PLL | ✓ | ✓ (240000, 160000, 80000) | ✓ |
| 40, 20, 10, 8, 5, 4, 2, 1 MHz | Quarz (40 MHz geteilt durch 1 … 40) | ✓ | ✓ (40000 … 1000) | – |
| 975 kHz bis 39 kHz | Quarz geteilt durch 41 … 1024 | – | ✓ | – |
| unter 39 kHz bis etwa 5 kHz | interner Oszillator RC_FAST, geteilt durch bis zu 1024 | – | ✓ | – |

Nach einem Reset läuft die Konsole mit 40 MHz, mit WLAN mit 160 MHz.

- **WLAN:** Das WLAN braucht den PLL, also mindestens 80 MHz. Läuft der WLAN-Dienst, geben alle Takte vom Quarz -1.
  Vorher in der Konsole `wlan off`, danach `wlan on`. Zwischen 80, 160 und 240 MHz bleibt die Verbindung bestehen;
  dafür braucht das Board den WLAN-Dienst ab Version 12 (Board Manager: **Install WiFi...**).
- **`millis()` und das Terminal:** Bei jedem Takt ab 1 MHz laufen sie richtig weiter. Die Bibliothek rechnet bei jedem
  Wechsel den Teiler des UART um, damit die Baudrate gleich bleibt, und sagt dem ROM, wie viele Takte eine
  Mikrosekunde hat.
- **Unter 1 MHz** lassen sich 115200 Baud aus dem Takt nicht mehr erzeugen: Das Terminal schweigt. Was ein Programm
  vorher ausgegeben hat, ist schon draußen (`cpu_clock_khz` wartet, bis der UART alles gesendet hat). Zurück bei 1 MHz
  oder mehr ist das Terminal wieder da. Aus demselben Grund kommt unter 1 MHz auch kein Ctrl+C an (nicht getestet, aber
  der UART empfängt dann mit der falschen Baudrate): Das Programm muss selbst zurückkehren, sonst hilft nur ein Reset.
  `millis()` zählt unter 1 MHz falsch; ein Programm, das dort Zeit messen will, zählt Takte (siehe
  [Zeit ohne `millis()`](#zeit-ohne-millis)).
- **RC_FAST** ist ein Oszillator im Chip ohne Quarz. Laut Datenblatt hat er etwa 8 MHz; gemessen waren es auf dem
  ESP32 DevKit etwa 5,2 MHz, und der Wert schwankt von Chip zu Chip und mit der Temperatur. Die Bibliothek misst ihn
  beim ersten Gebrauch gegen den Quarz aus (mit der Kalibrierung von Timergruppe 0), damit der Rückgabewert stimmt.
  Unterhalb von 39 kHz sind die Takte deshalb nur so genau wie diese Messung.
- **Die Konsole nach dem Programm:** Sie behält jeden Takt ab 1 MHz, auch nach Ctrl+C, einem Absturz oder dem
  Debugger; die Bibliothek hat den Teiler des UART und die Takte pro Mikrosekunde schon passend gestellt, das Terminal
  und `millis()` laufen also weiter. Endet ein Programm unter 1 MHz, schaltet die Konsole auf 40 MHz vom Quarz zurück.
  Schaltet man das WLAN bei einem Quarztakt mit `wlan on` ein, stellt der WLAN-Dienst selbst 160 MHz ein.

### Gemessen

Dieselbe Arbeit (eine Schleife, `clockspeed`) bei jedem Takt, die Zeiten mit `millis()`, und 3 s nach `millis()` vom PC
nachgemessen:

| Takt | 240 MHz | 160 MHz | 80 MHz | 40 MHz | 20 MHz | 10 MHz | 5 MHz | 2 MHz | 1 MHz |
|---|---|---|---|---|---|---|---|---|---|
| Zeit | 54 ms | 81 ms | 161 ms | 322 ms | 645 ms | 1290 ms | 2581 ms | 6450 ms | 12900 ms |
| 3 s nach `millis()`, am PC | 2994 ms | 3000 ms | 2999 ms | 2985 ms | 2987 ms | 3010 ms | 3003 ms | 3000 ms | 2995 ms |

Unter 1 MHz, am PC gemessen (die Zeit zwischen einer Zeile vor und einer Zeile nach der langsamen Phase, etwa 1 s):

| eingestellt | 975 kHz | 500 kHz | 100 kHz | 39 kHz | 20 kHz | 6 kHz | 5 kHz |
|---|---|---|---|---|---|---|---|
| Quelle | Quarz | Quarz | Quarz | Quarz | RC_FAST | RC_FAST | RC_FAST |
| gemessen | 973 kHz | 498 kHz | 99 kHz | 38 kHz | 19 kHz | 5,0 kHz | 4,1 kHz |

Je tiefer der Takt, desto mehr zählt das Umschalten selbst mit (etwa 1000 Takte, bei 5 kHz eine Fünftelsekunde); der
Takt in der langsamen Phase stimmt.

## ESP32-S3

### Die Takte

| Takt | Quelle | mit `cpu_clock` | mit `cpu_clock_khz` | bei laufendem WLAN |
|---|---|---|---|---|
| 240, 160, 80 MHz | PLL | ✓ | ✓ (240000, 160000, 80000) | ✓ |
| 40, 20, 10 MHz | Quarz (40 MHz geteilt durch 1, 2, 4) | ✓ | ✓ (40000, 20000, 10000) | – |
| unter 10 MHz | – | – (-1) | – (-1) | – |

Nach einem Reset läuft die Konsole mit 40 MHz, mit WLAN mit 160 MHz. `cpu_clock_khz` kann hier nur die ganzen MHz, die
auch `cpu_clock` kann.

- **Nicht unter 10 MHz:** Die Konsole des S3 spricht über den USB-Anschluss des Chips (USB-Serial-JTAG). Läuft der Kern
  vom Quarz, bekommt der Bus der Peripherie (APB) denselben Takt wie der Kern, und dieser USB-Teil braucht mindestens
  10 MHz davon. Beobachtet: Bei 8, 5 und 4 MHz kamen Zeichen doppelt beim PC an, bei 2 und 1 MHz hörte der Port ganz auf
  zu arbeiten, auch wenn das Programm in der Zeit nichts ausgab; dann half nur ein Reset oder das Board neu
  einzustecken. Deshalb gibt `cpu_clock` unter 10 MHz -1, und tiefe Takte wie beim ESP32 gibt es auf dem S3 nicht.
- **WLAN:** Das WLAN braucht den PLL. Läuft der WLAN-Dienst, geben 40, 20 und 10 MHz -1. Vorher in der Konsole
  `wlan off`, danach `wlan on`. Zwischen 80, 160 und 240 MHz bleibt die Verbindung bestehen, und ein Neustart des WLAN
  behält den Takt. Dafür braucht das Board den WLAN-Dienst ab Version 13 (Board Manager: **Install WiFi...**).
- **240 MHz** braucht eine Stufe mehr Spannung am Kern. `cpu_clock` hebt sie vor dem Wechsel zu 240 MHz an und senkt
  sie nach dem Wechsel von 240 MHz wieder (siehe [Wie es innen arbeitet](#wie-es-innen-arbeitet)).
- **`millis()` und das Terminal** laufen bei jedem Takt richtig weiter. Der PLL bleibt bei jedem Takt an, auch wenn der
  Kern vom Quarz läuft, weil der USB-Anschluss seine 48 MHz von ihm bekommt.
- **Die Konsole nach dem Programm:** Sie behält jeden Takt ab 10 MHz, auch nach Ctrl+C. Steht der Kern doch einmal
  tiefer, schaltet sie auf 40 MHz vom Quarz zurück (`boards/esp32s3/console_clock.asm`).

### Gemessen

Dieselbe Arbeit wie beim ESP32 (`clockspeed`), die Zeiten mit `millis()`; nachgeprüft mit dem SYSTIMER des Chips, der
vom Quarz zählt und vom Takt des Kerns nichts merkt:

| Takt | 240 MHz | 160 MHz | 80 MHz | 40 MHz | 20 MHz | 10 MHz |
|---|---|---|---|---|---|---|
| Zeit | 15 ms | 24 ms | 46 ms | 93 ms | 185 ms | 370 ms |

Mit verbundenem WLAN, bei jedem Wechsel zwischen 80, 160 und 240 MHz: jeweils 4 von 4 Pings zum Router und eine
DNS-Abfrage.

## ESP32-C3

### Die Takte

| Takt | Quelle | mit `cpu_clock` | mit `cpu_clock_khz` | bei laufendem WLAN |
|---|---|---|---|---|
| 160, 80 MHz | PLL | ✓ | ✓ (160000, 80000) | ✓ |
| 40, 20, 10 MHz | Quarz (40 MHz geteilt durch 1, 2, 4) | ✓ | ✓ (40000, 20000, 10000) | – |
| unter 10 MHz | – | – (-1) | – (-1) | – |

Nach einem Reset läuft die Konsole mit 160 MHz, mit und ohne WLAN.

- **Nicht unter 10 MHz:** Die Konsole des C3 spricht wie die des S3 über den USB-Anschluss des Chips
  (USB-Serial-JTAG), und vom Quarz bekommt dessen Bus denselben Takt wie der Kern. Die Grenze von 10 MHz ist vom S3
  übernommen und auf dem C3 nicht eigens ausprobiert.
- **WLAN:** Das WLAN braucht den PLL. Läuft es, geben 40, 20 und 10 MHz -1; vorher in der Konsole `wlan off`. Zwischen
  80 und 160 MHz bleibt die Verbindung bestehen, und der erste Start des WLAN nach einem Reset behält einen Takt von
  80 MHz, den ein Programm eingestellt hat. Dafür braucht das Board den WLAN-Dienst ab Version 7 (Board Manager:
  **Install WiFi...**); mit einem älteren Dienst lehnt `cpu_clock` die Takte vom Quarz immer ab, weil es nicht
  erkennen kann, ob das WLAN läuft.
- **Keine Spannung zu ändern:** Anders als beim S3 braucht kein Takt des C3 eine andere Spannung am Kern. Die Konsole
  stellt beim Start die für 160 MHz ein, und dabei bleibt es.
- **`millis()` und das Terminal** laufen bei jedem Takt richtig weiter: `millis()` zählt einen Zeitgeber, der vom Quarz
  läuft, ebenso der 10-ms-Takt, mit dem der WLAN-Dienst seine Aufgaben erledigt, während ein Programm rechnet.
- **Die Konsole nach dem Programm:** Sie behält jeden Takt ab 10 MHz, auch nach Ctrl+C. Steht der Kern doch einmal
  tiefer, schaltet sie auf 40 MHz vom Quarz zurück (`boards/esp32c3/console_clock.asm`).

### Gemessen

Dieselbe Arbeit wie beim ESP32 (`clockspeed`), die Zeiten mit `millis()`, und 3 s nach `millis()` vom PC nachgemessen:

| Takt | 160 MHz | 80 MHz | 40 MHz | 20 MHz | 10 MHz |
|---|---|---|---|---|---|
| Zeit | 22 ms | 44 ms | 87 ms | 175 ms | 350 ms |
| 3 s nach `millis()`, am PC | 3021 ms | 2979 ms | 2999 ms | 2979 ms | 2995 ms |

Mit verbundenem WLAN, bei jedem Wechsel zwischen 80 und 160 MHz: jeweils 4 von 4 Pings zum Router und eine
DNS-Abfrage.

## ESP32-S31

### Die Takte

| Takt | Quelle | mit `cpu_clock` | mit `cpu_clock_khz` | bei laufendem WLAN |
|---|---|---|---|---|
| 320, 160, 80, 53 MHz | CPLL (320 MHz geteilt durch 1, 2, 4, 6) | ✓ | ✓ (320000 … 53333) | ✓ |
| 40, 20, 10, 8, 5, 4, 2, 1 MHz | Quarz (40 MHz geteilt durch 1 … 40) | ✓ | ✓ (40000 … 1000) | – |
| 975 kHz bis 156 kHz | Quarz geteilt durch 41 … 255 | – | ✓ | – |

Nach einem Reset läuft die Konsole mit 160 MHz. 53 MHz sind genau 53,3 MHz (`cpu_clock` gibt 53 zurück,
`cpu_clock_khz` 53333).

- **Der USB-Anschluss hängt nicht am Takt des Kerns:** Anders als beim ESP32-S3 und ESP32-C3 arbeitet die Konsole des
  S31 bei jedem Takt weiter. Ausprobiert bis 156 kHz: Ausgabe, `info`, `ls` und sogar das Hochladen eines Programms
  (bei 1 MHz 2,8 s statt 0,9 s). Deshalb behält die Konsole jeden Takt.
- **320 MHz** braucht eine Stufe mehr Spannung am Kern. `cpu_clock` hebt sie vor dem Wechsel an und lässt sie danach
  dort bis zum Reset (siehe [Wie es innen arbeitet](#wie-es-innen-arbeitet)). 240 MHz gibt es nicht: Dafür wäre ein
  zweiter PLL nötig, und 320 MHz sind ohnehin schneller.
- **WLAN:** Das WLAN braucht den PLL. Läuft es, geben die Takte vom Quarz -1; vorher in der Konsole `wlan off`.
  Zwischen 320, 160, 80 und 53 MHz bleibt die Verbindung bestehen. `wlan on` bei einem Takt vom Quarz schaltet zuerst
  auf 160 MHz zurück.
- **`millis()` und das Terminal** laufen bei jedem Takt richtig weiter, `millis()` zählt einen Zeitgeber vom Quarz.
  Unter 1 MHz rechnet das ROM mit einem Takt pro Mikrosekunde, seine Wartezeiten werden dort länger; `millis()` stimmt.
- **`info`** rechnet den Takt aus den Registern aus und zeigt unter 1 MHz kHz an („core at 156 kHz“); der Board
  Manager zeigt es ebenso.
- **Die RGB-LED** (die Funktion `rgb` der Konsole) braucht einen hohen Takt, etwa 160 MHz: Ihr Zeitverhalten ist in
  Takten des Kerns gemessen.

### Gemessen

Dieselbe Arbeit wie beim ESP32 (`clockspeed`), die Zeiten mit `millis()`; 3 s nach `millis()` am PC bei jedem Takt
von 160 MHz bis 156 kHz 2979 bis 3033 ms:

| Takt | 320 | 160 | 80 | 53 | 40 | 20 | 10 | 5 | 2 | 1 MHz |
|---|---|---|---|---|---|---|---|---|---|---|
| Zeit (ms) | 10 | 19 | 39 | 58 | 77 | 155 | 310 | 620 | 1550 | 3101 |

Bei 320 MHz liefen 2000 Rechnungen mit Prüfsumme (je 15 ms, mit viel Speicherzugriff) alle richtig. Mit verbundenem
WLAN, bei jedem Wechsel zwischen 320, 160, 80 und 53 MHz: jeweils 4 von 4 Pings zum Router und eine DNS-Abfrage.

## Raspberry Pi Pico und Pico 2

### Die Takte

| Takt | Quelle | mit `cpu_clock` | mit `cpu_clock_khz` |
|---|---|---|---|
| 48 MHz (der Takt der Konsole) | PLL_USB | ✓ | ✓ (48000) |
| jedes ganze MHz von 49 bis 133 (Pico) bzw. 150 (Pico 2) | PLL_SYS | ✓ | ✓ (in ganzen MHz) |
| 12000 kHz bis 1 kHz | Quarz, 12 MHz geteilt durch eine ganze Zahl: 12000, 6000, 4000, 3000, 2400, 2000 … 1 kHz | – | ✓ |
| zwischen 12 und 48 MHz | – | – | – (-1) |

133 MHz ist der höchste Takt, für den der RP2040 bei seiner Spannung gebaut ist, 150 MHz beim RP2350.

- **`millis()`, das Terminal und USB:** Der Zeitgeber (TIMER) zählt vom Quarz, der UART und der USB-Anschluss bekommen
  ihre 48 MHz direkt vom USB-PLL. Bei jedem Takt von `cpu_clock` merken sie nichts.
- **Unter etwa 1 MHz** steht `millis()`: Der Zeitgeber bekommt seine Mikrosekunden-Ticks aus dem Takt des Quarzes, und
  ein so langsamer Kern nimmt sie nicht mehr alle an. Das Terminal läuft weiter, bei wenigen kHz aber langsam.
- **USB bei den Takten vom Quarz:** Läuft clk_sys vom Quarz (12 MHz und weniger), kann der PC den COM-Port nicht neu
  öffnen; Windows meldet einen Zeitüberlauf („The semaphore timeout period has expired“, beobachtet bei 12 und 6 MHz
  und bei 1 kHz). Ein schon offener Port läuft weiter; Ctrl+C beendet ein Programm auch bei 1 kHz, nach 3 bis 4
  Sekunden. Nach einer Zeit unter ein paar MHz kann die nächste Ausgabe über USB außerdem etwa eine Sekunde später beim
  PC ankommen (beobachtet beim Pico, verloren geht nichts).
- **Pico W, Pico 2 W:** Die Konsole bedient das WLAN alle 10 ms über den SysTick-Zeitgeber, der mit dem Takt des Kerns
  zählt. Die Bibliothek stellt ihn bei jedem Takt neu ein; unter 1 MHz bekommt er seinen längsten Abstand, das WLAN
  wartet dann. Zurück bei 48 MHz oder mehr geht es weiter: Pings und DNS funktionierten nach 500, 10 und 1 kHz wie
  vorher. Die LED eines W hängt am WLAN-Chip, jedes Schalten ist ein Gespräch mit ihm von etwa 75 000 Takten: bei
  100 kHz fast eine Sekunde, bei 1 kHz über eine Minute.
- **Keine Division im tiefen Takt:** Der Cortex-M0+ des Pico hat keinen Divisionsbefehl, aBelle ruft dafür eine
  Funktion auf, die hunderte Takte braucht (auf dem Pico 2 ebenso: aBelle erzeugt für beide denselben Thumb-1-Code). Die
  Bibliothek rechnet deshalb alles, bevor sie heruntertaktet. Ein Programm, das bei 1 kHz eine Division macht, wartet
  darauf einige Zehntelsekunden.
- **Die Konsole nach dem Programm:** Sie behält jeden Takt vom PLL (48 MHz und mehr), auch nach Ctrl+C. Endet ein
  Programm mit einem Takt vom Quarz, schaltet sie clk_sys auf ihre 48 MHz vom USB-PLL zurück, setzt den Teiler auf 1,
  schaltet PLL_SYS ab und stellt SysTick wieder auf 10 ms; sonst wäre sie über USB nicht mehr zu erreichen.

### Gemessen

Dieselbe Arbeit wie beim ESP32 (`clockspeed`), 3 s nach `millis()` am PC jeweils 2985 bis 3012 ms:

| Takt | 48 MHz | 77 MHz | 100 MHz | 125 MHz | 133 MHz | 150 MHz |
|---|---|---|---|---|---|---|
| Pico (RP2040) | 269 ms | 167 ms | 129 ms | 103 ms | 97 ms | – |
| Pico 2 (RP2350) | 200 ms | 124 ms | 96 ms | – | 72 ms | 64 ms |

Mit `cpu_clock_khz`, am PC gemessen: 12000, 4000 und 1000 kHz stimmen auf etwa ein Prozent; darunter (500 kHz bis
1 kHz) liegen die Werte um die Takte des Umschaltens darunter, beim Pico kommt die gelegentliche Sekunde der
USB-Übertragung dazu. `millis()` auf dem Board bestätigt bei 2400 kHz die erwartete Zeit genau (1042 ms).

## Zeit ohne `millis()`

Unter 1 MHz ist `millis()` keine Hilfe mehr. Ein Programm kann dann Takte zählen: Es misst am Anfang bei vollem Takt,
wie lange eine Runde einer Schleife dauert, und rechnet daraus, wie viele Runden bei einem anderen Takt eine bestimmte
Zeit ergeben.

```
cyc100: i32[1]                  # die Takte einer Runde von count() * 100

def count(n):
    i = 0
    while i < n:
        i += 1

def main():
    t = millis()
    count(200000)                                   # bei 40 MHz gemessen
    cyc100[0] = (millis() - t) * 40000 / 2000       # ms * kHz = Takte; / 200000 Runden * 100
    khz = cpu_clock_khz(10)
    count(khz * 50000 / cyc100[0])                  # eine halbe Sekunde bei khz: khz * 500 Takte
    cpu_clock(40)
```

Beim Pico passt `khz * 50000` ab etwa 43 MHz nicht mehr in 32 Bit; dort rechnet man oberhalb von 20000 kHz
`khz / cyc100[0] * 50000`.

## Was man bedenken sollte

- **Strom:** Weniger Takt heißt weniger Strom, wie viel genau, ist noch nicht gemessen. Für lange Pausen ist ein
  Schlafmodus (beim ESP32 Light Sleep oder Deep Sleep, siehe `examples/esp32/bme280_sleep.abel`) oft sparsamer als ein
  tiefer Takt.
- **Ein eigener Teiler:** Die Takte unter 1 MHz kommen aus einem Teiler von höchstens 1024 (ESP32) bzw. aus einem
  ganzzahligen Teiler von 12 MHz (Pico). Wer einen bestimmten Wert braucht, nimmt den Rückgabewert, nicht den
  gewünschten Wert.
- **Ein Programm `cpuclock.abel` im eigenen Ordner** verdeckt die Bibliothek: `include` sucht zuerst im Ordner des
  Programms.
- **Debugger:** Den Takt unter dem Debugger zu ändern, ist nicht getestet. Beim ESP32 spricht der Debug-Monitor über
  den UART: Unter 1 MHz kann er an einem Breakpoint nicht antworten.

## Andere Boards

| Board | Stand |
|---|---|
| Raspberry Pi Pico W-2023 (Klon mit ESP8285) | die Bibliothek des Pico gilt; ungetestet ist das WLAN über den ESP8285 bei tiefem Takt |
| LilyGO T-PicoC3 | die RP2040-Seite wie ein Pico (ungetestet), die C3-Seite wie der ESP32-C3 |

## Wie es innen arbeitet

**ESP32.** Der Kern läuft entweder vom PLL oder vom Quarz (`SOC_CLK_SEL` im Register `RTC_CNTL_CLK_CONF`), unter 39 kHz
von RC_FAST. Der PLL läuft auf 320 MHz für 80 und 160 MHz (`CPUPERIOD_SEL` 0 oder 1) und auf 480 MHz für 240 MHz; bei
480 MHz ergibt jedes `CPUPERIOD_SEL` 240 MHz. Der Wechsel zu 240 MHz und zurück geht deshalb über den Quarz: den PLL
aus, neu einstellen (über den I2C-Bus im Chip, `rom_i2c_writeReg`), bei 480 MHz zuerst die Spannung des Kerns auf
1,25 V. Vom Quarz läuft der Kern mit 40 MHz / (`PRE_DIV_CNT` + 1), 10 Bit, also bis 1024. Mit jedem Wechsel des
APB-Takts wird der Teiler von UART0 umgerechnet (die Baudrate bleibt), ebenso der von Timer 0 des WLAN-Dienstes, und
`g_ticks_per_us` beider Kerne bekommt die neuen MHz (das ROM und `millis()` brauchen sie). RC_FAST braucht zusätzlich
das Bit `DIG_CLK8M_EN`, sonst bekommt der Kern keinen Takt und bleibt stehen. Am Ende eines Programms prüft die
Konsole nur, ob der Kern unter 1 MHz läuft (`PRE_DIV_CNT` 40 oder mehr, oder RC_FAST), und schaltet dann auf den Quarz
ungeteilt zurück; den Teiler des UART lässt die Bibliothek unter 1 MHz auf dem Wert für 40 MHz
(`boards/esp32/console_clock.asm`).

**ESP32-S3.** Wie ESP-IDF (`rtc_clk.c` und `clk_tree_ll.h` für den S3, mit einem Quarz von 40 MHz): Der PLL läuft auf
480 MHz und gibt 80, 160 und 240 MHz (`CPUPERIOD_SEL` 0, 1, 2 in `SYSTEM_CPU_PER_CONF`); der APB bekommt bei jedem davon
80 MHz. Vom Quarz läuft der Kern mit 40 MHz / (`PRE_DIV_CNT` + 1) (`SYSTEM_SYSCLK_CONF`; dort wählt `SOC_CLK_SEL` auch
zwischen Quarz und PLL). Der PLL bleibt immer an, ein Wechsel ist also nur: die LDO-Stufen für den neuen Takt
(`SLAVE_PD` in `RTC_CNTL_DATE`: 7 >> (MHz / 80), 7 beim Quarz), bei 240 MHz die Spannung des Kerns eine Stufe höher,
dann `CPUPERIOD_SEL`, der Teiler und `SOC_CLK_SEL`. Nach oben kommt die Spannung zuerst, nach unten zuletzt. Das ROM hat
ein einziges Wort für die Takte pro Mikrosekunde, für beide Kerne (`ets_update_cpu_frequency`); daraus rechnen
`ets_delay_us`, `millis()` der Konsole und der WLAN-Dienst. Timer 0 des WLAN-Dienstes zählt vom Quarz und merkt nichts.

Die Spannung steht in zwei Registern eines Analogblocks (`I2C_DIG_REG`, Block 0x6D: `EXT_RTC_DREG` und `EXT_DIG_DREG`,
Register 4 und 6, Bits 4 … 0), die nur über einen I2C-Bus im Chip erreichbar sind. Gemessen standen sie bei 24, für
240 MHz bei 25 (ESP-IDF nimmt dafür „dbias + 3“ statt „+ 2“). Zwei Dinge waren nötig, damit das fehlerfrei läuft:

- **Nicht über `rom_i2c_readReg`.** Diese ROM-Funktion springt über eine Tabelle von Funktionen im RAM des ROM (Zeiger
  bei 0x3FCEF3D4). Beim ersten Start des WLAN trägt die WLAN-Bibliothek dort ihre eigenen I2C-Funktionen ein, und das
  bleibt bis zum Reset so. Diese Funktionen brauchen aber einen Zeiger der Bibliothek (`g_phyFuns`), der nach jedem
  neuen Laden des WLAN-Dienstes 0 ist, bis der Funkteil wieder startet. Ein Wechsel zu oder von 240 MHz direkt nach
  `wlan on` stürzte deshalb ab (Exception 0x1C, Adresse 0x160). `cpu_clock` schreibt deshalb die Register des
  I2C-Masters (ab 0x6000E000) selbst, so wie es die Funktionen des ROM hinter der Tabelle tun.
- **Bei laufendem WLAN macht es der WLAN-Dienst.** Den I2C-Bus benutzt auch der Funkteil des WLAN, auf Kern 1; ESP-IDF
  schützt ihn mit einer Sperre über beide Kerne. Hier stellt der WLAN-Dienst die Spannung selbst ein (`wifi_dbias`, ab
  Version 13), auf Kern 1 zwischen den Tasks des WLAN: Die wechseln nur, wo sie warten, nie mitten in einem Zugriff auf
  den Bus. Während eines Verbindungsversuchs erledigt der Dienst einen solchen Auftrag sofort, `cpu_clock` muss also
  nicht auf die Verbindung warten.

Ein Neustart des WLAN stellt den Takt nicht mehr auf 160 MHz: Ab Version 13 behält der WLAN-Dienst einen Takt vom PLL,
wie beim ESP32 ab Version 12. Am Programmende prüft die Konsole nur, ob der Kern vom Quarz unter 10 MHz läuft, und
schaltet dann auf den Quarz ungeteilt zurück (`boards/esp32s3/console_clock.asm`).

**ESP32-C3.** Wie ESP-IDF (`rtc_clk.c` und `clk_tree_ll.h` für den C3): Der PLL läuft auf 480 MHz (die Konsole stellt
ihn beim Start so ein und lässt ihn an, der USB-Anschluss braucht ihn) und gibt 80 und 160 MHz (`CPUPERIOD_SEL` 0, 1 in
`SYSTEM_CPU_PER_CONF`, 0x600C0008); der APB bekommt bei beiden 80 MHz. Vom Quarz läuft der Kern mit 40 MHz /
(`PRE_DIV_CNT` + 1) (`SYSTEM_SYSCLK_CONF`, 0x600C0058, dort auch `SOC_CLK_SEL`). Ein Wechsel stellt diese drei Felder
um, schreibt die Frequenz des APB für das ROM nach `RTC_APB_FREQ_REG` (die Hz >> 12, in beiden Hälften) und sagt dem
ROM die Takte pro Mikrosekunde (`ets_update_cpu_frequency`). Den I2C-Bus im Chip braucht der C3 dafür nicht, also auch
nichts von dem, was beim S3 nötig war.

Zwei Dinge waren trotzdem nötig, damit es mit dem WLAN fehlerfrei läuft. Der C3 hat nur einen Kern; der WLAN-Dienst
läuft mit, während ein Programm rechnet. Damit `cpu_clock` weiß, ob das WLAN läuft, hat der Dienst ab Version 7 den
Einsprung `wifi_state`. Und `wlan off` schaltet das WLAN jetzt auch dann ab, wenn das Board kein Netz gespeichert hat:
Ein Programm kann es ja selbst gestartet haben, und vorher blieb es dann an (und die Takte vom Quarz gesperrt). Der
WLAN-Dienst stellt den Takt nur beim ersten Start nach einem Reset ein; ab Version 7 behält er dabei einen Takt vom
PLL, statt immer 160 MHz zu nehmen. Am Programmende prüft die Konsole nur, ob der Kern vom Quarz unter 10 MHz läuft
(oder von RC_FAST), und schaltet dann auf den Quarz ungeteilt zurück (`boards/esp32c3/console_clock.asm`).

**ESP32-S31.** Wie ESP-IDF (`rtc_clk.c` und `clk_tree_ll.h` für den S31): Die Konsole stellt beim Start den CPLL auf
320 MHz und lässt ihn an. In `HP_SYS_CLKRST` (0x20587000) wählt `SOC_CLK_SEL` die Quelle (0 Quarz, 1 CPLL); dahinter
haben Kern (8 Bit), Speicher (1 Bit, vom Kern), Systembus (vom Kern) und APB (vom Systembus) je einen Teiler, und
`SOC_CLK_UPDATE` übernimmt alles auf einmal. 320 MHz: Kern /1, Speicher /2 (160 MHz), Systembus /3 (106,7 MHz), APB /2
(53,3 MHz); 160 MHz: /2, /1, /2, /2; 80 MHz: /4, /1, /1, /2; 53 MHz: /6 und sonst /1; vom Quarz alles bis auf den Kern
/1. Danach bekommt das ROM die Takte pro Mikrosekunde (`ets_update_cpu_frequency`).

Die Spannung des Kerns steht in `PMU_HP_ACTIVE_HP_REGULATOR0` (0x20704034), im Feld `dbias` (Bits 31 … 27); mit
`DBIAS_SEL` 1 gilt dieses Register. Das Boot-ROM lässt 24, ESP-IDF stellt ohne automatische Regelung (PVT) fest 26 ein,
für alle Takte. `cpu_clock(320)` hebt auf 26 an, wenn es tiefer steht. Gemessen lief 320 MHz auch mit 24 fehlerfrei;
26 ist die Reserve, die ESP-IDF vorsieht. Mit PVT, dem Standard von ESP-IDF, regelt der Chip die Spannung nach seiner
Kalibrierung im eFuse selbst nach; das macht Asmonite nicht.

Damit das WLAN mit allen Takten fehlerfrei läuft, waren in der Konsole zwei Dinge nötig: `wlan on` schaltet von einem
Takt vom Quarz zuerst auf 160 MHz (`clock_init`), denn der Funkteil braucht den PLL; und `wlan off` schaltet das WLAN
auch dann ab, wenn ein Programm es selbst gestartet hat, sonst blieben die Takte vom Quarz gesperrt. Ob das WLAN
läuft, sagt der WLAN-Dienst über `wifi_state` (derselbe Dienst wie beim C3, ab Version 7).

**Pico, Pico 2.** clk_sys kommt in der Konsole vom USB-PLL (48 MHz). `cpu_clock` stellt den PLL_SYS ein, wie es das
Pico SDK tut: 12 MHz × FBDIV / (POSTDIV1 × POSTDIV2), der VCO zwischen 750 und 1600 MHz; gesucht werden die
Nachteiler von oben, bis ein VCO passt. Der Wechsel geht, wie das Datenblatt es verlangt: clk_sys auf clk_ref
(störungsfrei), PLL_SYS zurücksetzen, einstellen, warten, bis er eingerastet ist, dann die Hilfsquelle und zurück.
`cpu_clock_khz` lässt clk_sys auf clk_ref (dem Quarz) und teilt mit `CLK_SYS_DIV` (24 Bit ganzer Teil beim RP2040,
16 Bit beim RP2350). Damit der UART von alldem nichts merkt, bekommt clk_peri seinen Takt in der Konsole direkt vom
USB-PLL statt von clk_sys. Am Programmende schaltet die Konsole nur zurück, wenn clk_sys vom Quarz kommt
(`boards/pico/console_clock.asm`, für Pico und Pico 2 gemeinsam); `info` rechnet den Takt aus denselben Registern aus.

## Mehr

- Die Bibliotheken: `abelle/lib/esp32/cpuclock.abel`, `abelle/lib/esp32s3/cpuclock.abel`,
  `abelle/lib/esp32c3/cpuclock.abel`, `abelle/lib/esp32s31/cpuclock.abel`, `abelle/lib/pico/cpuclock.abel`,
  `abelle/lib/pico2/cpuclock.abel` (der Kopf jeder Datei beschreibt sie genau).
- Die Sprache aBelle: [abelle/README.md](../../abelle/README.md).
- Die Boards und ihre Konsolen: [boards.md](boards.md).
