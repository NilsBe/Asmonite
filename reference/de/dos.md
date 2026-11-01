# DOS- und BIOS-Interrupts

Die Befehlsinfo (F1) zeigt zu einem `int` die Funktion, die er aufruft. Welche Funktion es ist, steht in `ah`
(bei der Maus, `int 33h`, in `ax`); Dismonite und Asmonite suchen es in den Befehlen davor (`mov ah, 0x09`,
`mov ax, 0x4C00`, `xor ah, ah`). Ist es nicht zu bestimmen, steht die Übersicht des Interrupts da.

Jeder Abschnitt beginnt mit `## ` und seinem Namen: `int21:09` ist `int 21h` mit `ah` = 09h, `int21` die
Übersicht. Parameter und Ergebnisse stehen in Registern; fast alle Funktionen melden einen Fehler mit gesetztem
Carry-Flag (CF = 1) und dem Fehlercode in `ax`.

## int20 – Int 20h: Programm beenden (alt)

**Eingabe:** `cs` = Segment des PSP (Programmpräfix)

**Ausgabe:** keine, das Programm endet

Beendet das Programm wie `int 21h` mit `ah` = 00h. Funktioniert nur, wenn `cs` das PSP-Segment ist, also in
`.COM`-Programmen. Besser ist `int 21h` mit `ah` = 4Ch, das auch einen Rückgabewert liefert.

Verwandt: `int21:4c`

## int21 – Int 21h: DOS-Funktionen (Übersicht)

Der DOS-Aufruf. Die Funktionsnummer steht in `ah`, die Parameter in anderen Registern. Fehler: CF = 1 und der
Code in `ax`.

- Zeichen: `01h` lesen mit Echo, `02h` ausgeben, `06h` direkt, `07h`/`08h` lesen ohne Echo, `09h` Text bis `$`,
  `0Ah` Zeile lesen, `0Bh` Eingabestatus, `0Ch` Puffer leeren
- Dateien: `3Ch` anlegen, `3Dh` öffnen, `3Eh` schließen, `3Fh` lesen, `40h` schreiben, `41h` löschen,
  `42h` Position setzen, `43h` Attribute, `56h` umbenennen, `57h` Datum und Zeit, `45h`/`46h` Handle kopieren
- Verzeichnisse: `39h` anlegen, `3Ah` löschen, `3Bh` wechseln, `47h` aktuelles lesen, `4Eh`/`4Fh` suchen
- Laufwerke: `0Eh` wählen, `19h` aktuelles, `36h` freier Platz
- Speicher: `48h` belegen, `49h` freigeben, `4Ah` Größe ändern
- Programme: `4Bh` starten, `4Ch` beenden, `4Dh` Rückgabewert, `31h` resident beenden
- Interrupts: `25h` Vektor setzen, `35h` Vektor lesen
- System: `2Ah`/`2Bh` Datum, `2Ch`/`2Dh` Zeit, `30h` Version, `33h` Strg+C, `59h` erweiterter Fehler,
  `38h` Länderinfo, `2Fh`/`1Ah` DTA, `51h`/`62h` PSP
- alt (FCB): `0Fh` bis `17h`, `21h` bis `24h`, `27h` bis `29h`

Dieselben Namen mit Doppelpunkt und der Nummer zeigen die Einzelheiten: `int21:3d`.

Verwandt: `int`, `int20`

## int21:00 – Int 21h, AH=00h: Programm beenden (alt)

**Eingabe:** `ah` = 00h, `cs` = Segment des PSP

**Ausgabe:** keine

Wie `int 20h`. Veraltet; `ah` = 4Ch ist besser und liefert den Rückgabewert.

Verwandt: `int21:4c`, `int20`

## int21:01 – Int 21h, AH=01h: Zeichen lesen mit Echo

**Eingabe:** `ah` = 01h

**Ausgabe:** `al` = das Zeichen

Wartet auf eine Taste, zeigt das Zeichen an und prüft auf Strg+C. Bei einer Sondertaste (Pfeile, F1 ...) ist
`al` = 0; ein zweiter Aufruf liefert dann den Scancode.

```asm
mov ah, 0x01
int 0x21         ; al = Taste
```

Verwandt: `int21:08`, `int21:02`

## int21:02 – Int 21h, AH=02h: Zeichen ausgeben

**Eingabe:** `ah` = 02h, `dl` = das Zeichen

**Ausgabe:** keine (`al` ist danach `dl`)

Schreibt ein Zeichen auf den Bildschirm. `0x0D` geht an den Zeilenanfang, `0x0A` eine Zeile weiter; für einen
Zeilenumbruch beide ausgeben. Prüft auf Strg+C.

```asm
mov dl, 'A'
mov ah, 0x02
int 0x21
```

Verwandt: `int21:09`, `int21:06`

## int21:03 – Int 21h, AH=03h: Zeichen von der seriellen Schnittstelle lesen

**Eingabe:** `ah` = 03h

**Ausgabe:** `al` = das Zeichen

Liest von COM1 (die Hilfsschnittstelle, AUX) und wartet, bis ein Zeichen da ist. Für die Schnittstelle selbst
ist `int 14h` genauer.

Verwandt: `int21:04`, `int14`

## int21:04 – Int 21h, AH=04h: Zeichen an die serielle Schnittstelle senden

**Eingabe:** `ah` = 04h, `dl` = das Zeichen

**Ausgabe:** keine

Sendet ein Zeichen an COM1 (AUX).

Verwandt: `int21:03`, `int14`

## int21:05 – Int 21h, AH=05h: Zeichen zum Drucker senden

**Eingabe:** `ah` = 05h, `dl` = das Zeichen

**Ausgabe:** keine

Schreibt ein Zeichen auf den Drucker LPT1.

Verwandt: `int17`

## int21:06 – Int 21h, AH=06h: direkte Ein- und Ausgabe

**Eingabe:** `ah` = 06h, `dl` = das Zeichen, oder `dl` = FFh zum Lesen

**Ausgabe:** beim Lesen: ZF = 1, wenn keine Taste da ist, sonst ZF = 0 und `al` = das Zeichen

Mit `dl` = FFh wird ohne Warten gelesen, ohne Echo und ohne Prüfung auf Strg+C. Jeder andere Wert von `dl`
wird ausgegeben. Typisch in Spielen und Schleifen, die auf eine Taste warten, während sie etwas anderes tun.

```asm
mov dl, 0xFF
mov ah, 0x06
int 0x21
jz keine_taste
```

Verwandt: `int21:07`, `int21:0b`

## int21:07 – Int 21h, AH=07h: Zeichen lesen ohne Echo, ohne Strg+C

**Eingabe:** `ah` = 07h

**Ausgabe:** `al` = das Zeichen

Wartet auf eine Taste, ohne sie anzuzeigen und ohne Strg+C zu prüfen. Bei einer Sondertaste ist `al` = 0 und
der nächste Aufruf liefert den Scancode.

Verwandt: `int21:08`, `int16:00`

## int21:08 – Int 21h, AH=08h: Zeichen lesen ohne Echo

**Eingabe:** `ah` = 08h

**Ausgabe:** `al` = das Zeichen

Wie `ah` = 07h, prüft aber auf Strg+C (dann wird `int 23h` gerufen).

Verwandt: `int21:07`, `int21:01`

## int21:09 – Int 21h, AH=09h: Text ausgeben

**Eingabe:** `ah` = 09h, `ds:dx` = Adresse des Texts, der mit `$` endet

**Ausgabe:** keine (`al` = 24h)

Schreibt den Text bis zum Zeichen `$` (das nicht ausgegeben wird). Ein `$` im Text selbst ist nicht möglich.
Zeilenumbruch: `13, 10` im Text.

```asm
mov dx, text
mov ah, 0x09
int 0x21
...
text: db 'Hallo!', 13, 10, '$'
```

Verwandt: `int21:02`, `int21:40`

## int21:0a – Int 21h, AH=0Ah: Zeile lesen

**Eingabe:** `ah` = 0Ah, `ds:dx` = Puffer: Byte 0 = Größe des Puffers (mit dem Zeilenende), der Rest wird gefüllt

**Ausgabe:** Byte 1 des Puffers = Anzahl der gelesenen Zeichen (ohne Zeilenende), ab Byte 2 der Text, am Ende `0x0D`

Liest eine Zeile mit Bearbeitung (Rückschritt, Esc) bis zur Eingabe-Taste.

```asm
buffer: db 80, 0
        times 82 db 0
```

Verwandt: `int21:01`, `int21:3f`

## int21:0b – Int 21h, AH=0Bh: Eingabestatus

**Eingabe:** `ah` = 0Bh

**Ausgabe:** `al` = 0FFh, wenn ein Zeichen wartet, sonst 0

Prüft, ob eine Taste gedrückt wurde, ohne zu warten und ohne das Zeichen zu holen.

Verwandt: `int21:06`, `int16:01`

## int21:0c – Int 21h, AH=0Ch: Tastaturpuffer leeren und lesen

**Eingabe:** `ah` = 0Ch, `al` = die Funktion, die danach gerufen wird (01h, 06h, 07h, 08h oder 0Ah)

**Ausgabe:** wie die gerufene Funktion

Verwirft zuerst, was getippt wurde, und führt dann die Eingabefunktion in `al` aus.

Verwandt: `int21:01`, `int21:08`

