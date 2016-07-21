defmodule Money.BudgetController do
  use Money.Web, :controller
  alias Money.Transaction

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
     [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, _user) do
    render(conn, "index.html")
  end

  def show(conn, %{"year" => year, "month" => month}, user) do
    IO.puts("year: #{year} month: #{month}")
    render(conn, "show.html", year: year, month: month)

    year = String.to_integer(year)
    month = String.to_integer(month)

    last_day = :calendar.last_day_of_the_month(year, month)
    {:ok, start_date} = Ecto.DateTime.cast({{year, month, 1}, {0, 0, 0}})
    {:ok, end_date} = Ecto.DateTime.cast({{year, month, last_day}, {0, 0, 0}})
    #start_date = {{year, month, 1}, {0, 0, 0}}
    #end_date = {{year, month, last_day}, {0, 0, 0}}

    IO.inspect(start_date)
    IO.inspect(end_date)
    transactions = Repo.all(filter_transactions(user, start_date, end_date))
    IO.inspect(transactions)
  end

  defp filter_transactions(user, start_date, end_date) do
    from e in Transaction,
    join: a in assoc(e, :account),
    join: u in assoc(a, :user),
    where: u.id == ^user.id,
    where: ^start_date <= e.when and e.when <= ^end_date,
    preload: :category
  end
end

