.PHONY: deps create migrate dev-server server test format format-check

deps:
	mix deps.get

create:
	mix ecto.create

migrate:
	mix ecto.migrate

dev-server:
	iex -S mix phx.server

serve:
	mix phx.server

test:
	mix test

format:
	mix format

format-check:
	mix format --check-formatted
