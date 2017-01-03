defmodule Money.TransactionController do
  use Money.Web, :controller
  alias Money.Transaction
  alias Money.TransactionView
  alias Money.Repo
  alias Money.ChangesetView
  require Logger

  plug :load_categories when action in [:new, :create, :edit, :update]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
     [conn, conn.params, conn.assigns.current_user])
  end

  def create(conn, %{"transaction" => params}, user) do
    changeset = Transaction.changeset(%Transaction{}, params)
                |> transform_category(params, user)
                |> transform_account(params, user)

    case Repo.insert(changeset) do
      {:ok, transaction} ->
        transaction = Repo.preload(transaction, [:category, :account])

        transaction_balance = transaction_balance(account: transaction.account)

        conn
        |> put_status(:created)
        |> render(TransactionView, "show.json", %{transaction: transaction,
                                                  transaction_balance: transaction_balance,
                                                  render_account_title: Map.has_key?(params, "account"),
                                                  conn: conn})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "transaction" => params}, user) do
    transaction = Repo.get!(user_transactions(user), id)
    changeset = Transaction.changeset(transaction, params)
                |> transform_category(params, user)
                |> transform_account(params, user)

    case Repo.update(changeset) do
      {:ok, transaction} ->
        transaction = Repo.preload(transaction, [:category, :account])

        transaction_balance = transaction_balance(account: transaction.account)

        conn
        |> render(TransactionView, "show.json", %{transaction: transaction,
                                                  transaction_balance: transaction_balance,
                                                  render_account_title: Map.has_key?(params, "account"),
                                                  conn: conn})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    transaction = Repo.get!(user_transactions(user), id)

    Repo.delete!(transaction)

    transaction_balance = transaction_balance(account_id: transaction.account_id)

    conn
    |> render(TransactionView, "delete.json", %{id: transaction.id,
                                                transaction_balance: transaction_balance})
  end

  defp transform_category(changeset, %{"category" => category_name}, user) do
    %{changes: changes, errors: errors} = changeset

    category = Repo.get_by(user_categories(user), name: category_name)
    if category do
      %{changeset | changes: Map.put_new(changes, :category_id, category.id)}
    else
      %{changeset | errors: [{:category, {"unknown category: '" <> category_name <> "'", []}} | errors],
                      valid?: false}
    end
  end
  defp transform_category(changeset, _, _), do: changeset

  defp transform_account(changeset, %{"account" => account_title}, user) do
    %{changes: changes, errors: errors} = changeset

    account = Repo.get_by(user_accounts(user), title: account_title)
    if account do
      errors = Keyword.delete(errors, :account_id)
      %{changeset | changes: Map.put_new(changes, :account_id, account.id),
                    errors: errors,
                    valid?: length(errors) == 0}
    else
      %{changeset | errors: [{:account, {"unknown account: '" <> account_title <> "'", []}} | errors],
                      valid?: false}
    end
  end
  defp transform_account(changeset, _, _), do: changeset
end

