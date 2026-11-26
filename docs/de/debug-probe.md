# Die Raspberry Pi Debug Probe (noch nicht verlinkt)

> **Aufgehoben für ein eigenes Kapitel später.** Zurzeit beschreiben die Anleitungen den Pico und den Pico 2 nur über
> ihr USB-Kabel (die Konsole von Asmonite und ihr Debug-Monitor, siehe [riscv-pico2.md](riscv-pico2.md)); der Dialog
> Debug targets zeigt die Einstellungen der Probe nicht. Asmonite nimmt eine eingesteckte Probe weiterhin. Diese Seite
> bewahrt, was über die Probe geschrieben war, aus der Anleitung von Version 0.16.0.

## Was du brauchst

- eine **Debug-Probe** mit CMSIS-DAP: die Raspberry Pi Debug Probe oder ein zweiter Pico mit der Firmware
  `debugprobe`. Drei Drähte gehen an die Debug-Pins des Boards (SWCLK, GND, SWDIO); das Board bekommt seinen Strom über
  sein eigenes USB-Kabel.
- Die Probe braucht keinen Treiber; Windows nimmt sie als WinUSB-Gerät.

Nur ein Programm kann die Probe zur Zeit benutzen: Läuft OpenOCD oder ein anderer Debugger, schließe ihn (oder wähle
OpenOCD unter *Debug > Debug targets*, als Ausweichweg für die RISC-V-Kerne).

## Was die Probe zum USB-Kabel hinzufügt

- **Programme im Flash** (`.imagebase 0x10000000`): F7 / F9 löschen und schreiben nur die 4-KB-Sektoren, die sich
  unterscheiden, prüfen das Geschriebene und debuggen das Programm im Flash. Der erste Start eines neuen Programms
  dauert etwa eine Sekunde; ein unverändertes Programm wird nicht neu geschrieben. Über OpenOCD lässt sich der Flash
  nicht schreiben.
- **Die RISC-V-Kerne des Pico 2** (`.arch riscv32`): Der Debugger hält Kern 0 an, schreibt das Programm in den RAM bei
  `.imagebase`, setzt den pc auf `_start` und hält dort. Die Register `x0` bis `x31` (mit ihren Namen) und `pc`; 4
  Hardware-Breakpoints, die auch im Flash wirken.
- **Umschalten der Kerne des Pico 2:** Der Chip lässt nur eine Sorte Kerne zugleich laufen. Läuft die andere, schreibt
  der Debugger ein Flash-Programm der richtigen Sorte, setzt den Chip zurück und macht mit den Kernen des Programms
  weiter (etwa zwei Sekunden). Ein Programm im RAM kann nicht umschalten: Nach einem Reset startet der Boot-ROM die
  Kerne, für die das Programm im Flash ist; Asmonite sagt dann, dass zuerst ein Flash-Programm der richtigen Sorte zu
  starten ist (`blink_arm_flash.asm` oder `blink_flash.asm`). **RISC-V Cores** oder **Arm Cores** im Board Manager
  (Menü Board) schreibt das Beispiel `blink` der anderen Kerne in den Flash.
- **Die Arm-Kerne über SWD:** 8 Hardware-Breakpoints beim Cortex-M33; beginnt das Programm mit einer Vektortabelle,
  setzt der Debugger den Stackpointer daraus. Der Pico (RP2040): 4 Hardware-Breakpoints nur im Flash, im RAM
  `bkpt`-Befehle.
- Ein Programm für den Pico an einem Pico 2 (oder umgekehrt) wird mit dem Namen des Boards abgelehnt, bevor etwas
  geschrieben wird. Antworten die Kerne des RP2040 nach so einem Versuch nicht, setzt Asmonite sie über den
  Rescue-Port des Chips zurück.

## Debug targets

*Debug > Debug targets > Raspberry Pi Pico 2*: **The USB debug probe** (RISC-V- und Arm-Kerne) oder **OpenOCD as a
backup** (nur RISC-V-Kerne, sein GDB-Server an Host und Port; der Host ist `127.0.0.1` und der Port `3333`). *Test the
connection* sagt, ob das Board antwortet, ob der Kern läuft oder angehalten ist und welche Kerne laufen. Für den Pico:
*Test the connection* (sein USB-Boot, wenn ein Board darin ist, sonst die Probe) und *Set up the USB boot* (siehe
[picoboot.md](picoboot.md)). Diese Felder sind im Dialog zurzeit ausgeblendet.

