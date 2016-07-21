defmodule Money.UserHelper do
  import Plug.Conn

  def preload_user_data(conn, opts) do
    repo = Keyword.fetch!(opts, :repo)

    if user = conn.assigns[:current_user] do
      user = repo.preload(user, :accounts)
      assign(conn, :current_user, user)
    else
      conn
    end
  end
end

