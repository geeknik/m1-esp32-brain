#!/bin/sh
# build_factory.sh — reproducible factory build for m1-esp32-brain.
#
# Why this exists: the 1.5.0 release was built with an unrecorded ESP-IDF and
# an uncommitted sdkconfig, so the deployed firmware could not be bit-rebuilt
# from the repo (see PROVENANCE.md). This script makes every future factory
# image self-describing: it refuses to run until the IDF version is pinned in
# tools/IDF_PIN, builds from the committed sdkconfig.defaults only, and writes
# a manifest recording toolchain, git state, and image hashes.
#
# Usage (after sourcing ESP-IDF's export.sh so idf.py is on PATH):
#   tools/build_factory.sh
set -e

cd "$(dirname "$0")/.."
REPO_ROOT=$(pwd)

PIN_FILE="tools/IDF_PIN"
IDF_PIN=$(grep -Ev '^\s*(#|$)' "$PIN_FILE" | tail -1 | tr -d ' \t')

if [ "$IDF_PIN" = "unset" ] || [ -z "$IDF_PIN" ]; then
    echo "error: tools/IDF_PIN is 'unset' — the ESP-IDF that produced the" >&2
    echo "       deployed 1.5.0 image has not been captured yet." >&2
    echo "       Obtain a hardware-verified factory image, run:" >&2
    echo "           esptool.py image_info <app.bin>   # prints 'ESP-IDF: vX.Y.Z'" >&2
    echo "       write that version into tools/IDF_PIN, then rebuild." >&2
    exit 1
fi

command -v idf.py >/dev/null 2>&1 || {
    echo "error: idf.py not on PATH — source ESP-IDF export.sh first." >&2
    exit 1
}

IDF_VER=$(idf.py --version 2>/dev/null | awk '{print $2}')
if [ "$IDF_VER" != "$IDF_PIN" ]; then
    echo "error: ESP-IDF version mismatch: found $IDF_VER, pinned $IDF_PIN" >&2
    echo "       (switch IDF or update tools/IDF_PIN deliberately, with a" >&2
    echo "        PROVENANCE.md note explaining why the pin moved.)" >&2
    exit 1
fi

GIT_COMMIT=$(git rev-parse --short=8 HEAD 2>/dev/null || echo "nogit")
GIT_DIRTY=0
git diff --quiet HEAD 2>/dev/null || GIT_DIRTY=1

BUILD_DIR=build-factory
OUT_DIR=artifacts
mkdir -p "$OUT_DIR"

echo "Building with ESP-IDF $IDF_VER (commit=$GIT_COMMIT dirty=$GIT_DIRTY)..."
idf.py -B "$BUILD_DIR" \
    -DSDKCONFIG_DEFAULTS="sdkconfig.defaults" \
    -DIDF_TARGET="esp32c6" \
    build

APP_BIN="$BUILD_DIR/m1-esp32-brain.bin"
[ -f "$APP_BIN" ] || { echo "error: expected app image not found: $APP_BIN" >&2; exit 1; }

echo "Merging factory image (bootloader + partition table + app @0x0)..."
idf.py -B "$BUILD_DIR" merge-bin \
    --flash-size 4MB \
    --output "$OUT_DIR/factory_m1-esp32-brain.bin"
cp "$APP_BIN" "$OUT_DIR/app_m1-esp32-brain.bin"

FW_VER=$(sed -n 's/^set(PROJECT_VER "\(.*\)")$/\1/p' CMakeLists.txt | tr -d ' ')
MANIFEST="$OUT_DIR/PROVENANCE-${FW_VER}-${GIT_COMMIT}.txt"
{
    echo "firmware_version=$FW_VER"
    echo "commit=$GIT_COMMIT"
    echo "dirty=$GIT_DIRTY"
    echo "esp_idf=$IDF_VER"
    echo "sdkconfig_defaults=sdkconfig.defaults"
    echo "build_timestamp_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    for f in "$OUT_DIR/factory_m1-esp32-brain.bin" "$OUT_DIR/app_m1-esp32-brain.bin"; do
        echo "file=$(basename "$f")"
        echo "  size_bytes=$(wc -c < "$f" | tr -d ' ')"
        echo "  md5=$(md5 -q "$f" 2>/dev/null || md5sum "$f" | cut -d' ' -f1)"
        echo "  sha256=$(shasum -a 256 "$f" | cut -d' ' -f1)"
    done
} > "$MANIFEST"

echo "Provenance manifest:"
cat "$MANIFEST"
echo "Done. Append the manifest fields to PROVENANCE.md when qualifying the image."
