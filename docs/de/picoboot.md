# Der Raspberry Pi Pico (RP2040) ohne Debug-Sonde

Asmonite debuggt ein Programm im RAM eines RP2040 **mit einem USB-Kabel, ohne Debug-Sonde und ohne Löten**: über den
USB-Boot seines Boot-ROMs (BOOTSEL, die Schnittstelle PICOBOOT, die auch `picotool` benutzt). Breakpoints, Schritte
Zeile für Zeile, Schritt über einen Aufruf, die Register, der Speicher. Wenn das Programm zurückkehrt, zeigt Asmonite
`r0` und `r1`.

Das geht beim Raspberry Pi Pico und bei anderen Boards mit dem RP2040. Ausprobiert mit einem LilyGO T-PicoC3 (ein
RP2040 und ein ESP32-C3 auf einem Board).

Mit dem Raspberry Pi Debug Probe (oder einer anderen CMSIS-DAP-Sonde) an den SWD-Pins debuggt Asmonite den Pico wie
bisher, auch Programme im Flash und mit Pause. Der USB-Boot ist der Weg ohne Sonde.

## Was du brauchst

- Ein Board mit dem RP2040 und ein USB-Kabel, das Daten überträgt.
- Das Board in seinem **USB-Boot**: **BOOT** (oder BOOTSEL) gedrückt halten, dann das Board einstecken oder **RUN**
  (Reset) drücken, während du BOOT hältst; dann BOOT loslassen. Windows zeigt das Laufwerk `RPI-RP2`.
- Windows 10 oder 11.

## Einmal einrichten

Der USB-Boot hat zwei Schnittstellen: das Laufwerk, das Windows kennt, und „RP2 Boot“, für das Windows einen Treiber
braucht.

1. Geräte-Manager: **RP2 Boot** (unter „Andere Geräte“), Rechtsklick, **Treiber aktualisieren**.
2. **Auf meinem Computer nach Treibern suchen**, dann **Aus einer Liste verfügbarer Treiber auf meinem Computer
   auswählen**.
3. **USB-Geräte** (Universal Serial Bus devices), Weiter.
4. Hersteller **WinUsb Device**, Modell **WinUsb Device**, Weiter, und die Warnung bestätigen.
5. In Asmonite: **Debug > Debug targets > Raspberry Pi Pico (RP2040) > Set up the USB boot**. Windows fragt nach
   Administratorrechten: Asmonite gibt der Schnittstelle einen Namen (eine Device-Interface-GUID), unter dem Programme
   sie finden.

Beides ist einmal für jedes Board nötig. Danach sagt **Test the connection** „an RP2040 (boot ROM version 3) in its USB
boot (BOOTSEL), no debug probe“ (Version 3 ist der RP2040 B2, Version 1 und 2 die älteren B0 und B1).

## Ein Programm

```asm
.target pico
.arch thumb
.imagebase 0x20000000

_start:
    movs r0, #42
    bx   lr
```

Steht das Board in seinem USB-Boot, nehmen F9 (Ausführen) und F7 (Schritt hinein) diesen Weg von selbst; das
Ausgabefenster sagt „in its USB boot (BOOTSEL), over the USB cable without a debug probe“. Das Programm kommt ins RAM
bei `.imagebase` (ab `0x20000000` bis `0x2003F000`, 252 KB), wird zurückgelesen und startet bei `_start`; F7 hält dort
an. Dann wie bei den anderen Boards: F7 und F8 gehen Zeile für Zeile, F8 geht über `bl`, F5 setzt einen Breakpoint,
F9 läuft bis zum nächsten, die Register `r0` bis `r15` und `xPSR` zeigen den Stand, und das Speicherfenster liest das
RAM und das ROM.

Das Programm startet mit `sp` bei `0x2003F000` (sein Stack wächst von dort nach unten) und `lr` an der Endmarke des
Debuggers: Es wird wie eine Funktion aufgerufen. Wenn es zurückkehrt (`bx lr`, oder `pop {..., pc}` nach einem
`push {..., lr}`), endet die Sitzung, und das Ausgabefenster zeigt

```
The program returned: r0 = 42 (0x2A), r1 = 0 (0x0)
```

und das Board ist bereit für das nächste F9, weiter in seinem USB-Boot.

**Keine Pause.** Das Programm läuft, während das Boot-ROM auf es wartet: Ein laufendes Programm lässt sich nicht
anhalten, und Stop lässt es weiterlaufen. Setz einen Breakpoint, bevor das Programm in eine Schleife läuft. Ein
Programm, das nie anhält, läuft bis RUN (oder bis das Board abgesteckt wird); dann bring es wieder in den USB-Boot.

