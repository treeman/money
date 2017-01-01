defmodule Money.Category do
  use Money.Web, :model

  schema "categories" do
    field :name, :string
    belongs_to :category_group, Money.CategoryGroup
    has_many :transactions, Money.Transaction
    has_many :budgeted_category, Money.BudgetedCategory

    timestamps()
  end

  @required_fields [:name, :category_group_id]
  @optional_fields []

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
  end

  def alphabetical(query) do
    from c in query, order_by: c.name
  end

  def names_and_ids(query) do
    from c in query, select: {c.name, c.id}
  end
end

