defmodule Money.AccountController do
  use Money.Web, :controller
  alias Money.Account
  alias Money.Expense

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
     [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, user) do
    expenses = Repo.all(rolling_balance(user: user))
    render(conn, "show.html", expenses: expenses)
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
    expenses = Repo.all(rolling_balance(account: account))

    render(conn, "show.html", account: account, expenses: expenses)
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

  defp user_accounts(user) do
    assoc(user, :accounts)
  end

  defp rolling_balance(account: account) do
    from e in Expense,
    select: %{expense: e,
              balance: fragment("SUM(amount) OVER(ORDER BY ?, ?)",
                                e.when, e.id)},
    order_by: [desc: e.when],
    where: e.account_id == ^account.id
  end

  defp rolling_balance(user: user) do
    IO.inspect(user)
    from e in Expense,
    join: a in assoc(e, :account),
    join: u in assoc(a, :user),
    select: %{expense: e,
              balance: fragment("SUM(amount) OVER(PARTITION BY ? ORDER BY ?, ?)",
                                e.account_id, e.when, e.id)},
    order_by: [desc: e.when],
    where: u.id == ^user.id
  end
end

