defmodule Money.TransactionController do
  use Money.Web, :controller
  alias Money.Transaction
  alias Money.Category

  plug :load_categories when action in [:new, :create, :edit, :update]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
     [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, user) do
    transactions = Repo.all(user_transactions(user))
    render(conn, "index.html", transactions: transactions)
  end

  def new(conn, %{"account_id" => account_id}, _user) do
    changeset = Transaction.changeset(%Transaction{}, %{account_id: account_id})
    render(conn, "new.html", changeset: changeset)
  end
  # Cannot do it yet.
  #def new(conn, _params, _user) do
    #changeset = Transaction.changeset(%Transaction{}, %{})
    #render(conn, "new.html", changeset: changeset)
  #end

  def create(conn, %{"transaction" => transaction_params}, _user) do
    changeset = Transaction.changeset(%Transaction{}, transaction_params)

    case Repo.insert(changeset) do
      {:ok, _transaction} ->
        # TODO handle redirects in a cleaner way.
        account_id = Map.get(transaction_params, "account_id")
        conn
        |> put_flash(:info, "Transaction created successfully.")
        |> redirect(to: account_path(conn, :show, account_id))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    transaction = Repo.get!(user_transactions(user), id)

    render(conn, "show.html", transaction: transaction)
  end

  def edit(conn, %{"id" => id}, user) do
    transaction = Repo.get!(user_transactions(user), id)
    changeset = Transaction.changeset(transaction)
    render(conn, "edit.html", transaction: transaction, changeset: changeset)
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}, user) do
    transaction = Repo.get!(user_transactions(user), id)
    changeset = Transaction.changeset(transaction, transaction_params)

    case Repo.update(changeset) do
      {:ok, transaction} ->
        conn
        |> put_flash(:info, "Transaction updated successfully.")
        |> redirect(to: transaction_path(conn, :show, transaction))
      {:error, changeset} ->
        render(conn, "edit.html", transaction: transaction, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    transaction = Repo.get!(user_transactions(user), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(transaction)

    conn
    |> put_flash(:info, "Transaction deleted successfully.")
    |> redirect(to: account_path(conn, :show, transaction.account_id))
  end

  defp load_categories(conn, _) do
    query =
      Category
      |> Category.alphabetical
      |> Category.names_and_ids
    categories = Repo.all(query)
    assign(conn, :categories, categories)
  end
end

