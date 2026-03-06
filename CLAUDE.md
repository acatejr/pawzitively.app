# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pawzitively is a pet daycare tracking application built with Elixir/Phoenix.

## Tech Stack Decision

Chose Elixir/Phoenix over Python/Django because:
- Real-time functionality is important → Phoenix LiveView is purpose-built for this
- Learning Elixir is a goal
- Phoenix Channels/LiveView handle live updates without writing JavaScript

## MVP Scope

Focus on the core workflow:

1. **Pet & Owner Management** - CRUD for pets and their owners
2. **Check-in/Check-out** - the core daily operation
3. **Live Dashboard** - see who's currently checked in (LiveView)
4. **Basic Reporting** - daily attendance history

Deferred: payments, scheduling/reservations, notifications, mobile app

## Development Commands

```bash
# Start PostgreSQL
docker compose up -d

# Install dependencies
mix deps.get

# Create database
mix ecto.create

# Run migrations
mix ecto.migrate

# Start Phoenix server (with IEx for debugging)
iex -S mix phx.server

# Run tests
mix test

# Run a single test file
mix test test/path/to/test.exs

# Run a specific test by line number
mix test test/path/to/test.exs:42

# Code formatting
mix format

# Check formatting without changing files
mix format --check-formatted
```

## Project Structure

- `lib/pawzitively/` - Business logic (contexts, schemas)
- `lib/pawzitively_web/` - Web layer (controllers, LiveViews, templates)
- `lib/pawzitively_web/router.ex` - Route definitions
- `priv/repo/migrations/` - Database migrations
- `config/` - Configuration files (dev.exs, test.exs, prod.exs)

## Learning Resources

- [Elixir Getting Started](https://elixir-lang.org/getting-started/introduction.html)
- [Phoenix Guides](https://hexdocs.pm/phoenix/overview.html)
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/welcome.html)
- [Programming Phoenix LiveView](https://pragprog.com/titles/liveview/programming-phoenix-liveview/) (book)

## Rules

- DO NOT READ any .env files
- NEVER read the .env files

