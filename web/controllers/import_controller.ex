defmodule Money.ImportController do
  use Money.Web, :controller

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
     [conn, conn.params, conn.assigns.current_user])
  end

  def new(conn, %{"account_id" => account_id}, _user) do
    render(conn, "new.html", account_id: account_id)
  end

  def parse(conn, %{"account_id" => account_id, "data" => data}, _user) do
    # FIXME complete me
    _transactions = Money.Import.Swedbank.parse_transactions(data)

    conn |> redirect(to: import_path(conn, :new, account_id))
  end
end

