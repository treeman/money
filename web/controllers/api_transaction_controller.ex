defmodule Money.ApiTransactionController do
  use Money.Web, :controller
  alias Money.Transaction
  alias Money.TransactionView
  import Phoenix.View

  def create(conn, %{"transaction" => transaction_params}) do
    changeset = Transaction.changeset(%Transaction{}, transaction_params)

    case Repo.insert(changeset) do
      {:ok, transaction} ->
        transaction = Money.Repo.preload(transaction, :category)

        html_row = render_to_string TransactionView, "row.html", transaction: transaction, balance: 0, conn: conn

        conn
        |> put_status(:created)
        |> render(TransactionView, "show.json", %{transaction: transaction, html_row: html_row})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Transaction.ChangesetView, "error.json", changeset: changeset)
    end
  end
end

