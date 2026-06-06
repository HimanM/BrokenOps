FROM python:3.12-slim

RUN apt-get update && apt-get install -y \
    qemu-utils \
    libvirt-dev \
    pkg-config \
    gcc \
    gosu \
    xorriso \
    genisoimage \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
# Since we didn't have a requirements.txt before, we'll just pip install directly
RUN pip install --no-cache-dir fastapi uvicorn pydantic pyyaml libvirt-python asyncssh websockets httpx

COPY . .

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
