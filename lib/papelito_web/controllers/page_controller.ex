defmodule PapelitoWeb.PageController do
  use PapelitoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
