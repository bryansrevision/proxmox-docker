# Multi-stage build for minimal image size
FROM python:3.11-slim as builder

WORKDIR /tmp/build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt

# Production stage
FROM python:3.11-slim

LABEL maintainer="bryansrevision"
LABEL description="Proxmox Personal Data Platform - Portable Docker Container"
LABEL version="1.0.0"

# Set working directory
WORKDIR /app

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    openssh-client \
    nano \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Set environment variables
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    HOME=/home/pxmgr

# Create non-root user for security
RUN groupadd -r pxmgr && useradd -r -g pxmgr pxmgr

# Create directories
RUN mkdir -p /app /home/pxmgr/.config /home/pxmgr/.ssh && \
    chown -R pxmgr:pxmgr /app /home/pxmgr

# Copy application code
COPY --chown=pxmgr:pxmgr src/ /app/src/
COPY --chown=pxmgr:pxmgr setup.cfg pyproject.toml /app/

# Install the package
RUN cd /app && pip install -e . --no-cache-dir

# Copy entrypoint script with proper ownership and permissions
COPY --chown=pxmgr:pxmgr docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh && \
    chown pxmgr:pxmgr /app/docker-entrypoint.sh

# Create volumes for persistent data
VOLUME ["/app/config", "/home/pxmgr/.config", "/home/pxmgr/.ssh"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pxmgr --help > /dev/null || exit 1

# Switch to non-root user
USER pxmgr

# Expose ports (optional for web dashboard)
EXPOSE 8080

# Default entrypoint (use sh to exec)
ENTRYPOINT ["sh", "-c", "exec \"$@\"", "--"]
CMD ["pxmgr", "--help"]
