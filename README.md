# ForgeAppTemplate

A minimal starter template for Buildly Marketplace submissions with Robot Framework Browser tests.

[![CI](https://github.com/Buildly-Marketplace/ForgeAppTemplate/actions/workflows/ci.yml/badge.svg)](https://github.com/Buildly-Marketplace/ForgeAppTemplate/actions/workflows/ci.yml)

## Features

- **Robot Framework Browser** (Playwright-backed) for E2E testing
- **No npm required** - uses `robotframework-browser-batteries`
- **Two test modes**: Docker-first (CI) and Python-first (local dev)
- **Single control script** for start/stop/restart/status
- **Automatic screenshot generation** for Marketplace listings
- **GitHub Actions CI** with artifact uploads

## Quick Start

### Using Docker (Recommended)

```bash
# Start the app
./ops/startup.sh start docker

# Check status
./ops/startup.sh status docker

# Run E2E tests
./scripts/test-e2e-docker.sh

# Generate screenshots
./scripts/screenshots-docker.sh

# Stop
./ops/startup.sh stop docker
```

### Using Python (Local Development)

```bash
# Start the app (auto-selects available port 8000-9000)
./ops/startup.sh start python

# Check status
./ops/startup.sh status python

# Run E2E tests
./scripts/test-e2e-python.sh

# Generate screenshots
./scripts/screenshots-python.sh

# Stop
./ops/startup.sh stop python
```

### Specifying a Port

```bash
./ops/startup.sh start python --port 8080
./ops/startup.sh start docker --port 8080
```

## AI-Native Workflow with Buster (optional)

This template works with [Buster](https://github.com/buildlyio/buster), Buildly's
local-first developer assistant, but does **not** require it — nor any Labs
connectivity.

```bash
# Start a new Forge app from this structure
buster forge new "My App"

# …or bring an EXISTING app to the marketplace (additive; never edits your code)
buster adopt            # non-destructive scan → devdocs/generated/
buster forge adapt      # adds BUILDLY.yaml + devdocs templates where missing
```

Generated, human-readable docs live under `devdocs/generated/` (tracked); volatile
workflow state under `.buildly/` is git-ignored. Inferred conclusions are proposals
until a human approves them, and pull requests are never auto-merged.

## Project Structure

```
ForgeAppTemplate/
├── BUILDLY.yaml              # Marketplace manifest
├── README.md
├── .github/workflows/ci.yml  # GitHub Actions CI
│
├── ops/                      # Operations
│   ├── startup.sh            # Single control script
│   ├── docker-compose.yml
│   ├── Dockerfile.app
│   └── Dockerfile.e2e
│
├── scripts/                  # Test scripts
│   ├── test-e2e-docker.sh
│   ├── test-e2e-python.sh
│   ├── screenshots-docker.sh
│   └── screenshots-python.sh
│
├── src/                      # Application source
│   ├── server.py
│   └── index.html
│
├── tests/robot/              # Robot Framework tests
│   ├── requirements.txt
│   ├── smoke.robot
│   └── screenshots.robot
│
├── marketplace/screenshots/  # Generated screenshots
│   ├── 01-home.png
│   └── 02-primary-action.png
│
├── artifacts/                # Test outputs (gitignored)
│   └── robot/
│
└── devdocs/                  # Developer documentation
    ├── 04_testing.md
    └── 05_marketplace_manifest.md
```

## Test Modes

| Mode | Best For | Pros | Cons |
|------|----------|------|------|
| **Docker-first** | CI, reproducibility | Zero local deps, matches CI | Slower startup |
| **Python-first** | Local development | Fast iteration | May drift from CI |

See [devdocs/04_testing.md](devdocs/04_testing.md) for detailed comparison.

## Output Locations

| Output | Location | Git Status |
|--------|----------|------------|
| Robot reports | `artifacts/robot/` | Ignored |
| Screenshots | `marketplace/screenshots/` | **Tracked** |
| Python venv | `.venv/` | Ignored |
| Port state | `.forge-port` | Ignored |
| Python server log | `.forge-python.log` | Ignored |

## Marketplace Acceptance Contract

Submissions must satisfy requirements defined in `BUILDLY.yaml`:

1. **Tests pass**: `./scripts/test-e2e-docker.sh` exits 0
2. **Screenshots generated**: Required files exist in `marketplace/screenshots/`
3. **Manifest valid**: `BUILDLY.yaml` contains required fields
4. **No npm**: No `package.json` or `node_modules`

See [devdocs/05_marketplace_manifest.md](devdocs/05_marketplace_manifest.md) for full specification.

## UI Test Hooks

The app uses `data-testid` attributes for stable test selectors:

| Hook | Element | Purpose |
|------|---------|---------|
| `app-root` | Main container | Verify app loads |
| `primary-action` | CTA button | Test interaction |
| `panel` | Content panel | Verify state change |

## Scripts Reference

### ops/startup.sh

```bash
./ops/startup.sh <command> <mode> [--port PORT]

Commands: start, stop, restart, status, help
Modes: python, docker
```

### Test Scripts

```bash
./scripts/test-e2e-docker.sh      # Docker E2E tests
./scripts/test-e2e-python.sh      # Python E2E tests (app must be running)
./scripts/screenshots-docker.sh   # Docker screenshot generation
./scripts/screenshots-python.sh   # Python screenshot generation (app must be running)
```

## Making Scripts Executable

After cloning:

```bash
chmod +x ops/startup.sh scripts/*.sh
```

## Requirements

### Docker Mode
- Docker Desktop or Docker Engine with Compose

### Python Mode
- Python 3.10+
- System dependencies for Playwright (usually auto-installed)

## License

MIT - See [LICENSE](LICENSE) for details.
