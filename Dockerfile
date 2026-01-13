# Use 3.11 to satisfy browser-use >= 3.11 requirement
FROM python:3.11-slim-bullseye

WORKDIR /app

# 1. Install system-level browser dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget gnupg ca-certificates procps unzip curl \
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
    libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 \
    libxrandr2 libgbm1 libasound2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Update pip and install requirements
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 3. Install Playwright and its internal dependencies
# We run this as root to ensure the browsers are accessible globally
RUN python -m playwright install --with-deps chromium

# 4. Final Application Setup
COPY . .
RUN mkdir -p /app/data && chmod 777 /app/data
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser:appuser /app

# Secure the container by switching to non-root
USER appuser

EXPOSE 8000

CMD ["python", "app.py"]
