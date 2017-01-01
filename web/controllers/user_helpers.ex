defmodule Money.UserHelpers do
  import Plug.Conn
  import Ecto
  import Ecto.Query
  alias Money.Repo
  alias Money.Category
  alias Money.CategoryGroup

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

  def user_category_groups(user) do
    from g in CategoryGroup,
    join: u in assoc(g, :user),
    where: u.id == ^user.id
  end

  def user_categories(user) do
    from c in Category,
    join: g in assoc(c, :category_group),
    join: u in assoc(g, :user),
    where: u.id == ^user.id
  end

  def load_categories(conn, _) do
    user = conn.assigns[:current_user]

    query =
      user_categories(user)
      |> Category.alphabetical
      |> Category.names_and_ids
    categories = Repo.all(query)
    assign(conn, :categories, categories)
  end
end

