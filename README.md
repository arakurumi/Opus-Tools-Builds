# Opus-Tools GitHub Actions Builder

This repository builds [xiph/opus-tools](https://github.com/xiph/opus-tools) statically.

## What It Builds

- Linux x64 on `ubuntu-latest`
- Windows x64 on `windows-latest` through MSYS2 `MINGW64`
- Build arguments: `./configure PKG_CONFIG="pkg-config --static" LDFLAGS="-static"` (Linux) & `./configure --enable-static --disable-shared LDFLAGS="-static"` (Windows)

The workflow uploads GitHub Actions artifacts named:

- `opus-tools-linux64`
- `opus-tools-windows64`

Each artifact includes the compiled binaries (`opusenc`, `opusdec`, `opusinfo`) in `.tar.gz` format. The Windows artifact contains standalone Windows executables.
