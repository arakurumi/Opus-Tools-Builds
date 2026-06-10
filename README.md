# Opus-Tools GitHub Actions Builder

This repository builds [xiph/opus-tools](https://github.com/xiph/opus-tools) statically.

## What It Builds

- Linux x64 on `ubuntu-latest`
- Windows x64 on `windows-latest` through MSYS2 `MINGW64`
- Build arguments: `./configure --prefix="${workspace}/dist" --enable-static --disable-shared PKG_CONFIG="pkg-config --static" LDFLAGS="-static" CFLAGS="-DFLAC__NO_DLL"` (Linux) & `./configure --prefix="${workspace}/dist" --enable-static --disable-shared PKG_CONFIG="pkg-config --static" LDFLAGS="-static"` (Windows)

The workflow uploads GitHub Actions artifacts named:

- `opus-tools-linux64`
- `opus-tools-windows64`

Each artifact includes the compiled binaries (`opusenc`, `opusdec`, `opusinfo`) in `.tar.gz` format. The Windows artifact contains standalone Windows executables.

## Automatic Update Check

The workflow runs every day at `00:00 UTC`. It checks the current upstream default branch commit and skips the build if that exact commit was already built successfully.

Manual runs are available from the GitHub Actions tab. Set `force` to rebuild an upstream commit even if it was built before.