Wenn beides da ist, die Konsole an USB und eine Probe: Der Debugger nimmt die Konsole, wenn der Tab Serial an der
USB-Konsole ist, sonst die Probe. Hält die Probe den Kern noch als Debugger (nach einer SWD-Sitzung, die nicht sauber
endete), lehnt der Monitor des Pico 2 ab und sagt es: Board einmal ab- und wieder anstecken.

## Die serielle Ausgabe über die Probe

Die Raspberry Pi Debug Probe hat auch einen seriellen Port: Ihr zweiter Anschluss, **„U“**, ist ein UART mit einem
eigenen COM-Port am PC (neben dem SWD an „D“, über dasselbe USB-Kabel). Sein Kabel geht so an das Board:

| Probe, Anschluss „U“ | Pico 2, Pico | Blue Pill |
|---|---|---|
| RX (Eingang der Probe; gelb am Kabel der Probe) | GP0, Pin 1 (TX von UART0) | PA9 (TX von USART1) |
| TX (Ausgang der Probe; orange) | GP1, Pin 2 (RX von UART0) | PA10 (RX von USART1) |
| GND (schwarz) | GND, Pin 3 | G |

Hat eine Sitzung über die Probe das Programm geladen, verbindet sich der Tab **Serial** von selbst mit diesem COM-Port
und zeigt, was das Board sendet (voreingestellt 115200 Baud). Die Beispiele `examples/pico2/hello_uart_ram.asm`
(RISC-V), `hello_uart_arm_ram.asm` (Arm), `examples/pico/hello_uart_ram.asm` und `examples/stm32/hello_uart_ram.asm`
schreiben etwa einmal pro Sekunde „Hello, world!“ mit 115200 Baud: RP2040 und RP2350 starten dafür zuerst ihren
12-MHz-Quarz, der STM32 läuft von seinem 8-MHz-HSI. Die Probe gibt Empfangenes nur an ein Terminal weiter, das die
Leitung DTR an hat; der Tab Serial tut das für sie. Öffnet ein Terminal den COM-Port der Probe, während das Board ohne
Pause sendet, kommen die Zeichen bis zur ersten Pause verstümmelt: eine Eigenheit der Probe.

Die Konsole von Asmonite spricht auch über UART0 (GP0, GP1), also auch über den Anschluss „U“. **Prepare Board** mit
dem Pico 2 (Debug Probe) oder dem Pico (Debug Probe) links schreibt die Konsole über die Probe in den Flash.

## Ein USB-Gerät ohne SDK

`examples/pico/usb_echo_ram.asm` (Pico) und `examples/pico2/usb_echo_ram.asm` (Pico 2, Arm-Kerne) machen das Board zu
einem COM-Port am PC über sein eigenes USB-Kabel (USB CDC-ACM), ganz in Assembler, ohne Pico SDK und ohne TinyUSB.
Der Code für beide steht in `examples/pico/usb_cdc.asm`. So ein Programm belegt den USB-Port des Boards selbst, darum
braucht es die Probe: die Probe an SWD **und** das USB-Kabel des Boards am PC, dann F9. Windows zeigt einen neuen
COM-Port (Treiber `usbser.sys`); das Board grüßt, und was du tippst, kommt zurück. Die Kennung 0x1209/0x0001 ist die
Testnummer von pid.codes: nur für Tests am eigenen Schreibtisch.

## Wenn sie sich nicht verbindet

- *No debug probe ... only one program at a time*: Ein anderes Programm hat die Probe (OpenOCD, ein anderes Asmonite).
  Schließe es.
- *The board does not answer over SWD*: Das Board hat keinen Strom, die drei Drähte sind falsch oder lose, oder die
  Probe ist nicht die Debug Probe. Die Drähte: SWCLK, SWDIO, GND.
- *The board is an RP2040 ...* (oder *not an RP2350*, *no RP2040*): Das Board an der Probe ist nicht das von
  `.target`.

## Der STM32F103 („Blue Pill“)

Er hat keine Konsole von Asmonite: Er wird nur über die Probe debuggt, siehe [stm32.md](stm32.md).
