# Use a solid Python 3.11 base
FROM python:3.11-bullseye

WORKDIR /app

# 1. Install system dependencies for Playwright
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget gnupg ca-certificates procps unzip curl \
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
    libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 \
    libxrandr2 libgbm1 libasound2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Upgrade pip and install requirements
# Upgrading pip often fixes the "No matching distribution found" error
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# 3. Install Playwright browsers (as root to ensure they land in the right path)
RUN python -m playwright install --with-deps chromium

# 4. Final Setup
COPY . .
RUN mkdir -p /app/data && chmod 777 /app/data
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser:appuser /app

# Switch to user for security
USER appuser

EXPOSE 8000

CMD ["python", "app.py"]
