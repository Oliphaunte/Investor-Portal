ARG ELIXIR_VERSION=1.18.3
ARG OTP_VERSION=27.3.4
ARG DEBIAN_VERSION=bookworm-20250428-slim

ARG BUILDER_IMAGE="docker.io/hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="docker.io/debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  build-essential \
  git \
  curl \
  wget \
  ca-certificates \
  inotify-tools \
  postgresql-client \
  && rm -rf /var/lib/apt/lists/*

ENV LANG=C.UTF-8
WORKDIR /workspace

ENV NODE_VERSION=24.0.2
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version

# Pre-install Hex/Rebar for faster setup in container
RUN mix local.hex --force && mix local.rebar --force

# Default command for Dev Containers (VS Code will override as needed)
CMD ["sleep", "infinity"]
