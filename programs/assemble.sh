#!/bin/bash

# note: claude made this script.

# Usage: ./assemble.sh mips.asm

INPUT=$1
BASENAME="${INPUT%.*}"

if [ -z "$INPUT" ]; then
    echo "Usage: $0 <assembly_file.asm>"
    exit 1
fi

if [ ! -f "$INPUT" ]; then
    echo "Error: file '$INPUT' not found"
    exit 1
fi

echo "==> Assembling $INPUT..."
TMP=$(mktemp)
mips-linux-gnu-as -EB "$INPUT" -o "$TMP"

echo "==> Extracting .text section..."
mips-linux-gnu-objcopy -O binary --only-section=.text "$TMP" "$BASENAME.bin"
rm "$TMP"

echo ""
echo "==> Hex dump:"
xxd "$BASENAME.bin"

echo ""
echo "==> Disassembly:"
mips-linux-gnu-objdump -D -EB -b binary -m mips "$BASENAME.bin"

echo ""
echo "==> VHDL format:"
xxd -p "$BASENAME.bin" | fold -w2 | awk '{printf "x\"%s\", ", toupper($0)}' | tr -d '\n' && echo ""
echo ""

echo ""
echo "Done! Output file: $BASENAME.bin"