## int21:0d – Int 21h, AH=0Dh: Laufwerke zurücksetzen

**Eingabe:** `ah` = 0Dh

**Ausgabe:** keine

Schreibt alle Dateipuffer auf die Datenträger, schließt die Dateien aber nicht.

Verwandt: `int21:68`

## int21:0e – Int 21h, AH=0Eh: Laufwerk wählen

**Eingabe:** `ah` = 0Eh, `dl` = Laufwerk (0 = A, 1 = B, 2 = C)

**Ausgabe:** `al` = Anzahl der Laufwerke im System

Macht das Laufwerk zum aktuellen.

Verwandt: `int21:19`

## int21:0f, int21:10, int21:11, int21:12, int21:13, int21:14, int21:15, int21:16, int21:17, int21:21, int21:22, int21:23, int21:24, int21:27, int21:28, int21:29 – Dateifunktionen mit FCB (alt)

**Eingabe:** `ds:dx` = Adresse eines FCB (File Control Block, 37 Bytes)

**Ausgabe:** `al` = 0 bei Erfolg, 0FFh bei Fehler

Die Dateifunktionen aus der Zeit von DOS 1 (CP/M): öffnen `0Fh`, schließen `10h`, suchen `11h`/`12h`,
löschen `13h`, lesen `14h`, schreiben `15h`, anlegen `16h`, umbenennen `17h`, direkter Zugriff `21h` bis
`24h`, Blöcke `27h`/`28h`, Dateinamen zerlegen `29h`. Heute nimmt man die Funktionen mit Handles (`3Ch` bis
`42h`), die auch Pfade und große Dateien können.

Verwandt: `int21:3d`, `int21:3f`

## int21:19 – Int 21h, AH=19h: aktuelles Laufwerk

**Eingabe:** `ah` = 19h

**Ausgabe:** `al` = Laufwerk (0 = A, 1 = B, 2 = C)

Verwandt: `int21:0e`

## int21:1a – Int 21h, AH=1Ah: DTA setzen

**Eingabe:** `ah` = 1Ah, `ds:dx` = Adresse der DTA (Disk Transfer Area, 128 Bytes)

**Ausgabe:** keine

Legt den Puffer fest, in dem die Suchfunktionen `4Eh` und `4Fh` ihr Ergebnis ablegen. Ohne diesen Aufruf ist
es `PSP:0080h` (die Befehlszeile).

Verwandt: `int21:2f`, `int21:4e`

## int21:1b, int21:1c, int21:1f, int21:32 – Laufwerksdaten (alt)

**Eingabe:** `ah` = 1Bh (aktuelles Laufwerk), 1Ch (Laufwerk in `dl`), 1Fh (aktuelles) oder 32h (`dl`) für
den Parameterblock

**Ausgabe:** bei 1Bh und 1Ch: `al` = Sektoren je Cluster, `cx` = Bytes je Sektor, `dx` = Anzahl der Cluster,
`ds:bx` = Zeiger auf die Medienkennung; bei 1Fh und 32h: `ds:bx` = Zeiger auf den Laufwerksparameterblock

Gibt Angaben zur Aufteilung eines Laufwerks. Für den freien Platz nimmt man `ah` = 36h.

Verwandt: `int21:36`

## int21:25 – Int 21h, AH=25h: Interruptvektor setzen

**Eingabe:** `ah` = 25h, `al` = Nummer des Interrupts, `ds:dx` = Adresse der neuen Routine

**Ausgabe:** keine

Trägt die Adresse in die Interrupt-Tabelle ein. Die alte vorher mit `ah` = 35h holen und am Ende des Programms
wiederherstellen.

```asm
push ds
mov dx, handler
push cs
pop ds
mov ax, 0x2508   ; int 8
int 0x21
pop ds
```

Verwandt: `int21:35`, `int`

## int21:26 – Int 21h, AH=26h: neues PSP anlegen

**Eingabe:** `ah` = 26h, `dx` = Segment des neuen PSP

**Ausgabe:** keine

Kopiert das PSP des Programms an die Adresse `dx:0`. Veraltet; zum Starten von Programmen dient `ah` = 4Bh.

Verwandt: `int21:4b`

## int21:2a – Int 21h, AH=2Ah: Datum lesen

**Eingabe:** `ah` = 2Ah

**Ausgabe:** `cx` = Jahr (1980 bis 2099), `dh` = Monat, `dl` = Tag, `al` = Wochentag (0 = Sonntag)

Verwandt: `int21:2c`, `int21:2b`

## int21:2b – Int 21h, AH=2Bh: Datum setzen

**Eingabe:** `ah` = 2Bh, `cx` = Jahr, `dh` = Monat, `dl` = Tag

**Ausgabe:** `al` = 0 bei Erfolg, 0FFh bei ungültigem Datum

Verwandt: `int21:2a`

## int21:2c – Int 21h, AH=2Ch: Zeit lesen

**Eingabe:** `ah` = 2Ch

**Ausgabe:** `ch` = Stunde, `cl` = Minute, `dh` = Sekunde, `dl` = Hundertstelsekunden

Verwandt: `int21:2a`, `int21:2d`, `int1a:00`

## int21:2d – Int 21h, AH=2Dh: Zeit setzen

**Eingabe:** `ah` = 2Dh, `ch` = Stunde, `cl` = Minute, `dh` = Sekunde, `dl` = Hundertstel

**Ausgabe:** `al` = 0 bei Erfolg, 0FFh bei ungültiger Zeit

Verwandt: `int21:2c`

## int21:2e – Int 21h, AH=2Eh: Prüfung beim Schreiben ein- oder ausschalten

**Eingabe:** `ah` = 2Eh, `al` = 1 ein, 0 aus, `dl` = 0

**Ausgabe:** keine

Mit eingeschalteter Prüfung liest DOS jeden geschriebenen Sektor zur Kontrolle. Heute ohne Bedeutung.

Verwandt: `int21:54`

## int21:2f – Int 21h, AH=2Fh: DTA lesen

**Eingabe:** `ah` = 2Fh

**Ausgabe:** `es:bx` = Adresse der aktuellen DTA

Verwandt: `int21:1a`

## int21:30 – Int 21h, AH=30h: DOS-Version

**Eingabe:** `ah` = 30h

**Ausgabe:** `al` = Hauptversion, `ah` = Nebenversion, `bh` = Hersteller, `bl:cx` = Seriennummer

Bei DOS 5 und neuer meldet die Funktion das, was mit `SETVER` eingestellt ist; die wahre Version liefert
`ax` = 3306h. `al` = 0 heißt DOS 1.x.

```asm
mov ah, 0x30
int 0x21
cmp al, 5
jb zu_alt
```

Verwandt: `int21:33`

## int21:31 – Int 21h, AH=31h: Programm beenden und resident lassen

**Eingabe:** `ah` = 31h, `al` = Rückgabewert, `dx` = Größe des Programms, das im Speicher bleibt (in 16-Byte-Absätzen)

**Ausgabe:** keine, das Programm endet

Das Programm bleibt im Speicher (TSR), zum Beispiel mit einem eigenen Interrupt. Danach läuft nur noch, was
vorher als Vektor eingetragen wurde.

Verwandt: `int27`, `int21:25`

## int21:33 – Int 21h, AH=33h: Strg+Break und Systemangaben

**Eingabe:** `ah` = 33h, `al` = 00h lesen, 01h setzen (`dl` = 0 aus, 1 ein), 05h Startlaufwerk (`dl` = 1 für A),
06h wahre DOS-Version

**Ausgabe:** `dl` = Zustand (`al` = 00h); bei `al` = 06h `bl` = Haupt-, `bh` = Nebenversion, `dl` = Revision,
`dh` = Merkmale

Bestimmt, ob DOS bei jedem Aufruf auf Strg+Break prüft oder nur bei Zeichenfunktionen.

Verwandt: `int21:30`

## int21:34 – Int 21h, AH=34h: Adresse des InDOS-Flags

**Eingabe:** `ah` = 34h

**Ausgabe:** `es:bx` = Adresse eines Bytes, das ungleich 0 ist, solange DOS eine Funktion ausführt

Für resident bleibende Programme: Nur wenn das Flag 0 ist, darf man eine DOS-Funktion aufrufen.

Verwandt: `int28`

## int21:35 – Int 21h, AH=35h: Interruptvektor lesen

**Eingabe:** `ah` = 35h, `al` = Nummer des Interrupts

**Ausgabe:** `es:bx` = Adresse der Routine

Vorbereitung für `ah` = 25h: erst den alten Vektor merken, dann eigenen eintragen und am Ende zurückschreiben.

```asm
mov ax, 0x3508   ; int 8
int 0x21
mov [alt_off], bx
mov [alt_seg], es
```

Verwandt: `int21:25`

## int21:36 – Int 21h, AH=36h: freier Platz auf einem Laufwerk

**Eingabe:** `ah` = 36h, `dl` = Laufwerk (0 = aktuelles, 1 = A, 2 = B, 3 = C)

**Ausgabe:** `ax` = Sektoren je Cluster (0FFFFh bei ungültigem Laufwerk), `bx` = freie Cluster,
`cx` = Bytes je Sektor, `dx` = Cluster insgesamt

Freier Platz in Bytes = `ax` * `bx` * `cx` (bei großen Platten reicht 16 Bit nicht).

