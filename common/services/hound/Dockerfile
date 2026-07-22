# Hound MCP server (https://pypi.org/project/hound-mcp/) with the [all]
# extras: web fetch / crawl / search, Patchright anti-detect browser,
# PDF parsing (pdfplumber + pypdfium2), and OCR (rapidocr + onnxruntime).
#
# Build context: this directory only. `pip install` pulls the package from
# PyPI so the Dockerfile stays decoupled from the repo's pinning.
#
# Build:    ./build.sh
# Run MCP:  docker run --rm -i --init hound-mcp
FROM python:3.13-slim

# Headless Chromium runtime deps (Patchright uses Playwright's bundled
# chromium, which is a real Chromium and needs the usual libs). Kept minimal
# but covers Debian 12's Playwright-tested set.
# rapidocr/onnxruntime also want libgl1 + libglib for OpenCV.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        fonts-liberation \
        libasound2 \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libcups2 \
        libdbus-1-3 \
        libdrm2 \
        libgbm1 \
        libgl1 \
        libglib2.0-0 \
        libnspr4 \
        libnss3 \
        libxcomposite1 \
        libxdamage1 \
        libxfixes3 \
        libxkbcommon0 \
        libxrandr2 \
        libxshmfence1 \
    && rm -rf /var/lib/apt/lists/*

# Install hound-mcp with the [all] extras (pulls in onnxruntime, pdfplumber,
# pypdfium2, rapidocr, requests, tokenizers, and Playwright). The MCP server
# is exposed as the `hound` console-script entry point.
RUN pip install --no-cache-dir --disable-pip-version-check "hound-mcp[all]"

# Pre-fetch Patchright's Chromium so the first MCP request doesn't trigger a
# ~170 MB download on the user's machine. Stored under /ms-playwright (the
# path Playwright expects; respects PLAYWRIGHT_BROWSERS_PATH if ever set).
RUN python -m playwright install chromium

# Run as an unprivileged user — Playwright's chromium refuses to run as root.
RUN useradd --create-home --shell /bin/bash hound
USER hound
WORKDIR /home/hound

ENTRYPOINT ["hound"]
