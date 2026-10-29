<!-- See COPYING.txt for license details. -->

# M1 ESP32-C6 Brain Firmware

Native ESP-IDF co-processor firmware for the [Monstatek M1](https://monstatek.com)'s
ESP32-C6. It runs the M1's radio features (WiFi, Bluetooth, 802.15.4, ESP-NOW peer
link) natively and talks to the M1's STM32 over a custom binary SPI link
(`m1_link`).

This is the ESP32 firmware used by **C3** M1 firmware (v0.8.0.0-C3.107 and later).

> **This is a community project and is not affiliated with or endorsed by Monstatek.**

## Compatibility

The M1 and its ESP32-C6 must run matching firmware. This brain firmware pairs with
**C3 v0.8.0.0-C3.107+**. It is **not** compatible with genuine stock Monstatek
firmware (which uses a different ESP32 firmware). See the full
[compatibility reference](https://github.com/bedge117/M1/blob/main/COMPATIBILITY.md).

## Flashing

Flash via the qMonstatek desktop app (ESP32 Update) — "Download latest (SPI brain)"
fetches the current factory image and writes it at `0x0`.

- `factory_m1-esp32-brain.bin` — full image (bootloader + partition table + app), flash at `0x0`
- `app_m1-esp32-brain.bin` — app partition only, flash at `0x60000` (only when the bootloader/partition table are unchanged)

## Building

Use `tools/build_factory.sh` after sourcing ESP-IDF's `export.sh`. It enforces
the ESP-IDF pin in `tools/IDF_PIN` (currently `unset` — the original 1.5.0
build's IDF was never recorded; see [PROVENANCE.md](PROVENANCE.md) for how to
capture it from a hardware-verified image), builds from the committed
`sdkconfig.defaults`, merges the factory image, and emits a provenance
manifest. Do not hand-roll factory images: an untracked toolchain or sdkconfig
produces an image that cannot be reproduced or audited.
