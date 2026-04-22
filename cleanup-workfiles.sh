#!/usr/bin/env bash
set -euo pipefail

# Cleanup helper for repo-root work artifacts so commit diffs stay focused.
# Default mode only removes transient listing/symbol outputs.
# Use --build-artifacts to also remove local build outputs.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
INCLUDE_BUILD=0

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --build-artifacts) INCLUDE_BUILD=1 ;;
        -h|--help)
            cat <<'USAGE'
Usage: ./cleanup-workfiles.sh [--dry-run] [--build-artifacts]

Options:
  --dry-run           Show files that would be removed.
  --build-artifacts   Also remove compiled binaries/object files.
USAGE
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            echo "Try: ./cleanup-workfiles.sh --help" >&2
            exit 2
            ;;
    esac
done

remove_file() {
    local target="$1"
    if [[ -e "$target" ]]; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "would remove: ${target#$ROOT_DIR/}"
        else
            rm -f "$target"
            echo "removed: ${target#$ROOT_DIR/}"
        fi
    fi
}

remove_glob() {
    local pattern="$1"
    shopt -s nullglob
    local files=( $pattern )
    shopt -u nullglob
    for f in "${files[@]}"; do
        remove_file "$f"
    done
}

# Always-safe transient outputs in repo root.
remove_file "$ROOT_DIR/export.lis"
remove_file "$ROOT_DIR/export.sym"

if [[ "$INCLUDE_BUILD" -eq 1 ]]; then
    # Local build outputs (root).
    remove_file "$ROOT_DIR/export.o"
    remove_file "$ROOT_DIR/z80bench"
    remove_file "$ROOT_DIR/z80bench-cli"

    # Local build outputs (submodule working tree).
    remove_file "$ROOT_DIR/external/z80bench/z80bench"
    remove_file "$ROOT_DIR/external/z80bench/z80bench-cli"
    remove_file "$ROOT_DIR/external/z80bench/z80bench-test"
    remove_glob "$ROOT_DIR/external/z80bench/src/*.o"
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "dry-run complete."
else
    echo "cleanup complete."
fi
