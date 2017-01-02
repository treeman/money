defmodule Money.TransactionView do
  use Money.Web, :view
  alias Money.TransactionView

  def render("show.json", params = %{transaction: transaction}) do
    %{data: render_one(transaction, TransactionView, "transaction.json", params)}
  end

  def render("transaction.json", %{transaction: transaction, transaction_balance: transaction_balance, origin: origin, conn: conn}) do
    category = if transaction.category do transaction.category.name else "" end
    balance = Map.fetch!(transaction_balance, transaction.id)

    render_account_title = origin == account_path(conn, :index)

    html_row = render_to_string TransactionView, "row.html",
                transaction: transaction,
                balance: balance,
                render_account_title: render_account_title,
                conn: conn

    transaction_balance = map_convert_keys transaction_balance

    %{id: transaction.id,
      account_id: transaction.account_id,
      account_title: transaction.account.title,
      amount: transaction.amount,
      when: transaction.when,
      payee: transaction.payee,
      description: transaction.description,
      category: category,
      balance: balance,
      transaction_balance: transaction_balance,
      html_row: html_row}
  end

  def render("delete.json", %{id: id, transaction_balance: transaction_balance}) do
    transaction_balance = map_convert_keys transaction_balance

    %{data: %{id: id, transaction_balance: transaction_balance}}
  end

  def map_convert_keys(map) do
    map
    |> Enum.reduce(%{}, fn {id, v}, acc when is_integer(id) ->
                Map.put_new(acc, Integer.to_string(id), v);
    end)
  end
end

