defmodule Money.PageController do
  use Money.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
