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
        |> render("show.json", category: category)
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

  def delete(conn, %{"id" => id}, user) do
    category = Repo.get!(user_categories(user), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(category)

    send_resp(conn, :no_content, "")
  end
end
