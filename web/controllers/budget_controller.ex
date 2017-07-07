defmodule Money.BudgetController do
  use Money.Web, :controller
  alias Money.Router.Helpers
  alias Money.BudgetedCategory
  alias Money.BudgetedCategoryGroup

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
    {:ok, end_date} = Ecto.DateTime.cast({{year, month, last_day}, {23, 59, 59}})

    # Find the amount budgeted and sum of transactions for that category.
    # All categories must be there, non-existing transactions/budgets should be 0.
    budgeted = Ecto.Adapters.SQL.query!(Money.Repo, """
    SELECT c.id, COALESCE(SUM(t.amount), 0), COALESCE(bc.budgeted, 0), c.name
    FROM categories AS c
    LEFT JOIN transactions AS t
      ON c.id = t.category_id
      AND $1 <= t.when AND t.when <= $2
    LEFT JOIN budgeted_categories AS bc
      ON c.id = bc.category_id
      AND bc.year = $3 AND bc.month = $4
    INNER JOIN category_groups AS cg
      ON c.category_group_id = cg.id
      AND cg.user_id = $5
    GROUP BY c.id, bc.id
    """, [start_date, end_date, year, month, user.id])

    # We only construct a budget for a category if the user updates it,
    # transform to a map to keep a record of the existing ones.
    budgets = Enum.reduce budgeted.rows, %{}, fn [c_id, activity, budgeted, c_name], acc->
      Map.put(acc, c_id, %{
        category_id: c_id,
        category_name: c_name,
        activity: activity,
        budgeted: budgeted
      })
    end

    groups = from g in user_category_groups(user), preload: :categories

    budget = Enum.map Repo.all(groups), fn g ->
      # Simultaneously sum and generate budgeted categories.
      {budgeted, activity, budgeted_categories} =
        Enum.reduce g.categories,
                    {Decimal.new(0), Decimal.new(0), []},
                    fn c, {budgeted_sum, activity_sum, categories} ->

          # All categories should exist!
          %{activity: activity, budgeted: budgeted} = Map.get(budgets, c.id)

          category = %BudgetedCategory{year: year, month: month,
                                       budgeted: budgeted, activity: activity,
                                       category_id: c.id, category: c}

          {Decimal.add(budgeted_sum, category.budgeted),
           Decimal.add(activity_sum, category.activity),
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

