# This image includes Python, Playwright, and all browser dependencies pre-installed
FROM mcr.microsoft.com/playwright/python:v1.40.0-jammy

WORKDIR /app

# 1. Install your app-specific Python requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2. Copy your application files
COPY . .

# 3. Setup permissions and data folder
RUN mkdir -p /app/data && chmod 777 /app/data
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser:appuser /app

# 4. Switch to the non-root user
USER appuser

# 5. Expose the API port
EXPOSE 8000

# Start the application
CMD ["python", "app.py"]
