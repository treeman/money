defmodule Money.BudgetedCategory do
  use Money.Web, :model

  schema "budgeted_categories" do
    field :budgeted, :decimal
    field :year, :integer
    field :month, :integer
    belongs_to :category, Money.Category
    field :activity, :decimal, virtual: true, default: Decimal.new(0)

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:budgeted, :year, :month, :category_id, :activity])
    |> validate_required([:budgeted, :year, :month, :category_id])
    |> validate_number(:budgeted, greater_than_or_equal_to: Decimal.new(0))
    |> validate_number(:year, greater_than_or_equal_to: 0)
    |> validate_number(:month, greater_than_or_equal_to: 1,
                               less_than_or_equal_to: 12)
  end
end

