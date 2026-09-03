#!/usr/bin/env bash
#
# scripts/screenshots-python.sh
# Generate canonical marketplace screenshots using local Python
#
# Prerequisites:
# 1. App must be running: ./ops/startup.sh start python
# 2. Python 3.x must be installed
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VENV_DIR="$REPO_ROOT/.venv"
PORT_FILE="$REPO_ROOT/.forge-port"
REQUIREMENTS="$REPO_ROOT/tests/robot/requirements.txt"
SCREENSHOT_DIR="$REPO_ROOT/marketplace/screenshots"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[screenshots]${NC} $1"; }
log_success() { echo -e "${GREEN}[screenshots]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[screenshots]${NC} $1"; }
log_error() { echo -e "${RED}[screenshots]${NC} $1" >&2; }

# Determine port
if [[ -f "$PORT_FILE" ]]; then
    PORT=$(cat "$PORT_FILE")
else
    PORT=8000
fi

BASE_URL="http://localhost:$PORT"

# Check if app is running
log_info "Checking if app is running at $BASE_URL..."
if ! curl -s "$BASE_URL" &>/dev/null; then
    log_error "App is not running at $BASE_URL"
    log_info "Start it with: ./ops/startup.sh start python"
    exit 1
fi
log_success "App is running"

# Set up virtual environment
if [[ ! -d "$VENV_DIR" ]]; then
    log_info "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

# Activate venv
source "$VENV_DIR/bin/activate"

# Install dependencies
log_info "Installing Robot Framework dependencies..."
pip install -q -r "$REQUIREMENTS"

# Initialize Browser library
log_info "Initializing Playwright browsers..."
rfbrowser init 2>/dev/null || {
    log_warn "Browser init had warnings (may be already initialized)"
}

# Ensure output directories
mkdir -p "$SCREENSHOT_DIR"
mkdir -p "$REPO_ROOT/artifacts/robot"

# Run screenshot tests
log_info "Running screenshot generation against $BASE_URL..."
cd "$REPO_ROOT"

robot \
    --outputdir artifacts/robot \
    --log screenshots-log.html \
    --report screenshots-report.html \
    --output screenshots-output.xml \
    --variable BASE_URL:$BASE_URL \
    --variable SCREENSHOT_DIR:$SCREENSHOT_DIR \
    tests/robot/screenshots.robot

EXIT_CODE=$?

if [[ $EXIT_CODE -eq 0 ]]; then
    log_success "Screenshots generated successfully!"
    log_info "Screenshots available in: marketplace/screenshots/"
    ls -la "$SCREENSHOT_DIR"
else
    log_error "Screenshot generation failed (exit code: $EXIT_CODE)"
fi

exit $EXIT_CODE
