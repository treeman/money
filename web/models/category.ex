defmodule Money.Category do
  use Money.Web, :model

  schema "categories" do
    field :name, :string
    belongs_to :category_group, Money.CategoryGroup
    has_many :transactions, Money.Transaction
    has_many :budgeted_category, Money.BudgetedCategory

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  def alphabetical(query) do
    from c in query, order_by: c.name
  end

  def names_and_ids(query) do
    from c in query, select: {c.name, c.id}
  end
end

