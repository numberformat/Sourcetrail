#!/usr/bin/env bash

set -euo pipefail

BUILD_TYPE="${1:-Release}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build/${BUILD_TYPE}"
CONAN_OUTPUT_DIR="${BUILD_DIR}"
TOOLCHAIN_FILE="${CONAN_OUTPUT_DIR}/build/${BUILD_TYPE}/generators/conan_toolchain.cmake"

if ! command -v conan >/dev/null 2>&1; then
	echo "Error: conan is not in PATH. Install it first (e.g. 'pip install conan')." >&2
	exit 1
fi

if ! command -v cmake >/dev/null 2>&1; then
	echo "Error: cmake is not in PATH. Install CMake 3.12+ and try again." >&2
	exit 1
fi

conan_os_version_args=()
if [[ "$(uname -s)" == "Darwin" ]]; then
	export SDKROOT="$(xcrun --show-sdk-path)"
	export CPLUS_INCLUDE_PATH="${SDKROOT}/usr/include/c++/v1${CPLUS_INCLUDE_PATH:+:${CPLUS_INCLUDE_PATH}}"
	macos_version="$(sw_vers -productVersion | cut -d. -f1-2)"
	conan_os_version_args=(-s "os.version=${macos_version}")
fi

echo "==> Running Conan install (${BUILD_TYPE})"
conan install "${SCRIPT_DIR}" \
	--output-folder="${CONAN_OUTPUT_DIR}" \
	--build=missing \
	-s "build_type=${BUILD_TYPE}" \
	"${conan_os_version_args[@]}"

if [[ ! -f "${TOOLCHAIN_FILE}" ]]; then
	echo "Error: expected Conan toolchain at ${TOOLCHAIN_FILE} but it was not generated." >&2
	exit 1
fi

echo "==> Configuring CMake"
cmake -S "${SCRIPT_DIR}" \
	-B "${BUILD_DIR}" \
	-DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
	-DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}"

echo "==> Building Sourcetrail"
cmake --build "${BUILD_DIR}" --config "${BUILD_TYPE}" --target Sourcetrail

echo "Build completed. Artifacts are in ${BUILD_DIR}"
