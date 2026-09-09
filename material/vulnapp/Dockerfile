FROM python:3.11-slim

# Install ping utility so the legitimate functionality works.
# iputils-ping uses IPPROTO_ICMP sockets on modern kernels, so
# it works without CAP_NET_RAW or privileged mode.
RUN apt-get update && \
    apt-get install -y --no-install-recommends iputils-ping && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8080

# -u: unbuffered output so logs appear immediately in kubectl logs
CMD ["python", "-u", "app.py"]
