defmodule Money.CategoryGroupController do
  use Money.Web, :controller

  alias Money.CategoryGroup

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
     [conn, conn.params, conn.assigns.current_user])
  end

  def create(conn, %{"category_group" => category_group_params}, user) do
    changeset = CategoryGroup.changeset(%CategoryGroup{user_id: user.id}, category_group_params)

    case Repo.insert(changeset) do
      {:ok, category_group} ->
        conn
        |> put_status(:created)
        |> render("show.json", category_group: category_group)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Money.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "category_group" => category_group_params}, user) do
    category_group = Repo.get!(user_category_groups(user), id)
    changeset = CategoryGroup.changeset(category_group, category_group_params)

    case Repo.update(changeset) do
      {:ok, category_group} ->
        render(conn, "show.json", category_group: category_group)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Money.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
