#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -lt 1 ]]; then
  echo "Usage: tool/flutter_safe.sh <flutter-subcommand> [args...]"
  echo "Example: tool/flutter_safe.sh test"
  exit 64
fi

run_in_dir() {
  local target_dir="$1"
  shift
  (
    cd "$target_dir"
    flutter "$@"
  )
}

copy_repo_without_generated_state() {
  local target_dir="$1"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a \
      --exclude='.git' \
      --exclude='.dart_tool' \
      --exclude='build' \
      "$ROOT_DIR/" "$target_dir/"
  else
    cp -R "$ROOT_DIR/." "$target_dir"
    rm -rf "$target_dir/.git" "$target_dir/.dart_tool" "$target_dir/build"
  fi
}

if [[ "$ROOT_DIR" == *"'"* ]]; then
  readonly flutter_cmd="$1"
  shift

  case "$flutter_cmd" in
    test|analyze|drive)
      TMP_ROOT="${TMPDIR:-/tmp}"
      TMP_DIR="$(mktemp -d "${TMP_ROOT%/}/im_muslim_safe.XXXXXX")"
      cleanup() {
        rm -rf "$TMP_DIR"
      }
      trap cleanup EXIT

      copy_repo_without_generated_state "$TMP_DIR"
      run_in_dir "$TMP_DIR" pub get >/dev/null
      run_in_dir "$TMP_DIR" "$flutter_cmd" "$@"
      ;;
    *)
      SAFE_LINK="${TMPDIR:-/tmp}/im_muslim_safe_${USER:-runner}_$$"
      cleanup() {
        rm -f "$SAFE_LINK"
      }
      trap cleanup EXIT

      ln -s "$ROOT_DIR" "$SAFE_LINK"
      run_in_dir "$SAFE_LINK" "$flutter_cmd" "$@"
      ;;
  esac
else
  run_in_dir "$ROOT_DIR" "$@"
fi
