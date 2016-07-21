defmodule Money.Category do
  use Money.Web, :model

  schema "categories" do
    field :name, :string, null: false
    belongs_to :category_group, Money.CategoryGroup

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end

