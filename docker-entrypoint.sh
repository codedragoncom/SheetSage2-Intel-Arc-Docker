#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 INPUT_AUDIO [OUTPUT_DIR] [extra infer.py options...]" >&2
  exit 2
fi

INPUT_AUDIO="$1"
OUTPUT_DIR="${2:-/output}"
shift
if [[ $# -gt 0 ]]; then shift; fi

unset LD_LIBRARY_PATH

exec python /models/SheetSage2/infer.py \
  "$INPUT_AUDIO" \
  --model /models/SheetSage2 \
  --output "$OUTPUT_DIR" \
  --device xpu \
  --dtype bf16 \
  --render-score \
  --render-audio \
  "$@"
