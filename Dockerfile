# Development Dockerfile for Pawzitively (Phoenix/Elixir)
#
# This image is meant for local development with code reloading. The source
# tree is bind-mounted in via docker-compose, while deps and _build live in
# named volumes so they survive container restarts and aren't clobbered by the
# mount.
#
# Versions match .tool-versions (Elixir 1.19.5 / Erlang 28.3.1).

ARG ELIXIR_VERSION=1.19.5
ARG OTP_VERSION=28.3.1
ARG DEBIAN_VERSION=bookworm-20260610-slim

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}

# System deps:
# - build-essential: compiling NIFs / native code
# - git: some mix deps (e.g. heroicons) are fetched from GitHub
# - inotify-tools: required by Phoenix live reload to watch files
# - postgresql-client: handy for `psql` / debugging from inside the container
RUN apt-get update -y \
  && apt-get install -y build-essential git inotify-tools postgresql-client bash \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install the Hex package manager and Rebar build tool
RUN mix local.hex --force \
  && mix local.rebar --force

ENV MIX_ENV=dev \
    LANG=C.UTF-8

WORKDIR /app

# Pre-fetch dependencies as a cached layer. When mix.exs / mix.lock change this
# layer is rebuilt; otherwise it's reused across builds.
# COPY mix.exs mix.lock ./
# RUN mix deps.get
# RUN mix deps.compile

# The rest of the source is bind-mounted at runtime via docker-compose, so we
# don't COPY it here for the dev image.

# EXPOSE 4000

# Wait for nothing fancy here — docker-compose handles DB readiness ordering.
# Run migrations then boot the server with IEx attached for debugging.
# CMD ["sh", "-c", "mix ecto.create && mix ecto.migrate && mix phx.server"]
