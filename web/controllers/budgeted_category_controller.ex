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
    insert(conn, changeset)
  end

  defp grab_category(%{"name" => name, "category_group_id" => group_id}, user) do
    Repo.one(from c in user_categories(user),
               join: cg in assoc(c, :category_group),
               where: c.name == ^name,
               where: cg.id == ^group_id) ||
    # FIXME this allows us to insert a category for a group_id not belonging to user
      Repo.insert!(%Category{name: name,
                             category_group_id: String.to_integer(group_id)})
  end

  def save(conn, %{"year" => year, "month" => month, "budgeted_category" => params}, user) do
    category = Repo.get!(user_categories(user), params["category_id"])

    budgeted_category = Repo.get_by(BudgetedCategory,
                                    category_id: category.id,
                                    year: year,
                                    month: month)
    if budgeted_category do
      updateChange(conn, BudgetedCategory.changeset(budgeted_category, params))
    else
      params = Map.merge(params, %{"year" => year,
                                   "month" => month});
      insert(conn, BudgetedCategory.changeset(
                    %BudgetedCategory{category_id: category.id},
                    params))
    end
  end

  defp updateChange(conn, changeset) do
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

  defp insert(conn, changeset) do
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
end

