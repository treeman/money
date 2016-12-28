import Ecto
alias Money.Repo
#alias Money.Category
alias Money.CategoryGroup

# Hmmm...
# What about creating a Category tree?
# Maybe not.

# Just temporary. Restructure when better defaults are found.
groups = [
  %{name: "Immediate Obligations",
    categories: ["Rent", "Mortgage", "Electric", "Water", "Internet",
                 "Transportation", "Telephone", "Subscriptions"]},
  %{name: "Debt Payments",
    categories: ["Student Loan"]},
  %{name: "Savings",
    categories: ["Emergency Expenses"]},
  %{name: "Life Investments",
    categories: ["Vacation", "Fitness", "Education"]},
  %{name: "Fun",
    categories: ["Dining", "Gaming", "Music", "Entertainment", "Fun Money"]},
  %{name: "Unknown",
    categories: ["Medical", "Clothing", "Home Maintenance", "Auto Maintenance",
                 "Insurance", "Gifts", "Giving", "Computer Replacement",
                 "Forgotten Stuff"]}
]

for %{name: name, categories: categories} <- groups do
  group = Repo.get_by(CategoryGroup, name: name) ||
            %CategoryGroup{name: name}
            |> Repo.insert!()
  for c <- categories do
    category = build_assoc(group, :categories, %{name: c})
    Repo.insert!(category)
  end
end

