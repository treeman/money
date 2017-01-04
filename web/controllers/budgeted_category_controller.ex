defmodule Money.BudgetedCategoryController do
  use Money.Web, :controller

  alias Money.BudgetedCategory

  def create(conn, %{"budgeted_category" => budgeted_category_params}) do
    changeset = BudgetedCategory.changeset(%BudgetedCategory{}, budgeted_category_params)

    case Repo.insert(changeset) do
      {:ok, budgeted_category} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", budgeted_category_path(conn, :show, budgeted_category))
        |> render("show.json", budgeted_category: budgeted_category)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Money.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "budgeted_category" => budgeted_category_params}) do
    budgeted_category = Repo.get!(BudgetedCategory, id)
    changeset = BudgetedCategory.changeset(budgeted_category, budgeted_category_params)

    case Repo.update(changeset) do
      {:ok, budgeted_category} ->
        render(conn, "show.json", budgeted_category: budgeted_category)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Money.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    budgeted_category = Repo.get!(BudgetedCategory, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(budgeted_category)

    send_resp(conn, :no_content, "")
  end
end
