alias Money.Repo
alias Money.Expense
alias Ecto.Date
alias Ecto.DateTime

# Non-safe population
expenses = [
  %Expense{account_id: 3, amount: 13, category: "Food", where: "Cindy's", when: DateTime.from_date(Date.cast!("2016-07-19")),
           description: "Midnight lunch"},
  %Expense{account_id: 3, amount: 100, category: "Rent", where: "Cindy's", when: DateTime.from_date(Date.cast!("2016-07-15"))},
  %Expense{account_id: 3, amount: 1, category: "Food", where: "Street", when: DateTime.from_date(Date.cast!("2016-07-15"))}]

for expense <- expenses do
  Repo.insert!(expense)
end

