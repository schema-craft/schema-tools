# syntax=docker/dockerfile:1

FROM rust:slim

RUN sed -i 's/deb.debian.org\/debian\-security/debian.code.g2a.com\/security/g' /etc/apt/sources.list.d/debian.sources \
    && sed -i 's/deb.debian.org\/debian/debian.code.g2a.com\//g' /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        make \
    && rm -rf /var/lib/apt/lists/* \
    && rustup component add rustfmt

ARG TARGETARCH
COPY --chmod=0755 schematools-cli-${TARGETARCH} /usr/local/bin/schematools-cli

ENTRYPOINT ["/usr/local/bin/schematools-cli"]
CMD ["--help"]