Verwandt: `int21:1b`

## int21:38 – Int 21h, AH=38h: Länderangaben

**Eingabe:** `ah` = 38h, `al` = 0 (aktuelles Land) oder Landesnummer, `ds:dx` = Puffer von 34 Bytes

**Ausgabe:** CF = 0: `bx` = Landesnummer, der Puffer mit Datumsformat, Währungszeichen, Trennzeichen

Verwandt: `int21:66`

## int21:39 – Int 21h, AH=39h: Verzeichnis anlegen

**Eingabe:** `ah` = 39h, `ds:dx` = Pfad (Text mit Endnull)

**Ausgabe:** CF = 1: `ax` = 3 Pfad nicht gefunden, 5 Zugriff verweigert

Verwandt: `int21:3a`, `int21:3b`

## int21:3a – Int 21h, AH=3Ah: Verzeichnis löschen

**Eingabe:** `ah` = 3Ah, `ds:dx` = Pfad

**Ausgabe:** CF = 1: `ax` = 3 Pfad nicht gefunden, 5 Zugriff verweigert (auch wenn nicht leer), 16 aktuelles Verzeichnis

Verwandt: `int21:39`

## int21:3b – Int 21h, AH=3Bh: Verzeichnis wechseln

**Eingabe:** `ah` = 3Bh, `ds:dx` = Pfad

**Ausgabe:** CF = 1: `ax` = 3 Pfad nicht gefunden

Wechselt das Verzeichnis, nicht das Laufwerk (dafür `ah` = 0Eh).

Verwandt: `int21:47`, `int21:0e`

## int21:3c – Int 21h, AH=3Ch: Datei anlegen

**Eingabe:** `ah` = 3Ch, `cx` = Attribute (0 normal, 1 schreibgeschützt, 2 versteckt, 4 System), `ds:dx` = Name

**Ausgabe:** CF = 0: `ax` = Handle; CF = 1: `ax` = 3 Pfad nicht gefunden, 4 zu viele offene Dateien,
5 Zugriff verweigert

Legt die Datei an und öffnet sie zum Schreiben. Eine vorhandene Datei wird geleert. `ah` = 5Bh scheitert
stattdessen, wenn es sie schon gibt.

```asm
mov dx, name
xor cx, cx
mov ah, 0x3C
int 0x21
jc fehler
mov [handle], ax
```

Verwandt: `int21:3d`, `int21:40`, `int21:3e`, `int21:5b`

## int21:3d – Int 21h, AH=3Dh: Datei öffnen

**Eingabe:** `ah` = 3Dh, `al` = Zugriff (0 lesen, 1 schreiben, 2 beides; Bits 4 bis 6 Freigabe), `ds:dx` = Name

**Ausgabe:** CF = 0: `ax` = Handle; CF = 1: `ax` = 2 Datei nicht gefunden, 3 Pfad nicht gefunden,
4 zu viele offene Dateien, 5 Zugriff verweigert, 12 ungültiger Zugriffsmodus

Das Handle gilt für `ah` = 3Fh, 40h, 42h und 3Eh. Die Handles 0 bis 4 sind schon vergeben: 0 Eingabe, 1 Ausgabe,
2 Fehlerausgabe, 3 COM1, 4 Drucker.

```asm
mov dx, name
mov ax, 0x3D00   ; lesen
int 0x21
jc nicht_da
mov bx, ax
```

Verwandt: `int21:3c`, `int21:3f`, `int21:3e`, `int21:6c`

## int21:3e – Int 21h, AH=3Eh: Datei schließen

**Eingabe:** `ah` = 3Eh, `bx` = Handle

**Ausgabe:** CF = 1: `ax` = 6 ungültiges Handle

Schreibt die Dateipuffer und trägt Größe, Datum und Zeit ein. Eine offene Datei am Programmende wird von DOS
geschlossen, aber nicht bei einem Absturz sauber.

Verwandt: `int21:3d`, `int21:68`

## int21:3f – Int 21h, AH=3Fh: aus Datei lesen

**Eingabe:** `ah` = 3Fh, `bx` = Handle, `cx` = Anzahl der Bytes, `ds:dx` = Puffer

**Ausgabe:** CF = 0: `ax` = gelesene Bytes (0 am Dateiende); CF = 1: `ax` = 5 Zugriff verweigert, 6 ungültiges
Handle

Weniger Bytes als verlangt heißt nicht Fehler, sondern Dateiende (oder bei der Tastatur: eine Zeile). Mit
Handle 0 liest man die Eingabe.

```asm
mov bx, [handle]
mov cx, 512
mov dx, puffer
mov ah, 0x3F
int 0x21
```

Verwandt: `int21:40`, `int21:42`, `int21:3d`

## int21:40 – Int 21h, AH=40h: in Datei schreiben

**Eingabe:** `ah` = 40h, `bx` = Handle, `cx` = Anzahl der Bytes, `ds:dx` = Daten

**Ausgabe:** CF = 0: `ax` = geschriebene Bytes; CF = 1: `ax` = 5 Zugriff verweigert, 6 ungültiges Handle

Ist `ax` kleiner als `cx`, ist der Datenträger voll (kein Fehler!). `cx` = 0 schneidet die Datei an der
aktuellen Position ab. Handle 1 ist die Bildschirmausgabe, 2 die Fehlerausgabe.

```asm
mov bx, 1        ; Bildschirm
mov cx, laenge
mov dx, text
mov ah, 0x40
int 0x21
```

Verwandt: `int21:3f`, `int21:09`, `int21:42`

## int21:41 – Int 21h, AH=41h: Datei löschen

**Eingabe:** `ah` = 41h, `ds:dx` = Name (ohne Platzhalter)

**Ausgabe:** CF = 1: `ax` = 2 Datei nicht gefunden, 3 Pfad nicht gefunden, 5 Zugriff verweigert

Verwandt: `int21:56`

## int21:42 – Int 21h, AH=42h: Position in der Datei setzen

**Eingabe:** `ah` = 42h, `al` = 0 vom Anfang, 1 von der aktuellen Position, 2 vom Ende; `bx` = Handle,
`cx:dx` = Verschiebung (mit Vorzeichen)

**Ausgabe:** CF = 0: `dx:ax` = neue Position vom Anfang; CF = 1: `ax` = Fehlercode

Die Dateigröße: `al` = 2 mit `cx:dx` = 0.

```asm
mov ax, 0x4202   ; ans Ende
xor cx, cx
xor dx, dx
int 0x21         ; dx:ax = Größe
```

Verwandt: `int21:3f`, `int21:40`

## int21:43 – Int 21h, AH=43h: Dateiattribute lesen und setzen

**Eingabe:** `ah` = 43h, `al` = 0 lesen, 1 setzen; `ds:dx` = Name; `cx` = Attribute (beim Setzen)

**Ausgabe:** CF = 0: `cx` = Attribute (beim Lesen); CF = 1: `ax` = 2, 3 oder 5

Attribute: 01h schreibgeschützt, 02h versteckt, 04h System, 10h Verzeichnis, 20h Archiv.

Verwandt: `int21:4e`

## int21:44 – Int 21h, AH=44h: IOCTL (Geräte steuern)

**Eingabe:** `ah` = 44h, `al` = Unterfunktion, `bx` = Handle (oder `bl` = Laufwerk)

**Ausgabe:** je nach Unterfunktion; CF = 1 bei Fehler

Die wichtigsten Unterfunktionen: 00h Geräteinformation lesen (`dx`, Bit 7 = 1: ein Gerät, keine Datei),
01h setzen, 02h/03h Steuerdaten lesen und schreiben, 06h Eingabestatus, 07h Ausgabestatus, 08h Medium wechselbar?,
09h Laufwerk im Netz?, 0Ah Handle im Netz?, 0Eh/0Fh logisches Laufwerk. Typische Verwendung: feststellen, ob
Handle 1 auf den Bildschirm oder in eine Datei zeigt (`al` = 0, Bit 7 von `dl`).

```asm
mov ax, 0x4400
mov bx, 1
int 0x21
test dl, 0x80    ; Gerät?
```

Verwandt: `int21:3d`

## int21:45 – Int 21h, AH=45h: Handle kopieren

**Eingabe:** `ah` = 45h, `bx` = Handle

**Ausgabe:** CF = 0: `ax` = neues Handle für dieselbe Datei; CF = 1: `ax` = 4 oder 6

Verwandt: `int21:46`

## int21:46 – Int 21h, AH=46h: Handle auf ein anderes umleiten

**Eingabe:** `ah` = 46h, `bx` = Handle, `cx` = Handle, das danach auf dieselbe Datei zeigt

**Ausgabe:** CF = 1: `ax` = 4 oder 6

Damit leitet man die Ausgabe um: erst die Datei öffnen, dann Handle 1 darauf legen.

Verwandt: `int21:45`

## int21:47 – Int 21h, AH=47h: aktuelles Verzeichnis lesen

**Eingabe:** `ah` = 47h, `dl` = Laufwerk (0 aktuell, 1 = A), `ds:si` = Puffer von 64 Bytes

