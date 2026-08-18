# syntax=docker/dockerfile:1

ARG VERSION

FROM rust:slim AS builder
ARG VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN cargo install schematools-cli@${VERSION}

FROM rust:slim
COPY --from=builder /usr/local/cargo/bin/schematools-cli /usr/local/bin/schematools-cli
ENTRYPOINT ["schematools-cli"]
CMD ["--help"]
