FROM mcp/playwright:latest

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libnss3-tools \
    && rm -rf /var/lib/apt/lists/*

COPY certs/*.crt /usr/local/share/ca-certificates/

RUN update-ca-certificates --fresh

RUN mkdir -p /home/node/.pki/nssdb && \
    chown -R node:node /home/node/.pki && \
    su -s /bin/bash node -c "certutil -d sql:/home/node/.pki/nssdb -N --empty-password 2>/dev/null" && \
    for f in /usr/local/share/ca-certificates/*.crt; do \
        su -s /bin/bash node -c "certutil -d sql:/home/node/.pki/nssdb -A -t 'CT,C,C' -n '$(basename "$f" .crt)' -i '$f' 2>/dev/null" || true; \
    done

USER node
