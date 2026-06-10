#!/usr/bin/env bash
# Script to build opus-tools
set -euo pipefail

# Determine paths
if command -v cygpath >/dev/null; then
  workspace="$(cygpath -u "${GITHUB_WORKSPACE}")"
else
  workspace="${GITHUB_WORKSPACE}"
fi

export DEPS_PREFIX="${workspace}/static-deps"
export PKG_CONFIG_PATH="${DEPS_PREFIX}/lib/pkgconfig"

# Build inside source directory
cd source
./autogen.sh

if [[ "$(uname -s)" == *"NT"* || "$(uname -s)" == *"MINGW"* || "$(uname -s)" == *"MSYS"* ]]; then
  echo "Building opus-tools for Windows (MSYS2)..."
  ./configure --prefix="${workspace}/dist" --enable-static --disable-shared PKG_CONFIG="pkg-config --static" LDFLAGS="-static"
else
  echo "Building opus-tools for Linux..."
  ./configure --prefix="${workspace}/dist" --enable-static --disable-shared PKG_CONFIG="pkg-config --static" LDFLAGS="-all-static"
fi

make -j"$(nproc)"
make install
