defmodule Money.TransactionHelpers do
  import Ecto.Query
  import Money.UserHelpers
  alias Money.Transaction
  alias Money.Repo

  def rolling_balance(account: account) do
    from t in Transaction,
    select: %{transaction: t,
              balance: fragment("SUM(amount) OVER(ORDER BY ?, ?)",
                                t.when, t.id)},
    preload: :category,
    order_by: [desc: t.when, desc: t.id],
    where: t.account_id == ^account.id
  end

  def rolling_balance(user: user) do
    from t in user_transactions(user),
    order_by: [desc: t.when, desc: t.id],
    preload: :category,
    select: %{transaction: t,
              balance: fragment("SUM(amount) OVER(PARTITION BY ? ORDER BY ?, ?)",
                                t.account_id, t.when, t.id)}
  end

  def rolling_balance(transaction: transaction) do
    transaction = Money.Repo.preload(transaction, :account)
    # Could not figure out a way to construct the query, this was easier...
    transactions = Repo.all(rolling_balance(account: transaction.account))
    %{balance: balance} = Enum.find(transactions, fn x -> x.transaction.id == transaction.id end)
    balance
  end

  def transaction_balance(account: account) do
    balance = Repo.all(rolling_balance(account: account))
    Enum.reduce(balance, %{}, fn %{balance: balance, transaction: t}, acc ->
      Map.put_new(acc, t.id, balance)
    end)
  end
end

