#!/usr/bin/env bash
# Script to package and validate the built artifacts
set -euo pipefail

# Detect binary name and OS
if [[ "$(uname -s)" == *"NT"* || "$(uname -s)" == *"MINGW"* || "$(uname -s)" == *"MSYS"* ]]; then
  EXE_SUFFIX=".exe"
  IS_WINDOWS=true
else
  EXE_SUFFIX=""
  IS_WINDOWS=false
fi

echo "Creating package directory..."
mkdir -p package

# Copy built binaries
cp dist/bin/opusenc${EXE_SUFFIX} package/
cp dist/bin/opusdec${EXE_SUFFIX} package/
cp dist/bin/opusinfo${EXE_SUFFIX} package/

# Copy license and source information
if [[ -f source/COPYING ]]; then
  cp source/COPYING package/LICENSE.txt
fi

# Write metadata
git -C source rev-parse HEAD > package/upstream-sha.txt
git -C source describe --tags --always > package/version.txt

echo "Validating built binaries..."
for bin in opusenc opusdec opusinfo; do
  BIN_PATH="package/${bin}${EXE_SUFFIX}"
  if [[ ! -f "${BIN_PATH}" ]]; then
    echo "::error::Binary not found at ${BIN_PATH}"
    exit 1
  fi
  
  echo "Checking: ${BIN_PATH}"
  file "${BIN_PATH}" || true
  
  # ldd check
  echo "ldd output:"
  { ldd "${BIN_PATH}" || true; } | tee ldd_output.txt
  
  # Validate that there are no dynamic links to the dependencies we built
  if [ "$IS_WINDOWS" = true ]; then
    if grep -Ei '(opus|ogg|flac).*\.(dll|so)' ldd_output.txt; then
      echo "::error::Dependencies are still dynamically linked!"
      exit 1
    fi
    if grep -Ei '/(clang64|mingw64|ucrt64)/bin/.*[.]dll' ldd_output.txt; then
      echo "::error::Windows binary is still linked to MSYS2 DLLs. Build must be standalone before release."
      exit 1
    fi
  else
    # On Linux, verify it is a fully static binary
    if ! grep -qi 'not a dynamic executable' ldd_output.txt && grep -q '\.so' ldd_output.txt; then
      echo "::error::Linux binary is not statically linked!"
      exit 1
    fi
  fi
  rm -f ldd_output.txt
done

echo "Packaging and validation completed successfully!"
