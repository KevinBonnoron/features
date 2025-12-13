# DevContainer Features

This repository contains [DevContainer Features](https://containers.dev/implementors/features/) for use with VS Code Dev Containers and GitHub Codespaces.

## Available Features

### ffmpeg

Compiles and installs ffmpeg from source with support for popular codecs (H.264, H.265, MP3, Opus) and optional libvpx support (VP8/VP9).

```json
"features": {
    "ghcr.io/KevinBonnoron/features/ffmpeg:0": {
        "version": "latest",
        "libvpx": false
    }
}
```

Options:
- `version`: FFmpeg version to install (e.g., "7.1", "6.1.1", or "latest"). Default: "latest"
- `libvpx`: Enable VP8/VP9 codec support. Default: false

### git-absorb

Installs [git-absorb](https://github.com/tummychow/git-absorb), a tool for automatic commit fixups.

```json
"features": {
    "ghcr.io/KevinBonnoron/features/git-absorb:0": {}
}
```

### pocketbase

Installs [PocketBase](https://pocketbase.io/), an open-source backend in 1 file.

```json
"features": {
    "ghcr.io/KevinBonnoron/features/pocketbase:0": {
        "version": "0.29.3"
    }
}
```

Options:
- `version`: PocketBase version to install (e.g., "0.29.3", "0.28.0"). Default: "0.29.3"

## Usage

To use these features, add them to your `.devcontainer/devcontainer.json` file:

```json
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/KevinBonnoron/features/ffmpeg:0": {},
        "ghcr.io/KevinBonnoron/features/git-absorb:0": {}
    }
}
```

## Contributing

Each feature is located in the `src/` directory with the following structure:

- `devcontainer-feature.json` - Feature metadata and configurable options
- `install.sh` - Installation script
- `README.md` - Auto-generated documentation

To add a new feature, create a new directory under `src/` with these files. The CI/CD workflow will automatically publish the feature and generate documentation when pushed to the main branch.
