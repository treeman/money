defmodule Money.TransactionView do
  use Money.Web, :view
  alias Money.TransactionView

  def render("show.json", %{transaction: transaction, balance: balance, html_row: html_row}) do
    %{data: render_one(transaction, TransactionView, "transaction.json", balance: balance, html_row: html_row)}
  end

  def render("transaction.json", %{transaction: transaction, balance: balance, html_row: html_row}) do
    category = if transaction.category do transaction.category.name else "" end

    %{id: transaction.id,
      account_id: transaction.account_id,
      amount: transaction.amount,
      when: transaction.when,
      payee: transaction.payee,
      description: transaction.description,
      category: category,
      balance: balance,
      html_row: html_row}
  end
end