**Ein Fehler** (ein Lesen von einer Adresse ohne Speicher, ein nicht ausgerichteter Zugriff, ein unbekannter Befehl)
hält das Programm am Befehl an: „a HardFault at ...“. Auch ein `bkpt` im Programm hält dort an.

## Wie es funktioniert

Ein kleiner Stub von Asmonite (268 Bytes bei `0x2003F000`, `src/debugger/picobootstub.asm`) wird vom Boot-ROM
aufgerufen (der Befehl EXEC von PICOBOOT). Er hebt die Register des Boot-ROMs auf, schaltet die Interrupts ab, setzt
eine eigene Vektortabelle ein, lädt die Register des Programms und springt an seinen pc. Ohne Debug-Sonde macht der
Cortex-M0+ aus einem `bkpt` einen HardFault: Der Stub nimmt ihn an, hebt die Register des Programms auf, stellt alles
des Boot-ROMs wieder her und kehrt zu ihm zurück. Dann antwortet der USB-Boot wieder, und Asmonite liest die Register
und den Speicher über USB.

Ein Breakpoint ist ein `bkpt`, das Asmonite nur während des Laufs ins RAM schreibt; beim Halt steht der Befehl wieder
dort. Ein Schritt setzt ein `bkpt` an jede Adresse, zu der der Befehl gehen kann (der nächste, das Ziel eines Sprungs,
`bl`, `bx`, `pop` mit dem pc).

## Die Beispiele

Die Beispiele des Pico 1 in `examples/pico`, die im RAM laufen, gehen auch so; ein Programm, das in einer Schleife
endet (`blink_ram.asm`), hält nur an einem Breakpoint oder mit RUN an. `examples/t-picoc3/display_ram.asm` füllt das
Display des LilyGO T-PicoC3 (geh mit F7 durch das Einrichten des SPI).

## Wenn etwas nicht geht

| Meldung | Was tun |
|---|---|
| „No RP2040 in its USB boot is plugged in“ | BOOT halten, RUN drücken (oder einstecken), BOOT loslassen: das Laufwerk RPI-RP2 erscheint |
| „... Windows has no driver for its interface RP2 Boot“ | Der Treiber wie oben (einmal) |
| „The USB boot of this board is not set up for Asmonite yet“ | Debug targets: „Set up the USB boot“ (einmal) |
| „... cannot be opened (another program ...?)“ | picotool oder ein anderes Programm schließen, das sie hat |
| „a program goes into the RAM only“ | Ein Programm für den Flash braucht die Debug-Sonde, oder Project > UF2 und das Laufwerk RPI-RP2 |

## Grenzen

- Nur Programme im RAM, unter `0x2003F000` (darüber der Stub, ganz oben der Stack des Boot-ROMs). Ein Programm für den
  Flash: mit der Debug-Sonde, oder als UF2-Datei (Project > UF2) auf das Laufwerk `RPI-RP2` kopiert.
- Keine Pause eines laufenden Programms (siehe oben).
- Das Speicherfenster liest das RAM und das ROM; nicht den Flash (den liest der USB-Boot erst nach einem Einrichten
  des Flashs, das Asmonite noch nicht macht) und nicht die Peripherie (das Programm selbst kann sie benutzen).
- Das Programm läuft mit den Takten, die das Boot-ROM für USB eingerichtet hat (48 MHz).
- **Der Pico 2 (RP2350) lässt sich so nicht debuggen**; für ihn nimmst du die Debug-Sonde (dort geht alles, auch Pause
  und Flash). Sein USB-Boot hat zwar auch PICOBOOT, und Windows nimmt ihn ohne jede Einrichtung, aber zwei Dinge
  fehlen (ausprobiert an einem Pico 2): Es gibt den Befehl EXEC nicht mehr (die Antwort ist „unbekannter Befehl“),
  das Boot-ROM kann den Stub also nicht aufrufen und die Kontrolle zurückbekommen; und ein Halt über einen Neustart in
  den USB-Boot ist auch kein Ausweg, denn das Boot-ROM des RP2350 löscht das ganze RAM, bevor es in den USB-Boot geht:
  Programm, Stack und Daten wären weg. Über seinen USB-Boot ließe sich ein Programm nur laden und starten, ohne Halt:
  Das macht die UF2-Datei auf dem Laufwerk `RP2350` schon.
