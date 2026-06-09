# Opus-Tools Builds

Automated compilation and packaging of [xiph/opus-tools](https://github.com/xiph/opus-tools) for Windows 64-bit and Linux 64-bit using GitHub Actions.

This repository is designed as a standalone builder. By default, the workflow automatically runs on a daily schedule (00:00 UTC), checks if the upstream repository has new updates, compiles the binaries from source if changes are detected, and posts them to your GitHub Releases page in `.tar.gz` format.

## Features

- **Built from Source**: Always compiles the official `xiph/opus-tools` directly.
- **Upstream Checking**: Checks the upstream repository for new commits daily. If no changes are detected, the build is skipped to save Actions runner minutes.
- **Build Caching**: Saves build status marker files to the GitHub Actions cache when a commit is successfully built to prevent redundant compiles.
- **Force Build Input**: Allows you to force a rebuild of the same commit using a manual trigger option.
- **Standalone Windows Binaries**: Compiled statically using MSYS2 / MinGW-w64 (`LDFLAGS="-static"`), meaning `opusenc.exe`, `opusdec.exe`, and `opusinfo.exe` are completely self-contained and require no external DLL files.
- **Standard Linux Binaries**: Compiled and linked dynamically for maximum compatibility.
- **Automated Releases**: Generates releases containing both Windows and Linux builds.
- **Dynamic Versioning**: Extracts the exact version tag/commit automatically from the `opus-tools` source using git/autotools versioning scripts.

---

## How It Works

The workflow consists of four jobs:
1. **`check_upstream`**: Runs first to resolve the latest commit SHA of `xiph/opus-tools` and check if we have already built it (via `actions/cache/restore`). It determines whether to continue the build (`should_build: true/false`).
2. **`build-linux`**: (Triggered only if `should_build` is `true`) Compiles the tools on `ubuntu-latest` and packages them into `opus-tools-linux64.tar.gz`.
3. **`build-windows`**: (Triggered only if `should_build` is `true`) Compiles static Windows binaries on `windows-latest` with MSYS2/MinGW and packages them into `opus-tools-windows64.tar.gz`.
4. **`release`**: (Triggered only if `should_build` is `true`) Publishes the packages to GitHub Releases and saves the build marker into the Actions cache to avoid rebuilds.

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
Create and push a tag to this repository. The action will automatically detect it, checkout the matching tag/ref from `xiph/opus-tools` (if available, otherwise fallback to the latest master commit), compile the binaries, and publish a release matching that tag name.
```bash
# Example: Triggering a build for version 0.2
git tag v0.2
git push origin v0.2
```

### Method 2: Scheduled Run (Automatic Daily)
The workflow runs automatically every day at `00:00 UTC`. It checks if there is a new commit on the `master` branch of `xiph/opus-tools`. If a new commit is found, it automatically builds and creates a release.

### Method 3: Manual Trigger (GitHub Actions UI)
1. Navigate to the **Actions** tab of your repository on GitHub.
2. Select **Build Opus-Tools** in the sidebar.
3. Click the **Run workflow** dropdown on the right side.
4. Fill in the options:
   - **Build even if this upstream commit was already built successfully (force)**: Check this option (set to `true`) if you want to rebuild even when there are no new commits.
   - **Tag name for the release**: Enter the name of the release tag (e.g., `v0.2`). If left empty, it will automatically use the compiled version number extracted from the source repository.
   - **Branch, tag, or commit of xiph/opus-tools to build**: Enter the branch/tag/commit from the official repository that you wish to compile (e.g., `master` or `v0.2`).
5. Click **Run workflow**.

---

## Outputs

Each release will contain:
- `opus-tools-linux64.tar.gz` (contains `opusdec`, `opusenc`, `opusinfo`)
- `opus-tools-windows64.tar.gz` (contains `opusdec.exe`, `opusenc.exe`, `opusinfo.exe`)
