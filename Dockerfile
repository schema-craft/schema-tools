# syntax=docker/dockerfile:1

FROM rust:slim

RUN apt-get update \
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
