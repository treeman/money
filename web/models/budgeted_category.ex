defmodule Money.BudgetedCategory do
  use Money.Web, :model

  schema "budgeted_categories" do
    field :budgeted, :decimal
    field :year, :integer
    field :month, :integer
    belongs_to :category, Money.Category
    field :activity, :decimal, virtual: true

    timestamps()
  end

  @required_fields [:budgeted, :year, :month]
  @optional_fields [:category_id, :activity]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:budgeted, greater_than_or_equal_to: Decimal.new(0))
    |> validate_number(:year, greater_than_or_equal_to: 0)
    |> validate_number(:month, greater_than_or_equal_to: 1,
                               less_than_or_equal_to: 12)
  end
end

