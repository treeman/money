defmodule Money.CategoryGroup do
  use Money.Web, :model

  schema "category_groups" do
    field :name, :string
    has_many :categories, Money.Category

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
