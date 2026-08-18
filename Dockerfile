# syntax=docker/dockerfile:1

FROM rust:slim

ARG TARGETARCH
COPY schematools-cli-${TARGETARCH} /usr/local/bin/schematools-cli
RUN chmod +x /usr/local/bin/schematools-cli

ENTRYPOINT ["schematools-cli"]
CMD ["--help"]
