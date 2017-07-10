defmodule Money.BudgetHelpers do
  import Plug.Conn
  import Ecto
  import Ecto.Query
  import Money.UserHelpers
  alias Money.Repo
  alias Money.BudgetedCategory
  alias Money.BudgetedCategoryGroup

  def load_activity(budgeted_category, user) do
    {start_date, end_date} = date_range(budgeted_category.year, budgeted_category.month)

    budgeted = Ecto.Adapters.SQL.query!(Money.Repo, """
    SELECT COALESCE(SUM(t.amount), 0)
    FROM categories AS c
    LEFT JOIN transactions AS t
      ON c.id = t.category_id
      AND $2 <= t.when AND t.when <= $3
    INNER JOIN category_groups AS cg
      ON c.category_group_id = cg.id
      AND cg.user_id = $4
    WHERE c.id = $1
    GROUP BY c.id
    """, [budgeted_category.category.id, start_date, end_date, user.id])

    [[activity]] = budgeted.rows
    IO.inspect(activity)

    %{budgeted_category | activity: activity}
  end

  def monthly_budget(user, year, month) do
    {start_date, end_date} = date_range(year, month)

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

  defp date_range(year, month) do
    # Select transactions during a single month.
    last_day = :calendar.last_day_of_the_month(year, month)
    {:ok, start_date} = Ecto.DateTime.cast({{year, month, 1}, {0, 0, 0}})
    {:ok, end_date} = Ecto.DateTime.cast({{year, month, last_day}, {23, 59, 59}})
    {start_date, end_date}
  end

end

