defmodule Money.CategoryGroupController do
  use Money.Web, :controller

  alias Money.CategoryGroup

  def create(conn, %{"category_group" => category_group_params}) do
    changeset = CategoryGroup.changeset(%CategoryGroup{}, category_group_params)

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

  def update(conn, %{"id" => id, "category_group" => category_group_params}) do
    category_group = Repo.get!(CategoryGroup, id)
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

  def delete(conn, %{"id" => id}) do
    category_group = Repo.get!(CategoryGroup, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(category_group)

    send_resp(conn, :no_content, "")
  end
end
