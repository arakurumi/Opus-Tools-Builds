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
echo "Cloning libogg (${LIBOGG_REF}) from ${LIBOGG_REPOSITORY}..."
echo "===================================================="
git clone --depth 1 --branch "${LIBOGG_REF}" "${LIBOGG_REPOSITORY}" libogg
cd libogg
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared
make -j"$(nproc)"
make install
cd ..

# 2. Build libopus
echo "===================================================="
echo "Cloning libopus (${LIBOPUS_REF}) from ${LIBOPUS_REPOSITORY}..."
echo "===================================================="
git clone --depth 1 --branch "${LIBOPUS_REF}" "${LIBOPUS_REPOSITORY}" libopus
cd libopus
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared
make -j"$(nproc)"
make install
cd ..

export PKG_CONFIG_PATH="${DEPS_PREFIX}/lib/pkgconfig"

# 3. Build libflac
echo "===================================================="
echo "Cloning libflac (${LIBFLAC_REF}) from ${LIBFLAC_REPOSITORY}..."
echo "===================================================="
git clone --depth 1 --branch "${LIBFLAC_REF}" "${LIBFLAC_REPOSITORY}" libflac
cd libflac
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared --disable-oggtest --disable-cpplibs
make -j"$(nproc)"
make install
cd ..

# 4. Build libopusenc
echo "===================================================="
echo "Cloning libopusenc (${LIBOPUSENC_REF}) from ${LIBOPUSENC_REPOSITORY}..."
echo "===================================================="
git clone --depth 1 --branch "${LIBOPUSENC_REF}" "${LIBOPUSENC_REPOSITORY}" libopusenc
cd libopusenc
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared
make -j"$(nproc)"
make install
cd ..

# 5. Build libopusfile
echo "===================================================="
echo "Cloning libopusfile (${LIBOPUSFILE_REF}) from ${LIBOPUSFILE_REPOSITORY}..."
echo "===================================================="
git clone --depth 1 --branch "${LIBOPUSFILE_REF}" "${LIBOPUSFILE_REPOSITORY}" libopusfile
cd libopusfile
./autogen.sh
./configure --prefix="${DEPS_PREFIX}" --enable-static --disable-shared --disable-http
make -j"$(nproc)"
make install
cd ..

cd .. # leave build-temp
rm -rf build-temp

echo "All dependencies compiled and installed to ${DEPS_PREFIX} successfully!"
