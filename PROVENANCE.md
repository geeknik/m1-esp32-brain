# Factory image provenance

Every brain release must be traceable to exact sources and tools. Future
releases build only via `tools/build_factory.sh`, which refuses to run while
the ESP-IDF pin in `tools/IDF_PIN` is unset and emits a manifest to append
here.

| Version | Commit | Built | ESP-IDF | Factory image (sha256) | Status |
|---|---|---|---|---|---|
| 1.5.0 | `e515182` | 2026-08-01 16:28:00 | v5.1.2-**dirty** | `131cd8f84ac715ef0f3d05aa684db8101c5567011fe7c9ac19b6863f94de51f5` | **Captured** — see notes |

## v1.5.0 capture notes (2026-10-29)

- Source: upstream release [bedge117/m1-esp32-brain `v1.5.0`](https://github.com/bedge117/m1-esp32-brain/releases/tag/v1.5.0), asset `factory_ESP32C6-SPI.bin` (1,684,528 bytes).
- md5 `d975daa8180f48c2ae63f158829ff51a` matches the shipped `.md5` asset.
- App descriptor (extracted from the app partition at 0x60000): version
  `1.5.0`, project `m1-esp32-brain`, build `16:28:00 Aug 1 2026`,
  **ESP-IDF `v5.1.2-dirty`**, app_elf_sha256 `ab6be8ba8d6dd1088455a071dcbf1943eac0660f7b47e8bf3cb90d8955366ad7`.
- The `-dirty` suffix means the original was built from a locally modified
  ESP-IDF v5.1.2 tree. A clean v5.1.2 rebuild is therefore **not guaranteed
  bit-identical**; verify by hash comparison before treating a rebuild as a
  substitute. `tools/IDF_PIN` is set to `v5.1.2`.

## Pairing note

M1OS 1.1.81+ (github.com/geeknik/M1OS) pairs with brain 1.5.0 over the SPI
wire contract (`components/m1_rpc/include/m1_rpc.h`). M1OS enforces copy
parity with `tools/check_esp_contract.py` on every build and in CI — changing
this header on either side must happen in both repos in the same change.
