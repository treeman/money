defmodule Money.TransactionView do
  use Money.Web, :view
  alias Money.TransactionView

  def render("show.json", params = %{transaction: transaction}) do
    %{data: render_one(transaction, TransactionView, "transaction.json", params)}
  end

  def render("transaction.json", %{transaction: transaction, transaction_balance: transaction_balance, conn: conn}) do
    category = if transaction.category do transaction.category.name else "" end
    balance = Map.fetch!(transaction_balance, transaction.id)

    # FIXME For now always render this... But maybe should ignore and update on js side...?
    html_row = render_to_string TransactionView, "row.html",
                transaction: transaction,
                balance: balance,
                conn: conn

    # Transform map keys to strings, json expects it.
    transaction_balance = transaction_balance
                          |> Enum.reduce(%{}, fn {id, v}, acc when is_integer(id) ->
                               Map.put_new(acc, Integer.to_string(id), v);
                          end)

    %{id: transaction.id,
      account_id: transaction.account_id,
      amount: transaction.amount,
      when: transaction.when,
      payee: transaction.payee,
      description: transaction.description,
      category: category,
      balance: balance,
      transaction_balance: transaction_balance,
      html_row: html_row}
  end
end

