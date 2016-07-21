defmodule Money.ExpenseController do
  use Money.Web, :controller

  import Ecto.Query
  alias Money.Expense

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
     [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, user) do
    expenses = Repo.all(user_expenses(user))
    render(conn, "index.html", expenses: expenses)
  end

  def new(conn, _params, _user) do
    changeset = Expense.changeset(%Expense{}, %{})
    render(conn, "new.html", changeset: changeset)
  end
  def new(conn, %{"account_id" => account_id}, _user) do
    changeset = Expense.changeset(%Expense{}, %{account_id: account_id})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"expense" => expense_params}, user) do
    account_id = Map.get(expense_params, "account_id")
    account = Repo.get!(user_accounts(user), account_id)

    changeset =
      build_assoc(account, :expenses)
      |> Expense.changeset(expense_params)

    case Repo.insert(changeset) do
      {:ok, _expense} ->
        conn
        |> put_flash(:info, "Expense created successfully.")
        |> redirect(to: account_path(conn, :show, account_id))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    expense = Repo.get!(user_expenses(user), id)

    render(conn, "show.html", expense: expense)
  end

  def edit(conn, %{"id" => id}, user) do
    expense = Repo.get!(user_expenses(user), id)
    changeset = Expense.changeset(expense)
    render(conn, "edit.html", expense: expense, changeset: changeset)
  end

  def update(conn, %{"id" => id, "expense" => expense_params}, user) do
    expense = Repo.get!(user_expenses(user), id)
    changeset = Expense.changeset(expense, expense_params)

    case Repo.update(changeset) do
      {:ok, expense} ->
        conn
        |> put_flash(:info, "Expense updated successfully.")
        |> redirect(to: expense_path(conn, :show, expense))
      {:error, changeset} ->
        render(conn, "edit.html", expense: expense, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    expense = Repo.get!(user_expenses(user), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(expense)

    conn
    |> put_flash(:info, "Expense deleted successfully.")
    |> redirect(to: account_path(conn, :show, expense.account_id))
  end

  defp user_accounts(user) do
    assoc(user, :accounts)
  end

  defp user_expenses(user) do
    from e in Expense,
    join: a in assoc(e, :account),
    join: u in assoc(a, :user),
    where: u.id == ^user.id
  end
end

