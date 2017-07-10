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
end