**Ausgabe:** der Pfad ohne Laufwerk und ohne führenden `\`, als Text mit Endnull; CF = 1: `ax` = 15 ungültiges
Laufwerk

Verwandt: `int21:3b`

## int21:48 – Int 21h, AH=48h: Speicher belegen

**Eingabe:** `ah` = 48h, `bx` = Größe in Absätzen (16 Bytes)

**Ausgabe:** CF = 0: `ax` = Segment des Blocks; CF = 1: `ax` = 7 Speicherblöcke zerstört, 8 nicht genug
Speicher, `bx` = Größe des größten freien Blocks

Programme (`.EXE` und `.COM`) bekommen beim Start den ganzen freien Speicher; sie müssen erst mit `ah` = 4Ah
Speicher abgeben.

Verwandt: `int21:49`, `int21:4a`

## int21:49 – Int 21h, AH=49h: Speicher freigeben

**Eingabe:** `ah` = 49h, `es` = Segment des Blocks

**Ausgabe:** CF = 1: `ax` = 7 oder 9 (ungültiger Block)

Verwandt: `int21:48`

## int21:4a – Int 21h, AH=4Ah: Speicherblock verändern

**Eingabe:** `ah` = 4Ah, `es` = Segment des Blocks, `bx` = neue Größe in Absätzen

**Ausgabe:** CF = 1: `ax` = 7, 8 oder 9; bei 8 steht in `bx` die größte mögliche Größe

Zuerst gibt man damit den Speicher hinter dem eigenen Programm zurück (`es` = PSP-Segment), bevor man mit
`ah` = 48h oder 4Bh Speicher braucht.

Verwandt: `int21:48`, `int21:4b`

## int21:4b – Int 21h, AH=4Bh: Programm starten

**Eingabe:** `ah` = 4Bh, `al` = 0 laden und ausführen, 1 laden, 3 Overlay laden; `ds:dx` = Programmname;
`es:bx` = Parameterblock (Umgebung, Befehlszeile, zwei FCBs)

**Ausgabe:** CF = 1: `ax` = 2 nicht gefunden, 5 Zugriff verweigert, 8 nicht genug Speicher

Kehrt zurück, wenn das gestartete Programm endet; den Rückgabewert holt `ah` = 4Dh. Alle Register außer
`cs:ip` sind danach verändert, auch `ss:sp` (vorher sichern). Vorher mit `ah` = 4Ah Speicher freigeben.

Verwandt: `int21:4d`, `int21:4c`, `int21:4a`

## int21:4c – Int 21h, AH=4Ch: Programm beenden

**Eingabe:** `ah` = 4Ch, `al` = Rückgabewert (ERRORLEVEL)

**Ausgabe:** keine, das Programm endet

Der übliche Schluss eines DOS-Programms. DOS schließt die offenen Dateien und gibt den Speicher frei.

```asm
mov ax, 0x4C00 ; Ende, 0
int 0x21
```

Verwandt: `int20`, `int21:31`, `int21:4d`

## int21:4d – Int 21h, AH=4Dh: Rückgabewert des letzten Programms

**Eingabe:** `ah` = 4Dh

**Ausgabe:** `al` = Rückgabewert, `ah` = Art des Endes (0 normal, 1 Strg+C, 2 kritischer Fehler, 3 resident)

Verwandt: `int21:4b`

## int21:4e – Int 21h, AH=4Eh: erste Datei suchen

**Eingabe:** `ah` = 4Eh, `cx` = Attribute, die mitgesucht werden (0 nur gewöhnliche Dateien), `ds:dx` = Muster
mit `*` und `?`

**Ausgabe:** CF = 0: die DTA enthält die Datei; CF = 1: `ax` = 2 oder 3 (nichts gefunden), 18 keine weitere

DTA-Aufbau: Offset 15h Attribute (1 Byte), 16h Zeit, 18h Datum, 1Ah Größe (4 Bytes), 1Eh Name (13 Bytes mit
Endnull). Die DTA vorher mit `ah` = 1Ah setzen.

Verwandt: `int21:4f`, `int21:1a`

## int21:4f – Int 21h, AH=4Fh: nächste Datei suchen

**Eingabe:** `ah` = 4Fh (die DTA von `ah` = 4Eh darf nicht verändert sein)

**Ausgabe:** CF = 0: die DTA enthält die nächste Datei; CF = 1: `ax` = 18 keine weitere

Verwandt: `int21:4e`

## int21:50, int21:51, int21:62 – PSP lesen und setzen

**Eingabe:** `ah` = 50h mit `bx` = Segment (setzen); 51h oder 62h (lesen)

**Ausgabe:** `bx` = Segment des PSP des laufenden Programms (bei 51h und 62h)

Das PSP (Programmpräfix, 256 Bytes) enthält die Befehlszeile bei Offset 80h, die Umgebung bei Offset 2Ch und
die Speichergrenze bei Offset 02h.

Verwandt: `int21:26`

## int21:54 – Int 21h, AH=54h: Prüfung beim Schreiben abfragen

**Eingabe:** `ah` = 54h

**Ausgabe:** `al` = 0 aus, 1 ein

Verwandt: `int21:2e`

## int21:56 – Int 21h, AH=56h: Datei umbenennen oder verschieben

**Eingabe:** `ah` = 56h, `ds:dx` = alter Name, `es:di` = neuer Name

**Ausgabe:** CF = 1: `ax` = 2, 3, 5 oder 17 (nicht dasselbe Laufwerk)

Auf demselben Laufwerk kann man auch in ein anderes Verzeichnis verschieben.

Verwandt: `int21:41`

## int21:57 – Int 21h, AH=57h: Datum und Zeit einer Datei

**Eingabe:** `ah` = 57h, `al` = 0 lesen, 1 setzen, `bx` = Handle; beim Setzen `cx` = Zeit, `dx` = Datum

**Ausgabe:** beim Lesen `cx` = Zeit, `dx` = Datum; CF = 1: `ax` = 1 oder 6

Zeit: Bits 11 bis 15 Stunde, 5 bis 10 Minute, 0 bis 4 Sekunde / 2. Datum: Bits 9 bis 15 Jahr - 1980, 5 bis 8
Monat, 0 bis 4 Tag.

Verwandt: `int21:43`

## int21:58 – Int 21h, AH=58h: Strategie der Speicherzuteilung

**Eingabe:** `ah` = 58h, `al` = 0 lesen, 1 setzen (`bx` = 0 erste passende, 1 beste, 2 letzte), 2/3 Verbindung zu
den oberen Speicherblöcken lesen/setzen

**Ausgabe:** `ax` = Strategie (beim Lesen)

Verwandt: `int21:48`

## int21:59 – Int 21h, AH=59h: erweiterte Fehlerangabe

**Eingabe:** `ah` = 59h, `bx` = 0

**Ausgabe:** `ax` = erweiterter Fehlercode, `bh` = Klasse, `bl` = empfohlene Maßnahme, `ch` = Ort

Nach einem Fehler gibt dies mehr Auskunft als der Code der Funktion, zum Beispiel 32 für einen
Sharing-Verstoß (Datei von einem anderen Programm gesperrt).

Verwandt: `int24`

## int21:5a – Int 21h, AH=5Ah: temporäre Datei anlegen

**Eingabe:** `ah` = 5Ah, `cx` = Attribute, `ds:dx` = Pfad mit `\` am Ende und Platz für 13 weitere Bytes

**Ausgabe:** CF = 0: `ax` = Handle, der Name steht im Puffer; CF = 1: `ax` = Fehlercode

Legt eine Datei mit einem eindeutigen Namen an. Löschen muss das Programm selbst.

Verwandt: `int21:3c`

## int21:5b – Int 21h, AH=5Bh: neue Datei anlegen

**Eingabe:** `ah` = 5Bh, `cx` = Attribute, `ds:dx` = Name

**Ausgabe:** CF = 0: `ax` = Handle; CF = 1: `ax` = 80 die Datei gibt es schon

Wie `ah` = 3Ch, scheitert aber, wenn die Datei vorhanden ist.

Verwandt: `int21:3c`

## int21:5c – Int 21h, AH=5Ch: Bereich einer Datei sperren

**Eingabe:** `ah` = 5Ch, `al` = 0 sperren, 1 freigeben, `bx` = Handle, `cx:dx` = Beginn, `si:di` = Länge

**Ausgabe:** CF = 1: `ax` = 1 (SHARE fehlt), 6 oder 33 (Sperrverstoß)

Für Programme, die dieselbe Datei gemeinsam benutzen (mit SHARE).

Verwandt: `int21:3d`

## int21:66 – Int 21h, AH=66h: Codeseite lesen und setzen

**Eingabe:** `ah` = 66h, `al` = 1 lesen, 2 setzen (`bx` = Codeseite)

**Ausgabe:** beim Lesen `bx` = aktive, `dx` = Standard-Codeseite (437 USA, 850 Westeuropa)

Verwandt: `int21:38`

## int21:67 – Int 21h, AH=67h: Anzahl der Handles festlegen

**Eingabe:** `ah` = 67h, `bx` = Anzahl (bis 255)

**Ausgabe:** CF = 1: `ax` = 8 nicht genug Speicher

Ohne den Aufruf hat ein Programm 20 Handles (5 davon sind vorbelegt).

Verwandt: `int21:3d`

## int21:68 – Int 21h, AH=68h: Datei auf den Datenträger schreiben

**Eingabe:** `ah` = 68h, `bx` = Handle

**Ausgabe:** CF = 1: `ax` = 6 ungültiges Handle

Schreibt die Dateipuffer sofort, ohne die Datei zu schließen (DOS 3.3 und neuer).

Verwandt: `int21:3e`, `int21:0d`

## int21:6c – Int 21h, AH=6Ch: Datei erweitert öffnen oder anlegen

**Eingabe:** `ah` = 6Ch, `al` = 0, `bl` = Zugriff, `bh` = Merkmale, `cx` = Attribute, `dx` = Aktion (Bit 0 öffnen
falls vorhanden, Bit 4 anlegen falls nicht vorhanden, Bit 1 überschreiben), `ds:si` = Name

**Ausgabe:** CF = 0: `ax` = Handle, `cx` = was geschah (1 geöffnet, 2 angelegt, 3 überschrieben)

Vereint `ah` = 3Dh und 3Ch (DOS 4 und neuer).

Verwandt: `int21:3d`, `int21:3c`

## int25 – Int 25h: Sektoren absolut lesen

**Eingabe:** `al` = Laufwerk (0 = A), `cx` = Anzahl der Sektoren, `dx` = erster Sektor, `ds:bx` = Puffer

**Ausgabe:** CF = 1: `ax` = Fehlercode (`al` = Fehler des Geräts)

DOS lässt die Flags **auf dem Stack** liegen: nach dem Aufruf muss man sie mit `popf` oder `add sp, 2`
abräumen, sonst stürzt das Programm ab. Veraltet; für große Platten gibt es `int 21h` mit `ax` = 7305h.

Verwandt: `int26`, `int13:02`

## int26 – Int 26h: Sektoren absolut schreiben

**Eingabe:** `al` = Laufwerk, `cx` = Anzahl, `dx` = erster Sektor, `ds:bx` = Puffer

**Ausgabe:** CF = 1: `ax` = Fehlercode

Wie `int 25h`: Die Flags liegen danach auf dem Stack. Ein Fehler hier kann das Dateisystem zerstören.

Verwandt: `int25`, `int13:03`

## int27 – Int 27h: resident beenden (alt)

**Eingabe:** `dx` = Offset des ersten Bytes hinter dem Teil, der im Speicher bleibt; `cs` = PSP

**Ausgabe:** keine, das Programm endet

Wie `int 21h` mit `ah` = 31h, aber für Programme bis 64 KB.

Verwandt: `int21:31`

## int29 – Int 29h: schnelle Zeichenausgabe

**Eingabe:** `al` = das Zeichen

**Ausgabe:** keine

Schreibt ein Zeichen auf den Bildschirm, ohne Umleitung und ohne Prüfung auf Strg+C. Der kürzeste Weg, ein
Zeichen auszugeben; undokumentiert bis DOS 5.

Verwandt: `int21:02`, `int10:0e`

## int10 – Int 10h: Bildschirm (Übersicht)

Das Video-BIOS. Die Funktion steht in `ah`.

- `00h` Videomodus setzen, `0Fh` aktuellen lesen
- Cursor: `01h` Form, `02h` setzen, `03h` lesen
- `05h` Seite wählen, `06h`/`07h` Fenster rollen
- Zeichen: `08h` lesen, `09h`/`0Ah` schreiben, `0Eh` ausgeben (Teletype), `13h` Text schreiben
- Grafik: `0Ch` Punkt setzen, `0Dh` Punkt lesen, `0Bh` Palette und Rand
- `10h` Farbtabelle (EGA/VGA), `11h` Zeichensatz, `12h` EGA-Angaben, `1Ah` Anzeigetyp, `4Fh` VESA

Mit der Taste F1 auf `int10:0e` und so weiter gibt es die Einzelheiten.

Verwandt: `int`

## int10:00 – Int 10h, AH=00h: Videomodus setzen

**Eingabe:** `ah` = 00h, `al` = Modus (Bit 7 = 1: den Bildschirm nicht löschen)

**Ausgabe:** keine

Wichtige Modi: 03h Text 80 x 25 in 16 Farben, 07h Text einfarbig, 13h Grafik 320 x 200 in 256 Farben,
12h Grafik 640 x 480 in 16 Farben, 04h Grafik 320 x 200 in 4 Farben.

```asm
mov ax, 0x0013 ; 256 Farben
int 0x10
```

Verwandt: `int10:0f`

## int10:01 – Int 10h, AH=01h: Cursorform setzen

**Eingabe:** `ah` = 01h, `ch` = erste Zeile (Bits 0 bis 4), `cl` = letzte Zeile des Cursors

**Ausgabe:** keine

Ein Zeichen hat je nach Karte 8, 14 oder 16 Zeilen (0 bis 7, 13 oder 15). `ch` = 20h versteckt den Cursor.

Verwandt: `int10:02`

## int10:02 – Int 10h, AH=02h: Cursor setzen

**Eingabe:** `ah` = 02h, `bh` = Seite (meist 0), `dh` = Zeile, `dl` = Spalte (beide ab 0)

**Ausgabe:** keine

```asm
xor bh, bh
mov dx, 0x0A28 ; Zeile 10/40
mov ah, 0x02
int 0x10
```

Verwandt: `int10:03`, `int10:0e`

## int10:03 – Int 10h, AH=03h: Cursor lesen

**Eingabe:** `ah` = 03h, `bh` = Seite

**Ausgabe:** `dh` = Zeile, `dl` = Spalte, `ch` = erste, `cl` = letzte Zeile der Cursorform

Verwandt: `int10:02`

## int10:05 – Int 10h, AH=05h: Bildschirmseite wählen

**Eingabe:** `ah` = 05h, `al` = Seite (0 bis 7 im Textmodus)

**Ausgabe:** keine

Verwandt: `int10:00`

## int10:06 – Int 10h, AH=06h: Fenster nach oben rollen

**Eingabe:** `ah` = 06h, `al` = Anzahl der Zeilen (0 = das Fenster löschen), `bh` = Attribut der neuen Zeilen,
`ch:cl` = Zeile und Spalte oben links, `dh:dl` = Zeile und Spalte unten rechts

**Ausgabe:** keine

Mit `al` = 0 und dem ganzen Fenster (0,0 bis 24,79) löscht man den Bildschirm.

```asm
mov ax, 0x0600
mov bh, 0x07 ; hellgrau
xor cx, cx
mov dx, 0x184F
int 0x10
```

Verwandt: `int10:07`

## int10:07 – Int 10h, AH=07h: Fenster nach unten rollen

**Eingabe:** wie `ah` = 06h

**Ausgabe:** keine

Verwandt: `int10:06`

## int10:08 – Int 10h, AH=08h: Zeichen und Attribut am Cursor lesen

**Eingabe:** `ah` = 08h, `bh` = Seite

**Ausgabe:** `al` = Zeichen, `ah` = Attribut

Attribut: Bits 0 bis 3 Vordergrund, 4 bis 6 Hintergrund, 7 Blinken.

Verwandt: `int10:09`

## int10:09 – Int 10h, AH=09h: Zeichen mit Attribut schreiben

**Eingabe:** `ah` = 09h, `al` = Zeichen, `bh` = Seite, `bl` = Attribut (im Grafikmodus die Farbe), `cx` = Anzahl
der Wiederholungen

**Ausgabe:** keine

Der Cursor bewegt sich nicht. Steuerzeichen werden als Bilder gezeigt, nicht ausgeführt.

Verwandt: `int10:0a`, `int10:0e`

## int10:0a – Int 10h, AH=0Ah: Zeichen schreiben

**Eingabe:** `ah` = 0Ah, `al` = Zeichen, `bh` = Seite, `cx` = Anzahl der Wiederholungen

**Ausgabe:** keine

Wie `ah` = 09h, aber das Attribut an der Stelle bleibt.

Verwandt: `int10:09`

## int10:0b – Int 10h, AH=0Bh: Rand- und Palettenfarbe

**Eingabe:** `ah` = 0Bh, `bh` = 0 und `bl` = Farbe von Rand und Hintergrund; oder `bh` = 1 und `bl` = Palette
(0 oder 1) im Grafikmodus 4

**Ausgabe:** keine

Verwandt: `int10:10`

## int10:0c – Int 10h, AH=0Ch: Punkt setzen

**Eingabe:** `ah` = 0Ch, `al` = Farbe, `bh` = Seite, `cx` = Spalte, `dx` = Zeile

**Ausgabe:** keine

Im Grafikmodus. Langsam; schnelle Programme schreiben selbst in den Bildspeicher (`A000h:0`).

Verwandt: `int10:0d`

## int10:0d – Int 10h, AH=0Dh: Punkt lesen

**Eingabe:** `ah` = 0Dh, `bh` = Seite, `cx` = Spalte, `dx` = Zeile

**Ausgabe:** `al` = Farbe

Verwandt: `int10:0c`

## int10:0e – Int 10h, AH=0Eh: Zeichen ausgeben (Teletype)

**Eingabe:** `ah` = 0Eh, `al` = Zeichen, `bh` = Seite, `bl` = Farbe (nur im Grafikmodus)

**Ausgabe:** keine

Schreibt das Zeichen an den Cursor und bewegt ihn; `0x07` (Klingel), `0x08` (Rückschritt), `0x0A` und `0x0D`
werden ausgeführt, am Ende der Seite wird gerollt. Die einfachste Ausgabe, auch im Bootsektor ohne DOS.

```asm
mov al, 'A'
mov ah, 0x0E
xor bh, bh
int 0x10
```

Verwandt: `int10:13`, `int21:02`

## int10:0f – Int 10h, AH=0Fh: aktuellen Videomodus lesen

**Eingabe:** `ah` = 0Fh

**Ausgabe:** `al` = Modus, `ah` = Anzahl der Spalten, `bh` = aktive Seite

Verwandt: `int10:00`

## int10:10 – Int 10h, AH=10h: Farbpalette (EGA und VGA)

**Eingabe:** `ah` = 10h, `al` = Unterfunktion: 00h Palettenregister setzen (`bl` = Nummer, `bh` = Wert),
10h Farbregister setzen (`bx` = Nummer, `dh` = Rot, `ch` = Grün, `cl` = Blau, je 0 bis 63), 12h Block setzen
(`es:dx`), 15h Farbregister lesen, 17h Block lesen

**Ausgabe:** je nach Unterfunktion

Im Modus 13h ändert man damit die 256 Farben.

Verwandt: `int10:0b`

## int10:11 – Int 10h, AH=11h: Zeichensatz laden (EGA und VGA)

**Eingabe:** `ah` = 11h, `al` = Unterfunktion (00h eigenen Satz laden, 01h 8 x 14, 02h 8 x 8, 04h 8 x 16
einbauen, 30h Angaben lesen)

**Ausgabe:** je nach Unterfunktion

Verwandt: `int10:00`

## int10:12 – Int 10h, AH=12h: Angaben zur Grafikkarte (EGA und VGA)

**Eingabe:** `ah` = 12h, `bl` = Unterfunktion: 10h EGA-Angaben, 30h Zeilenzahl wählen, 36h Bildaufbau ein/aus

**Ausgabe:** bei `bl` = 10h: `bh` = 0 Farbe / 1 einfarbig, `bl` = Speicher (0 = 64 KB bis 3 = 256 KB)

Prüft auch, ob es eine EGA/VGA gibt: bleibt `bl` = 10h, ist es eine ältere Karte.

Verwandt: `int10:1a`

## int10:13 – Int 10h, AH=13h: Text schreiben

**Eingabe:** `ah` = 13h, `al` = Modus (Bit 0: Cursor mitnehmen, Bit 1: der Text hat Attribute), `bh` = Seite,
`bl` = Attribut, `cx` = Länge, `dh:dl` = Zeile und Spalte, `es:bp` = Text

**Ausgabe:** keine

Schreibt einen ganzen Text auf einmal (ab AT-BIOS).

```asm
mov ax, 0x1301
mov bx, 0x0007
mov cx, laenge
mov dx, 0x0000
mov bp, text     ; es:bp
int 0x10
```

Verwandt: `int10:0e`

## int10:1a – Int 10h, AH=1Ah: Anzeigetyp (VGA)

**Eingabe:** `ah` = 1Ah, `al` = 00h

**Ausgabe:** `al` = 1Ah, wenn es eine VGA gibt; `bl` = aktiver Typ (7 VGA einfarbig, 8 VGA Farbe)

Verwandt: `int10:12`

## int10:4f – Int 10h, AH=4Fh: VESA-BIOS

**Eingabe:** `ah` = 4Fh, `al` = 00h Angaben zur Karte (`es:di` = Puffer), 01h Angaben zu einem Modus, 02h Modus
setzen (`bx` = Modus, Bit 14 = lineare Speicherung)

**Ausgabe:** `ax` = 004Fh bei Erfolg

Für Auflösungen über 640 x 480 und mehr als 16 Farben.

Verwandt: `int10:00`

## int11 – Int 11h: Ausstattung der Hardware

**Eingabe:** keine

**Ausgabe:** `ax` = Ausstattungswort: Bit 0 Diskettenlaufwerk da, Bit 1 Koprozessor, Bits 4 und 5 Videomodus
beim Start, Bits 6 und 7 Anzahl der Diskettenlaufwerke - 1, Bits 9 bis 11 Anzahl der seriellen Schnittstellen,
Bits 14 und 15 Anzahl der Drucker

Verwandt: `int12`

## int12 – Int 12h: Größe des Hauptspeichers

**Eingabe:** keine

**Ausgabe:** `ax` = Größe des konventionellen Speichers in KB (höchstens 640)

Verwandt: `int15:88`

## int13 – Int 13h: Laufwerke (Übersicht)

Das Platten-BIOS, ohne Dateisystem: Sektoren auf Disketten und Festplatten. Die Funktion steht in `ah`, das
Laufwerk in `dl` (00h erste Diskette, 80h erste Festplatte).

- `00h` Laufwerk zurücksetzen, `01h` Status
- `02h` Sektoren lesen, `03h` schreiben, `04h` prüfen, `05h` Spur formatieren
- `08h` Laufwerksdaten, `15h` Art des Laufwerks
- `41h` Erweiterungen da?, `42h` lesen, `43h` schreiben, `48h` Daten (LBA, für große Platten)

Fehler: CF = 1 und `ah` = Code. Wichtige Codes: 01h ungültiger Befehl, 02h Adressmarke fehlt, 03h
schreibgeschützt, 04h Sektor nicht gefunden, 06h Datenträger gewechselt, 09h Grenze von 64 KB überschritten,
10h Lesefehler (CRC), 20h Controller-Fehler, 40h Spur nicht gefunden, 80h Zeitüberschreitung (Laufwerk nicht
bereit).

Verwandt: `int25`

## int13:00 – Int 13h, AH=00h: Laufwerk zurücksetzen

**Eingabe:** `ah` = 00h, `dl` = Laufwerk

**Ausgabe:** CF = 1 bei Fehler, `ah` = Code

Setzt den Controller zurück und fährt die Köpfe auf Spur 0. Nach einem Lesefehler wiederholt man den Zugriff
zwei- oder dreimal mit diesem Aufruf dazwischen.

Verwandt: `int13:02`

## int13:01 – Int 13h, AH=01h: Status des letzten Zugriffs

**Eingabe:** `ah` = 01h, `dl` = Laufwerk

**Ausgabe:** `al` = Statuscode des letzten Zugriffs

Verwandt: `int13`

## int13:02 – Int 13h, AH=02h: Sektoren lesen

**Eingabe:** `ah` = 02h, `al` = Anzahl der Sektoren, `ch` = Zylinder (untere 8 Bits), `cl` = Sektor (Bits 0 bis 5,
ab 1) und obere 2 Bits des Zylinders (Bits 6 und 7), `dh` = Kopf, `dl` = Laufwerk, `es:bx` = Puffer

**Ausgabe:** CF = 0: `al` = Anzahl gelesener Sektoren; CF = 1: `ah` = Fehlercode

Der Puffer darf keine 64-KB-Grenze überschreiten. Der Bootsektor wird so geladen: Zylinder 0, Kopf 0, Sektor 1.

```asm
mov ax, 0x0201   ; 1 Sektor lesen
mov cx, 0x0001 ; Zyl. 0, Sek. 1
mov dx, 0x0080 ; Kopf 0, HD 1
mov bx, 0x7C00
int 0x13
```

Verwandt: `int13:03`, `int13:00`, `int13:42`

## int13:03 – Int 13h, AH=03h: Sektoren schreiben

**Eingabe:** wie `ah` = 02h

**Ausgabe:** CF = 0: `al` = Anzahl geschriebener Sektoren; CF = 1: `ah` = Fehlercode

Verwandt: `int13:02`

## int13:04 – Int 13h, AH=04h: Sektoren prüfen

**Eingabe:** wie `ah` = 02h (ohne Puffer)

**Ausgabe:** CF = 1 bei Fehler

Verwandt: `int13:02`

## int13:05 – Int 13h, AH=05h: Spur formatieren

**Eingabe:** `ah` = 05h, `al` = Sektoren je Spur, `ch` = Zylinder, `dh` = Kopf, `dl` = Laufwerk, `es:bx` = Tabelle
mit je 4 Bytes je Sektor (Zylinder, Kopf, Sektor, Größe)

**Ausgabe:** CF = 1 bei Fehler

Zerstört die Daten der Spur.

Verwandt: `int13:02`

## int13:08 – Int 13h, AH=08h: Laufwerksdaten lesen

**Eingabe:** `ah` = 08h, `dl` = Laufwerk

**Ausgabe:** `ch` = höchster Zylinder (untere 8 Bits), `cl` = höchster Sektor (Bits 0 bis 5) und obere Bits
des Zylinders, `dh` = höchster Kopf, `dl` = Anzahl der Laufwerke, `bl` = Typ einer Diskette

Die Anzahl der Zylinder, Köpfe und Sektoren ist jeweils der höchste Wert; Zylinder und Köpfe zählen ab 0,
Sektoren ab 1.

Verwandt: `int13:15`

## int13:15 – Int 13h, AH=15h: Art des Laufwerks

**Eingabe:** `ah` = 15h, `dl` = Laufwerk

**Ausgabe:** `ah` = 0 kein Laufwerk, 1 Diskette ohne Wechselmeldung, 2 Diskette mit Wechselmeldung,
3 Festplatte (`cx:dx` = Anzahl der Sektoren)

Verwandt: `int13:08`

## int13:41 – Int 13h, AH=41h: Erweiterungen prüfen

**Eingabe:** `ah` = 41h, `bx` = 55AAh, `dl` = Laufwerk (80h oder höher)

**Ausgabe:** CF = 0 und `bx` = AA55h, wenn die Erweiterungen (LBA) da sind; `cx` = Bit 0: Zugriff über
Adresspaket

Verwandt: `int13:42`

## int13:42 – Int 13h, AH=42h: Sektoren lesen (LBA)

**Eingabe:** `ah` = 42h, `dl` = Laufwerk, `ds:si` = Adresspaket: Byte 0 = Größe (10h), Byte 1 = 0, Wort 2 =
Anzahl der Sektoren, Doppelwort 4 = Puffer (Offset:Segment), Quadwort 8 = Sektornummer

**Ausgabe:** CF = 1: `ah` = Fehlercode

Liest über die Sektornummer, ohne Zylinder und Köpfe; funktioniert über 8 GB.

```asm
paket: db 0x10, 0
       dw 1            ; Sektoren
       dw 0x7C00, 0    ; Puffer
       dq 0            ; Sektor 0
