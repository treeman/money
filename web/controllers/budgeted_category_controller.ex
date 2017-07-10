# FIXME this isn't checked for user access at all
defmodule Money.BudgetedCategoryController do
  use Money.Web, :controller

  alias Money.Category
  alias Money.BudgetedCategory

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
     [conn, conn.params, conn.assigns.current_user])
  end

  def create(conn, %{"year" => year, "month" => month, "category" => params}, user) do
    create(conn, %{"budgeted_category" => %{
             "budgeted" => Decimal.new(0),
             "activity" => Decimal.new(0),
             "year" => year,
             "month" => month,
             "category_id" => grab_category(params, user).id,
           }}, user)
  end

  def create(conn, %{"budgeted_category" => params}, _user) do
    changeset = BudgetedCategory.changeset(%BudgetedCategory{}, params)

    case Repo.insert(changeset) do
      {:ok, budgeted_category} ->
        budgeted_category = Repo.preload(budgeted_category, [:category])

        conn
        |> put_status(:created)
        |> render("show.json", budgeted_category: budgeted_category)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Money.ChangesetView, "error.json", changeset: changeset)
    end
  end

  defp grab_category(%{"name" => name, "category_group_id" => group_id}, user) do
    # FIXME this allows us to insert a category for a group_id not belonging to user
    Repo.get_by(user_categories(user), name: name) ||
      Repo.insert!(%Category{name: name, category_group_id: String.to_integer(group_id)})
  end

  def update(conn, %{"id" => id, "budgeted_category" => budgeted_category_params}, _user) do
    budgeted_category = Repo.get!(BudgetedCategory, id)
    changeset = BudgetedCategory.changeset(budgeted_category, budgeted_category_params)

    case Repo.update(changeset) do
      {:ok, budgeted_category} ->
        budgeted_category = Repo.preload(budgeted_category, [:category])
        render(conn, "show.json", budgeted_category: budgeted_category)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Money.ChangesetView, "error.json", changeset: changeset)
    end
  end
end

