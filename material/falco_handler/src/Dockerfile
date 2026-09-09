FROM python:3.11-slim

# Create a non-root user
RUN useradd -m -s /bin/bash appuser

WORKDIR /app

COPY handler.py .

# Install dependencies without curl
RUN apt-get update && \
    pip install --no-cache-dir flask kubernetes gunicorn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch to non-root user
USER appuser

# Run with Gunicorn instead of Flask's built-in server
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "1", "--access-logfile", "-", "--error-logfile", "-", "handler:app"]
