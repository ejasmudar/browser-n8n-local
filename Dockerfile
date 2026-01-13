FROM python:3.11-slim

WORKDIR /app

# 1. Install ALL system dependencies first (including curl for the healthcheck)
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    ca-certificates \
    procps \
    unzip \
    curl \
    # Critical browser libraries
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Install Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. FIX: Install Playwright and dependencies in separate steps
# This helps debug where it fails and is more stable in Portainer
RUN python -m playwright install-deps chromium
RUN python -m playwright install chromium

# 4. Final Setup
COPY . .
RUN mkdir -p /app/data && chmod 777 /app/data
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

# Updated Healthcheck (Checking root if /api/v1/ping is missing)
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:8000/ || exit 1

CMD ["python", "app.py"]
