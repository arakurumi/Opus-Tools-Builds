# Opus-Tools Builds

Automated compilation and packaging of [xiph/opus-tools](https://github.com/xiph/opus-tools) for Windows 64-bit and Linux 64-bit using GitHub Actions.

This repository is designed as a standalone builder. When triggered, the workflow automatically fetches the latest source code of `opus-tools`, resolves its dependencies, compiles the binaries, and posts them to your GitHub Releases page in `.tar.gz` format.

## Features

- **Built from Source**: Always compiles the official `xiph/opus-tools` directly.
- **Standalone Windows Binaries**: Compiled statically using MSYS2 / MinGW-w64 (`LDFLAGS="-static"`), meaning `opusenc.exe`, `opusdec.exe`, and `opusinfo.exe` are completely self-contained and require no external DLL files.
- **Standard Linux Binaries**: Compiled and linked dynamically for maximum compatibility.
- **Automated Releases**: Generates releases containing both Windows and Linux builds.
- **Dynamic Versioning**: Extracts the exact version tag/commit automatically from the `opus-tools` source using git/autotools versioning scripts.

---

## How It Works

The workflow consists of three jobs:
1. **`build-linux`**: Uses `ubuntu-latest` runner to compile the tools and package them into `opus-tools-linux64.tar.gz`.
2. **`build-windows`**: Uses `windows-latest` with MSYS2/MinGW toolchain to compile static Windows binaries and package them into `opus-tools-windows64.tar.gz`.
3. **`release`**: Triggered only on tag push or manual trigger to automatically publish the packages to GitHub Releases.

---

## How to Setup

1. **Create Repository**: Create a new GitHub repository (e.g., `opus-tools-builds`).
2. **Push Workflow**: Commit this project's structure along with the GitHub Action configuration:
   ```bash
   .github/workflows/build.yml
   README.md
   ```
3. **Configure Permissions**: Ensure your repository has permission to write releases. Go to **Settings** -> **Actions** -> **General** -> **Workflow permissions** and select **Read and write permissions**.

---

## How to Trigger a Build & Release

### Method 1: Git Tag (Automatic)
Create and push a tag to this repository. The action will automatically detect it, checkout the matching tag/ref from `xiph/opus-tools` (if available, otherwise fallback to `master`), compile the binaries, and publish a release matching that tag name.
```bash
# Example: Triggering a build for version 0.2
git tag v0.2
git push origin v0.2
```

### Method 2: Manual Trigger (GitHub Actions UI)
1. Navigate to the **Actions** tab of your repository on GitHub.
2. Select **Build Opus-Tools** in the sidebar.
3. Click the **Run workflow** dropdown on the right side.
4. Fill in the options:
   - **Tag name for the release**: Enter the name of the release tag (e.g., `v0.2`). If left empty, it will automatically use the compiled version number extracted from the source repository.
   - **Branch, tag, or commit of xiph/opus-tools to build**: Enter the branch/tag/commit from the official repository that you wish to compile (e.g., `master` or `v0.2`).
5. Click **Run workflow**.

---

## Outputs

Each release will contain:
- `opus-tools-linux64.tar.gz` (contains `opusenc`, `opusdec`, `opusinfo`)
- `opus-tools-windows64.tar.gz` (contains `opusenc.exe`, `opusdec.exe`, `opusinfo.exe`)
