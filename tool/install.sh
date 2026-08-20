#!/bin/bash
# Offline install script for pip packages (black + isort)
# Run this on the offline machine after copying the tool/ directory.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON="$SCRIPT_DIR/python-3.10/bin/python3"

echo "=== Installing pip packages (offline) ==="

if [[ ! -x "$PYTHON" ]]; then
    echo "ERROR: Python not found at $PYTHON"
    echo "Run download.sh first on a machine with internet."
    exit 1
fi

# Install wheels from pip-wheels/ directory
if [[ -d "$SCRIPT_DIR/pip-wheels" ]] && [[ -n "$(ls -A "$SCRIPT_DIR/pip-wheels" 2>/dev/null)" ]]; then
    echo "Installing black + isort from local wheels..."
    "$PYTHON" -m pip install --no-index --find-links="$SCRIPT_DIR/pip-wheels" black isort
    echo "Done."
else
    echo "No pip-wheels/ directory found or it's empty."
    echo "Run download.sh on a machine with internet to download the wheels."
fi

# Verify
echo ""
echo "=== Verification ==="
if "$PYTHON" -c "import black" 2>/dev/null; then
    echo "  black: OK"
else
    echo "  black: NOT INSTALLED"
fi
if "$PYTHON" -c "import isort" 2>/dev/null; then
    echo "  isort: OK"
else
    echo "  isort: NOT INSTALLED"
fi