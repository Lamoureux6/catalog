# syntax=docker/dockerfile:1.2
FROM python:3.10.7-slim-bullseye

WORKDIR /work

# Copy application files
COPY requirements.txt .
COPY main.py .

# Optional
ENV FLASK_APP=main.py

# Upgrade base image libraries to prevent security vulnerabilities
RUN apt-get --quiet update && \
    apt-get --quiet --assume-yes upgrade && \
    apt-get clean && \
    rm --recursive --force /var/lib/apt/lists/* && \
    python -m venv .venv && \
    .venv/bin/pip install --no-cache-dir --requirement requirements.txt

# Create default user
RUN groupadd --system docker && useradd --system --shell /bin/false --gid docker docker
RUN chown --recursive docker:docker /work
USER docker

ENTRYPOINT ["/work/.venv/bin/flask", "run", "--host", "0.0.0.0"]
