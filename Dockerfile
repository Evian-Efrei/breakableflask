FROM python:3.11-slim AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc python3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .

# hadolint ignore=DL3013
RUN pip install --no-cache-dir --upgrade pip==23.3.1 && \
    pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim

# hadolint ignore=DL3008,DL3005
RUN apt-get update && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY --chown=appuser:appuser . .

USER appuser

CMD ["python", "app.py"]
