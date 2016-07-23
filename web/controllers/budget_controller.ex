defmodule Money.BudgetController do
  use Money.Web, :controller
  alias Money.Router.Helpers
  alias Money.BudgetedCategory
  alias Money.BudgetedCategoryGroup
  alias Money.CategoryGroup

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
     [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, _user) do
    # TODO redirect to last viewed month
    {{year, month, _}, _} = :calendar.local_time()

    conn |> redirect(to: Helpers.budget_path(conn, :show, year, month))
  end

  def show(conn, %{"year" => year, "month" => month}, user) do
    year = String.to_integer(year)
    month = String.to_integer(month)

    budget = monthly_budget(user, year, month)
    render(conn, "show.html", year: year, month: month, budget: budget)
  end

  defp monthly_budget(user, year, month) do
    # Select transactions during a single month.
    last_day = :calendar.last_day_of_the_month(year, month)
    {:ok, start_date} = Ecto.DateTime.cast({{year, month, 1}, {0, 0, 0}})
    {:ok, end_date} = Ecto.DateTime.cast({{year, month, last_day}, {0, 0, 0}})

    transactions =
      from t in user_transactions(user),
      where: ^start_date <= t.when and t.when <= ^end_date

    # Find the amount budgeted and sum the transactions for that category.
    budgeted =
      from t in transactions,
      join: c in assoc(t, :category),
      join: bc in assoc(c, :budgeted_category),
      group_by: [c.id, bc.budgeted],
      where: bc.year == ^year and bc.month == ^month,
      select: %{category_id: c.id,
                activity: sum(t.amount),
                budgeted: bc.budgeted}

    # We only construct a budget for a category if the user updates it,
    # transform to a map to keep a record of the existing ones.
    existing_budgets = Enum.reduce Repo.all(budgeted), %{}, fn b, acc->
      Map.put(acc, b[:category_id], b)
    end

    # Organize the budgets by group and generate budgeted categories for all categories
    # even if they do not exist in the database. Should only insert on update.

    # TODO categories/budgets only for a single user.
    groups = from g in CategoryGroup, preload: :categories

    budget = Enum.map Repo.all(groups), fn g ->
      # Simultaneously sum and generate budgeted categories.
      {budgeted, activity, budgeted_categories} =
        Enum.reduce g.categories,
                    {0, 0, []},
                    fn c, {budgeted_sum, activity_sum, categories} ->

          category = case Map.get(existing_budgets, c.id) do
            %{activity: activity,
              budgeted: budgeted} ->
                %BudgetedCategory{year: year, month: month,
                                  budgeted: budgeted, activity: activity,
                                  category_id: c.id, category: c}
            nil ->
                %BudgetedCategory{year: year, month: month,
                                  budgeted: 0, activity: 0,
                                  category_id: c.id, category: c}
          end

          {budgeted_sum + category.budgeted,
           activity_sum + category.activity,
           [category | categories]}
        end

      %BudgetedCategoryGroup{
        category_group_id: g.id,
        name: g.name,
        budgeted: budgeted,
        activity: activity,
        budgeted_categories: Enum.sort(budgeted_categories,
                                       &(&1.category.name < &2.category.name))
      }
    end
    # TODO custom sort.
    Enum.sort(budget, &(&1.name < &2.name))
  end
end

