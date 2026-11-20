; The console of Asmonite on the Pico 2: no ESP8285. The functions of boards\pico\console_esp.asm (the WiFi chip of
; the clones "Pico W-2023", RP2040 boards) that boards\pico\console_wifi.asm calls, doing nothing: esp_mode says no
; ESP, so the others are not reached (esp_detect: only on an RP2040). Thumb.

esp_mode:
    movs r0, #0
    bx   lr

esp_detect:
esp_chip:
esp_off:
esp_scan:
esp_start:
esp_leave:
esp_join:
esp_mac:
esp_service:
esp_send:
    movs r0, #1
    bx   lr
