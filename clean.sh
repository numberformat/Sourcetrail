#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

if [[ -d "${BUILD_DIR}" ]]; then
	echo "Removing ${BUILD_DIR}"
	rm -rf "${BUILD_DIR}"
else
	echo "No build directory found at ${BUILD_DIR}"
fi

echo "Clean complete."
