# Befehlsinfo (F1)

Die Befehlsinfo erklärt, was eine Zeile tut: den Befehl, die Windows-Funktion, die sie aufruft, den
DOS-Interrupt, die Direktive des Assemblers und auch Fehlermeldungen. Sie steht in beiden Programmen, mit
denselben Texten.

## Öffnen

- **Asmonite:** **F1** im Editor. Die Hilfe erscheint in der Spalte rechts, neben der Registerliste (Reiter
  **Help**). Sie zeigt, was die Zeile mit dem Cursor braucht. Sie ändert sich nur, wenn du wieder F1
  drückst; **x** in ihrer Titelzeile schließt sie.
- **Dismonite:** **F1** auf einer Zeile. Rechts erscheint der Reiter **Info**. Er folgt dem Cursor
  (*Help > Info follows the cursor* schaltet das ab); **x** schließt ihn.

## Was sie erklärt

| Auf der Zeile | Die Hilfe zeigt |
| --- | --- |
| ein Befehl (`mov`, `push`, `add r0, r1, #1`) | Syntax, erlaubte Operanden, Flags, ein Beispiel; für x86 und x64, ARM (Thumb-2, `.arch thumb`), ARM64, RISC-V (32 und 64 Bit) und Xtensa, nach dem `.arch` des Quelltexts. Ein Befehl ohne eigene Erklärung zeigt seinen kurzen Abschnitt aus der Befehlsreferenz (Syntax, Wirkung, Flags); nach einem x87- oder SSE-Befehl folgt der Überblick `x87` oder `sse` |
| der Aufruf einer importierten Funktion (`call [ExitProcess]`, `ldr r3, =CloseHandle`) | die DLL, die Aufrufkonvention, jeden Parameter mit Typ und Bedeutung, das Ergebnis, eine kurze Erklärung |
| `int 21h`, `int 10h`, `int 13h` ... | die Funktion (ihre Nummer steht in `ah`; die Info sucht sie in den Zeilen davor), Ein- und Ausgaberegister, Fehlercodes |
| eine Direktive (`.arch`, `.format`, `.import`, `section` ...) | was sie bewirkt und ein Beispiel |
| eine Fehlermeldung | was sie bedeutet, woran es meistens liegt, wie man es behebt |

Die importierten Funktionen stammen aus `help\<Sprache>\winapi.md` (kernel32, user32, gdi32, advapi32,
shell32, msvcrt und die universelle C-Laufzeit, über 230 Funktionen). Eine Funktion ohne Beschreibung
erscheint mit Name und DLL.

## Fehlermeldungen

- **Im Editor:** Nach einer fehlgeschlagenen Übersetzung ist die Zeile mit dem ersten Fehler rot. F1 auf
  dieser Zeile erklärt die Meldung.
- **Im Ausgabefenster:** Eine Zeile der Meldung anklicken und F1 drücken. Das geht für die Meldungen des
  Assemblers und für die Zeilen der PE-Prüfung („DLL not found“, „function not found in ...“).

## Sprache

*Help > Help language* schaltet sofort zwischen Deutsch und English um; die Wahl wird gespeichert
(`Asmonite.ini` oder `Dismonite.ini`). Ohne Wahl gilt die Sprache der Windows-Oberfläche: Deutsch bei einem
deutschen Windows, sonst Englisch.

## Grenzen

- Die Funktion eines DOS-Interrupts wird nur gefunden, wenn `ah` (oder `ax`) in den Zeilen direkt davor
  durch ein `mov` oder `xor` gesetzt wird; ist es nicht klar, erscheint die Übersicht des Interrupts.
- Die Texte sind zum Lernen geschrieben: Seltene Einzelheiten fehlen. Die Systemdokumentation der Funktion
  bleibt die Referenz.
