defmodule Money.MonthlyBudget do
  use Money.Web, :model

  schema "transactions" do
    field :year, :integer
    field :month, :integer
    has_many :budgeted_categories, Money.BudgetedCategories

    timestamps
  end

  @required_fields [:year, :month]
  @optional_fields []

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
  end
end

defmodule Money.BudgetedCategories do
  use Money.Web, :model

  schema "transactions" do
    field :amount, :integer
    has_one :category, Money.Category
    belongs_to :monthly_budget, Money.MonthlyBudget

    timestamps
  end

  @required_fields [:amount]
  @optional_fields []

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
  end
end

