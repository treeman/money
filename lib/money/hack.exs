import Ecto.Query
alias Money.Repo
alias Money.Account
alias Money.Expense

# Run with mix run lib/money/hack.exs

account = Repo.one(from a in Account, limit: 1)

q2 = from e in Expense,
     select: %{expense: e,
               balance: fragment("SUM(amount) OVER(ORDER BY \"when\", \"id\")")},
     where: e.account_id == ^account.id
r2 = Repo.all(q2)
IO.inspect(r2)

for %{expense: e, balance: b} <- r2 do
  IO.puts("#{e.amount}, #{e.when}, #{b}")
end

