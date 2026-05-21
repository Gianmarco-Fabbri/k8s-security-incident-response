FROM debian:bullseye-slim

WORKDIR /app

COPY handler.py .

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 python3-pip \
        curl && \
    pip3 install flask && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    && curl -SLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -S https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

CMD ["python3", "-u", "handler.py"]
