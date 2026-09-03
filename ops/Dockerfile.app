# ForgeAppTemplate Application Container
# Minimal Python HTTP server for development and testing
FROM python:3.12-slim

LABEL maintainer="Buildly Marketplace <marketplace@buildly.io>"
LABEL description="ForgeAppTemplate application server"

WORKDIR /app

# Copy application source
COPY src/ ./src/

# Expose default port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/')" || exit 1

# Run the server
CMD ["python3", "src/server.py", "--port", "8000"]
