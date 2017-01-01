defmodule Money.Factory do
  use ExMachina.Ecto, repo: Money.Repo

  alias Money.User
  alias Money.Account
  alias Money.Transaction
  alias Money.Category
  alias Money.CategoryGroup
  alias Money.BudgetedCategory

  def user_factory do
    %User{
      name: sequence("user"),
      username: sequence("username"),
      password: "password1",
      password_hash: Comeonin.Bcrypt.hashpwsalt("password1")
    }
  end

  def account_factory do
    %Account{
      title: sequence("account"),
      user: build(:user)
    }
  end

  def transaction_factory do
    %Transaction{
      amount: Decimal.new(:rand.uniform(10000) - 5000),
      when: random_date,
      payee: sequence("payee"),
      #description: sequence("description"),
      account: build(:account),
      #category: build(:category),
    }
  end

  def category_factory do
    %Category{
      name: sequence("name"),
      category_group: build(:category_group)
    }
  end

  def category_group_factory do
    %CategoryGroup{
      name: sequence("name"),
      user: build(:user)
    }
  end

  def budgeted_category_factory do
    date = random_date
    %BudgetedCategory{
      budgeted: Decimal.new(:rand.uniform(10000) - 5000),
      year: date.year,
      month: date.month,
      category: build(:category),
    }
  end

  def random_date do
    #1609459199 corresponds to 2020-12-31 23:59:59
    :rand.uniform(1609459199)
    |> DateTime.from_unix!(:seconds)
    |> Ecto.DateTime.cast!
  end
end

