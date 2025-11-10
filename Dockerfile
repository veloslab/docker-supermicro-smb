FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="supermicro-smb" \
      org.opencontainers.image.description="Legacy SMB server for Supermicro virtual media" \
      org.opencontainers.image.source="https://github.com/veloslab/docker-supermicro-smb" \
      org.opencontainers.image.licenses="MIT"

ENV SAMBA_CONFIG=/etc/samba/smb.conf \
    SAMBA_SHARE=/srv/isos \
    DEBIAN_FRONTEND=noninteractive

# Install Samba without recommended packages, then keep the layer clean.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends samba; \
    rm -rf /var/lib/apt/lists/*

WORKDIR ${SAMBA_SHARE}
VOLUME ["${SAMBA_SHARE}"]

# Copy the SMB configuration tailored for legacy Supermicro BMCs.
COPY smb.conf ${SAMBA_CONFIG}

EXPOSE 137/udp 138/udp 139 445

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD smbcontrol smbd ping || exit 1

# Run smbd in the foreground and log to stdout/stderr.
CMD ["/usr/sbin/smbd", "--foreground", "--no-process-group", "--log-stdout", "--configfile=/etc/samba/smb.conf"]
