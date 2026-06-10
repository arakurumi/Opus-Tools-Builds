#!/usr/bin/env bash
# Script to build static dependencies (libogg, libopus, libflac, libopusenc, libopusfile)
set -euo pipefail

# Determine prefix directory (handling MSYS2 paths on Windows)
if command -v cygpath >/dev/null; then
  workspace="$(cygpath -u "${GITHUB_WORKSPACE}")"
else
  workspace="${GITHUB_WORKSPACE}"
fi

export DEPS_PREFIX="${workspace}/static-deps"
mkdir -p "${DEPS_PREFIX}"

# We'll build dependencies in a build-temp subdirectory
mkdir -p build-temp
cd build-temp

# 1. Build libogg
echo "===================================================="
# Using libogg tag/branch if needed, default to main/master
echo "Cloning libogg from github.com/xiph/ogg..."
echo "===================================================="
git clone --depth 1 https://github.com/xiph/ogg.git libogg
cd libogg
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared
make -j"$(nproc)"
make install
cd ..

# 2. Build libopus
echo "===================================================="
echo "Cloning libopus from github.com/xiph/opus..."
echo "===================================================="
git clone --depth 1 https://github.com/xiph/opus.git libopus
cd libopus
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared
make -j"$(nproc)"
make install
cd ..

export PKG_CONFIG_PATH="${DEPS_PREFIX}/lib/pkgconfig"

# 3. Build libflac
echo "===================================================="
echo "Cloning libflac from github.com/xiph/flac..."
echo "===================================================="
git clone --depth 1 https://github.com/xiph/flac.git libflac
cd libflac
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared --disable-oggtest --disable-cpplibs
make -j"$(nproc)"
make install
cd ..

# 4. Build libopusenc
echo "===================================================="
echo "Cloning libopusenc from github.com/xiph/libopusenc..."
echo "===================================================="
git clone --depth 1 https://github.com/xiph/libopusenc.git libopusenc
cd libopusenc
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared
make -j"$(nproc)"
make install
cd ..

# 5. Build libopusfile
echo "===================================================="
echo "Cloning libopusfile from github.com/xiph/opusfile..."
echo "===================================================="
git clone --depth 1 https://github.com/xiph/opusfile.git libopusfile
cd libopusfile
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared --disable-http
make -j"$(nproc)"
make install
cd ..

cd .. # leave build-temp
rm -rf build-temp

echo "All dependencies compiled and installed to ${DEPS_PREFIX} successfully!"
