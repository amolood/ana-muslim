#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: tool/profile_android.sh <device_id> [extra flutter run flags]"
  echo "Example: tool/profile_android.sh AS7J6R4A11005927 --trace-skia"
  exit 64
fi

DEVICE_ID="$1"
shift || true

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Starting Flutter app in Profile mode on device: ${DEVICE_ID}"
echo "Workspace: ${ROOT_DIR}"
echo "Tip: open DevTools from the VM Service URL shown below."

cd "${ROOT_DIR}"
bash tool/flutter_safe.sh run --profile -d "${DEVICE_ID}" "$@"
