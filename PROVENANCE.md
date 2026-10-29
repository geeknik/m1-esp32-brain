# Factory image provenance

Every brain release must be traceable to exact sources and tools. The 1.5.0
release predates this policy: its ESP-IDF version was not recorded and its
`sdkconfig` was not committed, so the deployed image **cannot currently be
bit-rebuilt from the repo**. Close that gap by (a) capturing the true IDF from
a hardware-verified image and filling the pin below, and (b) building future
releases only via `tools/build_factory.sh`, which refuses to run unpinned and
emits a manifest to append here.

| Version | Commit | Date | ESP-IDF | Factory image sha256 | Status |
|---|---|---|---|---|---|
| 1.5.0 | `e515182` | 2026-08-03 | unknown — capture via `esptool.py image_info` | unknown — dump from device or qMonstatek download | **Unverifiable** |
| | | | | | |

## Pairing note

M1OS 1.1.80.0 (github.com/geeknik/M1OS) pairs with brain 1.5.0 over the SPI
wire contract (`components/m1_rpc/include/m1_rpc.h`). M1OS enforces copy
parity with `tools/check_esp_contract.py` on every build — changing this
header on either side must happen in both repos in the same change.
