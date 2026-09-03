# Testing Guide

This document explains the testing strategy for ForgeAppTemplate and Buildly Marketplace submissions.

## Overview

ForgeAppTemplate uses **Robot Framework Browser** (Playwright-backed) for E2E testing. This provides reliable, cross-browser testing without requiring npm or Node.js.

Two testing modes are available:

| Mode | Recommended For | Pros | Cons |
|------|-----------------|------|------|
| **Docker-first** | CI, reproducibility | Zero local deps, matches CI exactly | Slower startup, requires Docker |
| **Python-first** | Fast local dev | Fastest iteration, direct debugging | Requires local Python + system deps |

## Docker-first Mode (Recommended)

### When to Use
- **CI/CD pipelines** (always)
- **First-time setup** (no local deps needed)
- **Reproducing CI failures**
- **Generating final screenshots**

### Prerequisites
- Docker Desktop or Docker Engine with Compose

### Running Tests

```bash
# Run E2E smoke tests
./scripts/test-e2e-docker.sh

# Generate marketplace screenshots
./scripts/screenshots-docker.sh
```

### How It Works
1. Builds the app container (`ops/Dockerfile.app`)
2. Builds the e2e container (`ops/Dockerfile.e2e`) with Robot Framework + Playwright
3. Starts app container, waits for health check
4. Runs Robot tests in e2e container against app container
5. Outputs reports to `artifacts/robot/`
6. Screenshots go to `marketplace/screenshots/`

### Advantages
- **Reproducible**: Same environment locally and in CI
- **No local deps**: Only Docker required
- **Isolated**: Doesn't pollute your system

### Disadvantages
- **Slower**: Container build time on first run
- **Resource heavy**: Runs full containers
- **Debugging**: Harder to inspect test failures interactively

---

## Python-first Mode (Optional)

### When to Use
- **Fast iteration** during development
- **Debugging tests** with local tools
- **Quick smoke tests** while coding

### Prerequisites
- Python 3.10+
- System dependencies for Playwright (usually auto-installed)

### Setup

```bash
# Start the app server
./ops/startup.sh start python

# Run tests (creates venv, installs deps automatically)
./scripts/test-e2e-python.sh

# Generate screenshots
./scripts/screenshots-python.sh

# Stop when done
./ops/startup.sh stop python
```

### How It Works
1. Creates `.venv/` if needed
2. Installs Robot Framework + Browser library
3. Runs `rfbrowser init` to install Playwright browsers
4. Runs tests against local server

### Advantages
- **Fastest**: No container overhead
- **Direct debugging**: Use local tools, add breakpoints
- **Quick feedback**: Instant test reruns

### Disadvantages
- **May drift**: Local env might differ from CI
- **System deps**: May need manual Playwright deps on some systems
- **Not reproducible**: Works on your machine ≠ works everywhere

---

## Test Files

```
tests/robot/
├── requirements.txt    # Python dependencies (pinned versions)
├── smoke.robot         # Core functionality tests
└── screenshots.robot   # Screenshot generation for marketplace
```

### smoke.robot
Verifies basic app functionality:
- App root loads correctly
- Primary action button is clickable
- Panel appears after interaction
- Page has a title

### screenshots.robot
Generates canonical marketplace screenshots:
- `01-home.png` - Initial app state
- `02-primary-action.png` - After clicking primary action

---

## Output Locations

| Output | Location | Git |
|--------|----------|-----|
| Robot reports | `artifacts/robot/` | Ignored |
| Screenshots | `marketplace/screenshots/` | Tracked |
| Virtual env | `.venv/` | Ignored |

---

## CI Integration

GitHub Actions runs Docker-first tests on every push/PR:

```yaml
# .github/workflows/ci.yml
- run: ./scripts/test-e2e-docker.sh
- run: ./scripts/screenshots-docker.sh
```

Results are uploaded as artifacts for inspection.

---

## Troubleshooting

### "App is not running"
Start the app first:
```bash
./ops/startup.sh start python
# or
./ops/startup.sh start docker
```

### "rfbrowser init failed"
On some systems, Playwright needs additional deps:
```bash
# Debian/Ubuntu
sudo apt-get install libnss3 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libgbm1
```

### "Port already in use"
Check what's using the port:
```bash
lsof -i :8000
```

Use a different port:
```bash
./ops/startup.sh start python --port 8080
```

### Docker tests fail but Python tests pass
This usually means a path or environment issue. Check:
- Volume mounts in `docker-compose.yml`
- `BASE_URL` environment variable

---

## Best Practices

1. **Use Docker-first for CI** - Always match the CI environment
2. **Use Python-first for dev** - Fast feedback during development
3. **Run Docker tests before pushing** - Catch CI failures early
4. **Keep tests focused** - Test UI behavior, not implementation
5. **Use data-testid** - Stable selectors that don't break with styling changes
