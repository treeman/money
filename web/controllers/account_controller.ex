defmodule Money.AccountController do
  import Ecto.Query
  use Money.Web, :controller
  alias Money.Account
  alias Money.Transaction

  plug :load_categories when action in [:show, :index]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
     [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, user) do
    transactions = Repo.all(rolling_balance(user: user))
    render(conn, "show.html", transactions: transactions)
  end

  def new(conn, _params, user) do
    changeset =
      user
      |> build_assoc(:accounts)
      |> Account.changeset()

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"account" => account_params}, user) do
    changeset =
      user
      |> build_assoc(:accounts)
      |> Account.changeset(account_params)

    case Repo.insert(changeset) do
      {:ok, _account} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: account_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    account = Repo.get!(user_accounts(user), id)
    transactions = Repo.all(rolling_balance(account: account))
    new_transaction = Transaction.changeset(%Transaction{}, %{account_id: account.id})

    render(conn, "show.html",
           account: account,
           transactions: transactions,
           new_transaction: new_transaction)
  end

  def edit(conn, %{"id" => id}, user) do
    account = Repo.get!(user_accounts(user), id)
    changeset = Account.changeset(account)
    render(conn, "edit.html", account: account, changeset: changeset)
  end

  def update(conn, %{"id" => id, "account" => account_params}, user) do
    account = Repo.get!(user_accounts(user), id)
    changeset = Account.changeset(account, account_params)

    case Repo.update(changeset) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: account_path(conn, :show, account))
      {:error, changeset} ->
        render(conn, "edit.html", account: account, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    account = Repo.get!(user_accounts(user), id)

    Repo.delete!(account)

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: account_path(conn, :index))
  end

  def delete_transactions(conn, %{"id" => id}, user) do
    account = Repo.get!(user_accounts(user), id)
    Repo.delete_all(from t in Transaction,
                    where: t.account_id == ^account.id)
    conn
    |> put_flash(:info, "Deleted all transactions.")
    |> redirect(to: account_path(conn, :show, account.id))
  end
end

