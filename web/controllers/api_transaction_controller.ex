defmodule Money.ApiTransactionController do
  use Money.Web, :controller
  alias Money.Transaction
  alias Money.TransactionView
  alias Money.Repo
  alias Money.Category
  import Phoenix.View
  require Logger

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
     [conn, conn.params, conn.assigns.current_user])
  end

  # FIXME need to filter on user
  def create(conn, %{"transaction" => params}, _user) do
    params = params |> transform_category
                    |> transform_date

    changeset = Transaction.changeset(%Transaction{}, params)

    case Repo.insert(changeset) do
      {:ok, transaction} ->
        transaction = Repo.preload(transaction, [:category, :account])

        # FIXME should find the rolling balance for the whole account, it needs to be updated!
        balance = rolling_balance(transaction: transaction)

        # FIXME also figure out position (or client side...?)
        html_row = render_to_string TransactionView, "row.html", transaction: transaction, balance: balance, conn: conn

        conn
        |> put_status(:created)
        |> render(TransactionView, "show.json", %{transaction: transaction, balance: balance, html_row: html_row})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Transaction.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def transform_category(%{"category" => category_name} = params) do
    category = Repo.get_by(Category, name: category_name)
    category_id = if category do category.id else nil end

    unless category_id do IO.puts("new category not supported yet!") end

    params |> Map.delete("category")
           |> Map.put_new("category_id", category_id)
  end
  def transform_category(params), do: params

  def transform_date(%{"when" => date_string} = params) when is_binary(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} ->
        Map.put(params, "when", {Date.to_erl(date), {0, 0, 0}})
      {:error, reason} ->
        Logger.warn "Failed to transform date: #{IO.inspect(date_string)} #{IO.inspect(reason)}"
        params
    end
  end
  def transform_date(params), do: params

  def update(conn, %{"id" => id, "transaction" => params}, user) do
    params = params |> transform_category
                    |> transform_date

    transaction = Repo.get!(user_transactions(user), id)
    changeset = Transaction.changeset(transaction, params)

    case Repo.update(changeset) do
      {:ok, transaction} ->
        transaction = Repo.preload(transaction, [:category, :account])

        # FIXME should find the rolling balance for the whole account, it needs to be updated!
        balance = rolling_balance(transaction: transaction)

        # FIXME also figure out position (or client side...?)
        html_row = render_to_string TransactionView, "row.html", transaction: transaction, balance: balance, conn: conn

        conn
        |> render(TransactionView, "show.json", %{transaction: transaction, balance: balance, html_row: html_row})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Transaction.ChangesetView, "error.json", changeset: changeset)
    end
  end
end

