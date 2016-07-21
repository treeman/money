import Ecto.Query
alias Money.Repo
alias Money.Account
alias Money.Expense
alias Money.User

# Run with mix run lib/money/hack.exs

#account = Repo.one(from a in Account, limit: 1)

#q2 = from e in Expense,
     #select: %{expense: e,
               #balance: fragment("SUM(amount) OVER(ORDER BY \"when\", \"id\")")},
     #where: e.account_id == ^account.id
#r2 = Repo.all(q2)
#IO.inspect(r2)

#for %{expense: e, balance: b} <- r2 do
  #IO.puts("#{e.amount}, #{e.when}, #{b}")
#end

user = Repo.get_by(User, username: "tradet")

q3 = from e in Expense,
     join: a in assoc(e, :account),
     join: u in assoc(a, :user),
     select: %{expense: e,
               balance: fragment("SUM(amount) OVER(PARTITION BY ? ORDER BY ?, ?)", e.account_id, e.when, e.id)},
     order_by: [desc: e.when],
     where: u.id == ^user.id
r3 = Repo.all(q3)
IO.inspect(r3)

for %{expense: e, balance: b} <- r3 do
  IO.puts("#{e.account_id}, #{e.amount}, #{e.when}, #{b}")
end
