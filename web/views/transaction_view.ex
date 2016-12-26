defmodule Money.TransactionView do
  use Money.Web, :view
  alias Money.TransactionView

  def render("show.json", %{transaction: transaction, html_row: html_row}) do
    %{data: render_one(transaction, TransactionView, "transaction.json", html_row: html_row)}
  end

  def render("transaction.json", %{transaction: transaction, html_row: html_row}) do
    category = if transaction.category do transaction.category.name else "" end

    %{id: transaction.id,
      amount: transaction.amount,
      when: transaction.when,
      payee: transaction.payee,
      description: transaction.description,
      category: category,
      html_row: html_row}
  end
end