```

Verwandt: `int13:41`, `int13:43`

## int13:43 – Int 13h, AH=43h: Sektoren schreiben (LBA)

**Eingabe:** wie `ah` = 42h; `al` = Schreibmodus (Bit 0: Prüfen)

**Ausgabe:** CF = 1: `ah` = Fehlercode

Verwandt: `int13:42`

## int13:48 – Int 13h, AH=48h: Laufwerksdaten lesen (LBA)

**Eingabe:** `ah` = 48h, `dl` = Laufwerk, `ds:si` = Puffer (Wort 0 = Größe, vorher 1Ah setzen)

**Ausgabe:** CF = 0: der Puffer enthält Zylinder, Köpfe, Sektoren je Spur, Anzahl der Sektoren (Quadwort) und
Bytes je Sektor

Verwandt: `int13:08`

## int14 – Int 14h: serielle Schnittstelle

**Eingabe:** `ah` = Funktion, `dx` = Schnittstelle (0 = COM1)

- `00h` einstellen: `al` = Bits 5 bis 7 Geschwindigkeit (110 bis 9600), 3 und 4 Parität, 2 Stoppbits,
  0 und 1 Datenbits (7 oder 8)
- `01h` senden: `al` = Zeichen
- `02h` empfangen: `al` = Zeichen
- `03h` Status lesen

**Ausgabe:** `ah` = Leitungsstatus (Bit 7 Zeitüberschreitung, Bit 0 Zeichen da), `al` = Modemstatus oder das
Zeichen

Verwandt: `int21:03`

## int15 – Int 15h: Systemdienste (Übersicht)

Dienste des AT-BIOS. Die Funktion steht in `ah` (bei der Speicherkarte in `ax` = E820h).

- `24h` A20-Leitung steuern, `4Fh` Tastatur abfangen
- `86h` warten (Mikrosekunden), `87h` Speicher über 1 MB kopieren, `88h` Größe des erweiterten Speichers,
  `89h` in den Protected Mode wechseln
- `C0h` Systemangaben, `E8h` Speicherkarte (`ax` = E820h)

Verwandt: `int12`

## int15:86 – Int 15h, AH=86h: warten

**Eingabe:** `ah` = 86h, `cx:dx` = Zeit in Mikrosekunden

**Ausgabe:** CF = 1, wenn der Dienst fehlt

Wartet die Zeit ab (Auflösung etwa 976 µs). Anderen Programmen im Hintergrund gibt es keine Zeit.

Verwandt: `int1a:00`

## int15:87 – Int 15h, AH=87h: Speicher über 1 MB kopieren

**Eingabe:** `ah` = 87h, `cx` = Anzahl der Wörter, `es:si` = Tabelle mit Deskriptoren (Quelle und Ziel)

**Ausgabe:** `ah` = 0 bei Erfolg, CF = 1 bei Fehler

Schaltet kurz in den Protected Mode, um den Speicher oberhalb von 1 MB zu erreichen.

Verwandt: `int15:88`

## int15:88 – Int 15h, AH=88h: Größe des erweiterten Speichers

**Eingabe:** `ah` = 88h

**Ausgabe:** `ax` = Größe des Speichers über 1 MB in KB (höchstens 64 MB)

Verwandt: `int12`, `int15:87`

## int16 – Int 16h: Tastatur (Übersicht)

Das Tastatur-BIOS. Die Funktion steht in `ah`.

- `00h` Taste lesen (wartet), `01h` Taste da?, `02h` Umschaltzustand
- `05h` Taste in den Puffer legen, `03h` Wiederholrate
- `10h`, `11h`, `12h` wie `00h` bis `02h` für die erweiterte Tastatur (F11, F12, getrennte Pfeiltasten)

Die Taste kommt als Wort: `al` = ASCII-Zeichen (0 bei Sondertasten), `ah` = Scancode.

Verwandt: `int21:08`

## int16:00 – Int 16h, AH=00h: Taste lesen

**Eingabe:** `ah` = 00h

**Ausgabe:** `al` = ASCII-Zeichen (0 bei Sondertasten), `ah` = Scancode

Wartet auf eine Taste und entfernt sie aus dem Puffer. Scancodes: 48h Pfeil nach oben, 50h nach unten,
4Bh links, 4Dh rechts, 3Bh F1, 01h Esc.

```asm
xor ah, ah
int 0x16
cmp al, 27       ; Esc?
```

Verwandt: `int16:01`, `int21:08`

## int16:01 – Int 16h, AH=01h: Taste da?

**Eingabe:** `ah` = 01h

**Ausgabe:** ZF = 1: keine Taste da; ZF = 0: `ax` = Taste (bleibt im Puffer)

Verwandt: `int16:00`, `int21:0b`

## int16:02 – Int 16h, AH=02h: Umschaltzustand

**Eingabe:** `ah` = 02h

**Ausgabe:** `al` = Bits: 0 rechte Umschalttaste, 1 linke, 2 Strg, 3 Alt, 4 Rollen, 5 Num, 6 Caps, 7 Einfügen

Verwandt: `int16:00`

## int16:03 – Int 16h, AH=03h: Wiederholrate setzen

**Eingabe:** `ah` = 03h, `al` = 05h, `bh` = Verzögerung (0 bis 3), `bl` = Rate (0 bis 31, 0 am schnellsten)

**Ausgabe:** keine

Verwandt: `int16:00`

## int16:05 – Int 16h, AH=05h: Taste in den Puffer legen

**Eingabe:** `ah` = 05h, `ch` = Scancode, `cl` = ASCII-Zeichen

**Ausgabe:** `al` = 0 bei Erfolg, 1 Puffer voll

Verwandt: `int16:00`

## int16:10, int16:11, int16:12 – Tastatur (erweitert)

**Eingabe:** `ah` = 10h (lesen), 11h (da?), 12h (Umschaltzustand)

**Ausgabe:** wie `ah` = 00h, 01h, 02h; bei 12h in `ax` auch Bits der rechten und linken Strg- und Alt-Tasten

Verwenden die Tasten F11, F12 und die zweiten Pfeiltasten richtig; `00h` liefert für sie falsche Werte.

Verwandt: `int16:00`

## int17 – Int 17h: Drucker

**Eingabe:** `ah` = 00h Zeichen drucken (`al` = Zeichen), 01h Drucker einstellen, 02h Status; `dx` = Drucker
(0 = LPT1)

**Ausgabe:** `ah` = Status: Bit 7 bereit, 6 Bestätigung, 5 Papier fehlt, 4 ausgewählt, 3 Fehler, 0 Zeitüberschreitung

Verwandt: `int21:05`

## int1a – Int 1Ah: Uhr (Übersicht)

Die Zeit-Dienste des BIOS. Die Funktion steht in `ah`.

- `00h` Zählerstand lesen (Takte seit Mitternacht, 18,2 je Sekunde), `01h` setzen
- `02h` Uhrzeit der Echtzeituhr lesen, `03h` setzen
- `04h` Datum der Echtzeituhr lesen, `05h` setzen

Die Werte der Echtzeituhr stehen als BCD (zwei Dezimalziffern je Byte).

Verwandt: `int21:2c`

## int1a:00 – Int 1Ah, AH=00h: Zählerstand lesen

**Eingabe:** `ah` = 00h

**Ausgabe:** `cx:dx` = Takte seit Mitternacht (etwa 18,2065 je Sekunde, 1 573 040 je Tag), `al` ungleich 0, wenn
seit dem letzten Aufruf Mitternacht war

Die einfachste Zeitmessung: zweimal lesen und die Differenz bilden. Derselbe Wert steht bei `0040h:006Ch`.

Verwandt: `int1a:01`, `int15:86`

## int1a:01 – Int 1Ah, AH=01h: Zählerstand setzen

**Eingabe:** `ah` = 01h, `cx:dx` = neuer Zählerstand

**Ausgabe:** keine

Verwandt: `int1a:00`

## int1a:02 – Int 1Ah, AH=02h: Uhrzeit lesen

**Eingabe:** `ah` = 02h

**Ausgabe:** `ch` = Stunde, `cl` = Minute, `dh` = Sekunde (BCD), `dl` = Sommerzeit (0 oder 1); CF = 1, wenn die
Uhr nicht läuft

Verwandt: `int1a:04`, `int21:2c`

## int1a:03 – Int 1Ah, AH=03h: Uhrzeit setzen

**Eingabe:** `ah` = 03h, `ch` = Stunde, `cl` = Minute, `dh` = Sekunde (BCD), `dl` = Sommerzeit

**Ausgabe:** keine

Verwandt: `int1a:02`

## int1a:04 – Int 1Ah, AH=04h: Datum lesen

**Eingabe:** `ah` = 04h

**Ausgabe:** `ch` = Jahrhundert (19 oder 20), `cl` = Jahr, `dh` = Monat, `dl` = Tag (alle BCD); CF = 1, wenn die
Uhr nicht läuft

Verwandt: `int1a:02`, `int21:2a`

## int1a:05 – Int 1Ah, AH=05h: Datum setzen

**Eingabe:** `ah` = 05h, `ch` = Jahrhundert, `cl` = Jahr, `dh` = Monat, `dl` = Tag (BCD)

**Ausgabe:** keine

Verwandt: `int1a:04`

## int2f – Int 2Fh: Multiplex (Übersicht)

Dient Programmen, die sich im Speicher festsetzen, als gemeinsamer Anschluss: Jedes hat eine Nummer in `ah`.
Mit `al` = 00h fragt man, ob es da ist (die meisten antworten `al` = FFh).

- `10h` SHARE, `16h` Windows und Leerlauf, `43h` XMS-Treiber (HIMEM.SYS)
- andere: `11h` Netzwerk, `15h` MSCDEX (CD-ROM), `48h` DOSKEY, `AEh` Befehlsinterpreter

Verwandt: `int28`

## int2f:10 – Int 2Fh, AH=10h: SHARE

**Eingabe:** `ax` = 1000h

**Ausgabe:** `al` = FFh, wenn SHARE (Dateisperren) da ist

Verwandt: `int21:5c`

## int2f:16 – Int 2Fh, AH=16h: Windows und Leerlauf

**Eingabe:** `ax` = 1600h (läuft Windows im erweiterten Modus?) oder `ax` = 1680h (Leerlauf melden)

**Ausgabe:** bei 1600h: `al` = 00h oder 80h: nicht da; sonst Hauptversion in `al`, Nebenversion in `ah`;
bei 1680h: `al` = 00h, wenn der Aufruf unterstützt wird

Ein Programm, das auf etwas wartet, ruft 1680h in der Schleife, damit Windows oder ein Multitasker die Zeit
anderen geben kann.

Verwandt: `int28`

## int2f:43 – Int 2Fh, AH=43h: XMS-Treiber

**Eingabe:** `ax` = 4300h (da?) oder 4310h (Einsprung holen)

**Ausgabe:** bei 4300h: `al` = 80h, wenn der Treiber (HIMEM.SYS) da ist; bei 4310h: `es:bx` = Adresse, die man
mit `call far` für die XMS-Funktionen aufruft

Verwandt: `int15:87`

## int33 – Int 33h: Maus (Übersicht)

Der Maustreiber (Microsoft-Mausschnittstelle). Die Funktion steht in `ax`; zuerst prüft man mit 0000h, ob ein
Treiber da ist. Koordinaten sind virtuelle Punkte; im Textmodus sind es Vielfache von 8 (Spalte = `cx` / 8).

- `0000h` zurücksetzen und prüfen, `0001h` Zeiger zeigen, `0002h` verbergen
- `0003h` Position und Tasten, `0004h` Position setzen
- `0005h` Tastendruck, `0006h` Loslassen (je Taste), `000Bh` Bewegung seit dem letzten Aufruf
- `0007h`/`0008h` Bereich der Bewegung, `000Ch` eigene Routine bei Ereignissen, `000Fh` Empfindlichkeit

Verwandt: `int`

## int33:0000 – Int 33h, AX=0000h: Maus zurücksetzen und prüfen

**Eingabe:** `ax` = 0000h

**Ausgabe:** `ax` = FFFFh, wenn der Treiber da ist, sonst 0; `bx` = Anzahl der Tasten (2, 3 oder FFFFh)

Setzt den Treiber zurück: Der Zeiger ist verborgen, in der Mitte, und der Bereich ist der ganze Bildschirm.

```asm
xor ax, ax
int 0x33
test ax, ax
jz keine_maus
```

Verwandt: `int33:0001`

## int33:0001 – Int 33h, AX=0001h: Mauszeiger zeigen

**Eingabe:** `ax` = 0001h

**Ausgabe:** keine

Ein Zähler: Jedes Verbergen (0002h) braucht ein Zeigen. Im Grafikmodus muss man den Zeiger vor dem Zeichnen
in seiner Nähe verbergen.

Verwandt: `int33:0002`

## int33:0002 – Int 33h, AX=0002h: Mauszeiger verbergen

**Eingabe:** `ax` = 0002h

**Ausgabe:** keine

Verwandt: `int33:0001`

## int33:0003 – Int 33h, AX=0003h: Position und Tasten lesen

**Eingabe:** `ax` = 0003h

**Ausgabe:** `bx` = Tasten (Bit 0 links, Bit 1 rechts, Bit 2 mitte), `cx` = Spalte, `dx` = Zeile

```asm
mov ax, 3
int 0x33
test bx, 1       ; linke Taste?
```

Verwandt: `int33:0005`

## int33:0004 – Int 33h, AX=0004h: Mauszeiger setzen

**Eingabe:** `ax` = 0004h, `cx` = Spalte, `dx` = Zeile

**Ausgabe:** keine

Verwandt: `int33:0003`

## int33:0005 – Int 33h, AX=0005h: Angaben zu Tastendrücken

**Eingabe:** `ax` = 0005h, `bx` = Taste (0 links, 1 rechts, 2 mitte)

**Ausgabe:** `ax` = Zustand der Tasten, `bx` = Anzahl der Drücke seit dem letzten Aufruf, `cx:dx` = Position beim
letzten Drücken

Verwandt: `int33:0006`

## int33:0006 – Int 33h, AX=0006h: Angaben zum Loslassen

**Eingabe:** `ax` = 0006h, `bx` = Taste

**Ausgabe:** `ax` = Zustand der Tasten, `bx` = Anzahl des Loslassens, `cx:dx` = Position beim letzten Loslassen

Verwandt: `int33:0005`

## int33:0007 – Int 33h, AX=0007h: waagerechten Bereich setzen

**Eingabe:** `ax` = 0007h, `cx` = kleinste Spalte, `dx` = größte Spalte

**Ausgabe:** keine

Verwandt: `int33:0008`

## int33:0008 – Int 33h, AX=0008h: senkrechten Bereich setzen

**Eingabe:** `ax` = 0008h, `cx` = kleinste Zeile, `dx` = größte Zeile

**Ausgabe:** keine

Verwandt: `int33:0007`

## int33:000b – Int 33h, AX=000Bh: Bewegung seit dem letzten Aufruf

**Eingabe:** `ax` = 000Bh

**Ausgabe:** `cx` = waagerechte, `dx` = senkrechte Bewegung in Mickeys (mit Vorzeichen)

Ein Mickey ist die kleinste Bewegung der Maus (etwa 1/200 Zoll). Für Spiele, die keinen Zeiger zeigen.

Verwandt: `int33:0003`

## int33:000c – Int 33h, AX=000Ch: eigene Routine für Ereignisse

**Eingabe:** `ax` = 000Ch, `cx` = Maske der Ereignisse (Bit 0 Bewegung, 1 links gedrückt, 2 links los, 3 rechts
gedrückt, 4 rechts los, 5 mitte gedrückt, 6 mitte los), `es:dx` = Adresse der Routine

**Ausgabe:** keine

Der Treiber ruft die Routine mit `call far` auf: `ax` = Ereignisse, `bx` = Tasten, `cx:dx` = Position,
`si:di` = Bewegung. Die Routine endet mit `retf` und darf kaum DOS-Funktionen rufen.

Verwandt: `int33:0003`

## int33:000f – Int 33h, AX=000Fh: Empfindlichkeit setzen

**Eingabe:** `ax` = 000Fh, `cx` = Mickeys je 8 Punkte waagerecht (Standard 8), `dx` = senkrecht (Standard 16)

**Ausgabe:** keine

Verwandt: `int33:000b`

## int28 – Int 28h: DOS ist untätig

**Eingabe:** keine (ein Interrupt, den DOS selbst auslöst)

**Ausgabe:** keine

DOS ruft ihn, solange es auf eine Eingabe wartet. Resident bleibende Programme hängen sich dort ein, weil dann
DOS-Funktionen erlaubt sind (das InDOS-Flag ist gesetzt, aber DOS ist nicht tief in einer Funktion).

Verwandt: `int21:34`, `int2f:16`

## int24 – Int 24h: kritischer Fehler

**Eingabe:** keine (DOS ruft die Routine bei einem Gerätefehler)

**Ausgabe:** `al` = 0 ignorieren, 1 wiederholen, 2 abbrechen, 3 die Funktion mit Fehler beenden

Die Routine, die „Abbrechen, Wiederholen, Ignorieren?“ zeigt. Ein Programm hängt einen eigenen Vektor ein, um
den Fehler selbst zu behandeln.

Verwandt: `int21:59`

## !label

**Label** (Sprungmarke): ein Name für eine Adresse. Sprünge, Aufrufe und Daten beziehen sich darauf.

## !missing

Zu `{name}` gibt es noch keine Erklärung.
