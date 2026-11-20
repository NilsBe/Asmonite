# Examples

The examples of Asmonite, in assembly and in aBelle. Each one here has been gone through again and tested on the
boards it is for; more follow one by one.

- `common/`: programs in aBelle that run on every board (ESP32, ESP32-S3, ESP32-C3, ESP32-S31, Raspberry Pi Pico
  and Pico 2 (W)); Asmonite translates them for the board you use.
  - `common/hello.abel`: writes "Hello, world!" over the serial output of the board (F9).
  - `common/blink.abel`: blinks the LED of the board; set `LED_PIN` for your board at its top first.
  - `common/runs.abel`: counts how often it has run, in the file `runs.txt` on the board (`file_size`, `file_read`,
    `file_write`); the number stays when the power is off. `cat runs.txt` in the console shows it, `rm runs.txt`
    starts again.
  - `common/scan.abel`: the WiFi networks near the board (signal, channel, protection, BSSID, name); for the boards
    with WiFi.
  - `common/arpscan.abel`: who is in the network: asks every address of its /24 network by ARP and lists the
    devices that answer with their MAC; the board needs a network (`wlan set` in the console).
  - `common/ping.abel`: pings the router and a server in the internet (four echo requests each) and shows the
    times as the ping of a PC does; with an argument (`run ping 192.168.1.20` or `run ping example.com`) that host.
  - `common/pingled.abel`: the LED of the board flashes at each ping it answers; ping the address it shows from a
    PC or a phone. Set `LED_PIN` for your board at its top first; the board needs a network (`wlan set` in the
    console).
- `<board>/`: programs for one board only, because they use its hardware (pins, sensors, its LED).
  - `esp32s31/rgbblink.abel`: blinks the RGB LED of the ESP32-S31 board (a WS2812 at GPIO 60) by `rgb()` of its
    console; set `COLOUR` at its top.

German: [README.de.md](README.de.md).
