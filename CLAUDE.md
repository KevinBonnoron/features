# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains DevContainer Features for use with VS Code Dev Containers and GitHub Codespaces. Each feature is a self-contained, shareable unit of installation code and dev container configuration that can be installed into development containers.

## Repository Structure

```
src/
  <feature-name>/
    devcontainer-feature.json  # Feature metadata and options
    install.sh                 # Installation script
    README.md                  # Auto-generated documentation
test/
  <feature-name>/
    test.sh                    # Test script executed inside container
    scenarios.json             # (Optional) Multiple test scenarios
```

Each feature lives in its own directory under `src/` with a corresponding test directory:

**Source files:**
- `devcontainer-feature.json`: Defines the feature metadata (id, version, name, description, documentation URL, and configurable options)
- `install.sh`: Bash script that installs the feature (runs during container build)
- `README.md`: Auto-generated from devcontainer-feature.json by the CI/CD workflow

**Test files:**
- `test.sh`: Validation script using `check` commands from `dev-container-features-test-lib`
- `scenarios.json`: Defines multiple test scenarios with different options and base images

## Development Workflow

### Adding a New Feature

1. Create a new directory under `src/` with the feature name
2. Create `devcontainer-feature.json` with required metadata:
   - `id`: Feature identifier (lowercase, hyphenated)
   - `version`: Semantic version (e.g., "0.0.1")
   - `name`: Display name
   - `documentationURL`: GitHub URL to the feature directory
   - `description`: Brief description of what the feature installs
   - `options`: Object defining configurable options (can be empty `{}`)
3. Create `install.sh` script that:
   - Uses `apt-get` for package installation
   - Accesses options via shell variables (e.g., `${optionName}`)
   - Includes `--no-install-recommends` flag for minimal installations
   - Runs `apt-get update` before installing packages

### Option Variables

Options defined in `devcontainer-feature.json` are available in `install.sh` as shell variables. For example, an option `libvpx` becomes available as `${libvpx}`.

### CI/CD

The repository uses GitHub Actions (`.github/workflows/release.yml`) to:

1. Automatically publish features to GitHub Container Registry on push to main
2. Generate README.md files from devcontainer-feature.json
3. Create pull requests with documentation updates

The workflow uses `devcontainers/action@v1` with:
- `publish-features: "true"`
- `base-path-to-features: "./src"`
- `generate-docs: "true"`

### Testing Features

Each feature should have a corresponding test directory with at minimum a `test.sh` file:

```bash
#!/bin/bash
set -e

source dev-container-features-test-lib

check "tool is installed" tool --version
check "tool command exists" which tool

reportResults
```

For complex features, add `scenarios.json` to test different configurations:

```json
{
  "scenario_name": {
    "image": "ubuntu:22.04",
    "features": {
      "feature-name": {
        "option1": true
      }
    },
    "remoteEnv": {
      "ENV_VAR": "value"
    }
  }
}
```

Tests run automatically in CI before publishing. To run tests locally:

```bash
devcontainer features test --features ffmpeg --base-image ubuntu:22.04
```

### Version Bumping

When making changes to a feature, increment the `version` field in `devcontainer-feature.json` following semantic versioning.

## Current Features

- **ffmpeg**: Compiles and installs ffmpeg from source with configurable codecs
- **git-absorb**: Installs git-absorb tool for automatic commit fixup
- **pocketbase**: Installs PocketBase backend from official GitHub releases
