#!/bin/bash
# AWS Assume Role CLI - Universal Bash Wrapper
# Detects platform and executes appropriate binary

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# OS Detection with Debugging
os_type=""
echo "[awsr debug] OSTYPE: $OSTYPE" >&2
echo "[awsr debug] uname -s: $(uname -s)" >&2

case "$OSTYPE" in
  linux-gnu*) os_type="linux" ;;
  darwin*)    os_type="macos" ;;
  cygwin|msys|win32) os_type="windows" ;;
  *)
    # Fallback to uname for other environments (like Git Bash on Windows)
    case "$(uname -s)" in
      Linux*)   os_type="linux" ;;
      Darwin*)  os_type="macos" ;;
      MINGW*|MSYS*|CYGWIN*) os_type="windows" ;;
      *)
        echo "❌ Unsupported platform. OSTYPE: $OSTYPE, uname: $(uname -s)" >&2
        exit 1
        ;;
    esac
    ;;
esac

echo "[awsr debug] Detected OS: $os_type" >&2

case "$os_type" in
  linux)   BINARY="$SCRIPT_DIR/aws-assume-role-linux" ;;
  macos)   BINARY="$SCRIPT_DIR/aws-assume-role-macos" ;;
  windows) BINARY="$SCRIPT_DIR/aws-assume-role-windows.exe" ;;
esac

# Check if binary exists
if [[ ! -f "$BINARY" ]]; then
    echo "❌ Binary not found for detected OS '$os_type': $BINARY" >&2
    echo "Available files in $SCRIPT_DIR:" >&2
    ls -la "$SCRIPT_DIR"/ >&2
    exit 1
fi

# Execute with all arguments
exec "$BINARY" "$@"
