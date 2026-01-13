FROM python:3.11-slim

WORKDIR /app

# 1. Install system dependencies (Root)
RUN apt-get update && apt-get install -y \
    wget gnupg ca-certificates procps unzip curl \
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
    libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 \
    libxrandr2 libgbm1 libasound2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Install Python requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Install Playwright (STILL AS ROOT)
# This ensures it can install any missing system-level libraries
RUN python -m playwright install --with-deps chromium

# 4. Copy app and set permissions
COPY . .
RUN mkdir -p /app/data && chmod 777 /app/data
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser:appuser /app

# 5. Switch to non-root for security
USER appuser

EXPOSE 8000

# Healthcheck uses 'curl' which we added to the apt-get list above
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:8000/api/v1/ping || exit 1

CMD ["python", "app.py"]
