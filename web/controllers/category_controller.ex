defmodule Money.CategoryController do
  use Money.Web, :controller

  alias Money.Category

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
     [conn, conn.params, conn.assigns.current_user])
  end

  def create(conn, %{"category" => category_params}, _user) do
    changeset = Category.changeset(%Category{}, category_params)

    case Repo.insert(changeset) do
      {:ok, category} ->
        conn
        |> put_status(:created)
        |> render("show.json", category: category,
                               conn: conn)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Money.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "category" => category_params}, user) do
    category = Repo.get!(user_categories(user), id)
    changeset = Category.changeset(category, category_params)

    case Repo.update(changeset) do
      {:ok, category} ->
        render(conn, "show.json", category: category)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Money.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete_categories(conn, %{"data" => %{"groups" => groups, "categories" => categories}}, user) do
    groups = Poison.decode!(groups)
    groups = from g in user_category_groups(user),
             where: g.name in ^groups
    {_, deleted_groups} = Repo.delete_all(groups, returning: [:name])
    deleted_groups = Enum.map(deleted_groups, fn g -> g.name end)

    categories = Poison.decode!(categories)
    categories = from c in user_categories(user),
                 where: c.name in ^categories
    {_, deleted_categories} = Repo.delete_all(categories, returning: [:name])
    deleted_categories = Enum.map(deleted_categories, fn c -> c.name end)

    conn
    |> render(Money.CategoryView, "delete.json",
              %{groups: deleted_groups,
                categories: deleted_categories})
  end
end

