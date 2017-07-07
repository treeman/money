defmodule Money.TransactionHelpers do
  import Ecto.Query
  import Money.UserHelpers
  alias Money.Transaction
  alias Money.Repo

  def rolling_balance(user: user) do
    from(t in user_transactions(user))
    |> rolling_balance
  end

  def rolling_balance(account: account) do
    from(t in Transaction, where: t.account_id == ^account.id)
    |> rolling_balance
  end

  def rolling_balance(account_id: account_id) do
    from(t in Transaction, where: t.account_id == ^account_id)
    |> rolling_balance
  end

  def rolling_balance(account_ids: account_ids) do
    from(t in Transaction, where: t.account_id in ^account_ids)
    |> rolling_balance
  end

  def rolling_balance(transaction: transaction) do
    from(t in Transaction, where: t.id == ^transaction.id)
    |> rolling_balance
  end

  def rolling_balance(query) do
    from t in query,
    order_by: [desc: t.when, desc: t.id],
    preload: :category,
    select: %{transaction: t,
              balance: fragment("SUM(amount) OVER(PARTITION BY ? ORDER BY ?, ?)",
                                t.account_id, t.when, t.id)}
  end

  def transaction_balance(params) do
    balance = Repo.all(rolling_balance(params))
    Enum.reduce(balance, %{}, fn %{balance: balance, transaction: t}, acc ->
      Map.put_new(acc, t.id, balance)
    end)
  end
end

