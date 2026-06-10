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
echo "Cloning libogg from ${LIBOGG_REPOSITORY}..."
echo "===================================================="
git clone "${LIBOGG_REPOSITORY}" libogg
cd libogg
git checkout "${LIBOGG_REF}"
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared
make -j"$(nproc)"
make install
cd ..

# 2. Build libopus
echo "===================================================="
echo "Cloning libopus from ${LIBOPUS_REPOSITORY}..."
echo "===================================================="
git clone "${LIBOPUS_REPOSITORY}" libopus
cd libopus
git checkout "${LIBOPUS_REF}"
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared
make -j"$(nproc)"
make install
cd ..

export PKG_CONFIG_PATH="${DEPS_PREFIX}/lib/pkgconfig"

# 3. Build libflac
echo "===================================================="
echo "Cloning libflac from ${LIBFLAC_REPOSITORY}..."
echo "===================================================="
git clone "${LIBFLAC_REPOSITORY}" libflac
cd libflac
git checkout "${LIBFLAC_REF}"
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared --disable-oggtest --disable-cpplibs
make -j"$(nproc)"
make install
cd ..

# 4. Build libopusenc
echo "===================================================="
echo "Cloning libopusenc from ${LIBOPUSENC_REPOSITORY}..."
echo "===================================================="
git clone "${LIBOPUSENC_REPOSITORY}" libopusenc
cd libopusenc
git checkout "${LIBOPUSENC_REF}"
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared
make -j"$(nproc)"
make install
cd ..

# 5. Build libopusfile
echo "===================================================="
echo "Cloning libopusfile from ${LIBOPUSFILE_REPOSITORY}..."
echo "===================================================="
git clone "${LIBOPUSFILE_REPOSITORY}" libopusfile
cd libopusfile
git checkout "${LIBOPUSFILE_REF}"
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared --disable-http
make -j"$(nproc)"
make install
cd ..

cd .. # leave build-temp
rm -rf build-temp

echo "All dependencies compiled and installed to ${DEPS_PREFIX} successfully!"
