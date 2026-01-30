defmodule PawzitivelyWeb.PageController do
  use PawzitivelyWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
