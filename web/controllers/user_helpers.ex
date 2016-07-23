defmodule Money.UserHelpers do
  import Plug.Conn
  import Ecto
  import Ecto.Query

  def preload_user_data(conn, opts) do
    repo = Keyword.fetch!(opts, :repo)

    if user = conn.assigns[:current_user] do
      user = repo.preload(user, :accounts)
      assign(conn, :current_user, user)
    else
      conn
    end
  end

  def user_accounts(user) do
    assoc(user, :accounts)
  end

  def user_transactions(user) do
    from t in Money.Transaction,
    join: a in assoc(t, :account),
    join: u in assoc(a, :user),
    where: u.id == ^user.id
  end
end

