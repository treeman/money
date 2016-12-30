defmodule Money.CategoryGroup do
  use Money.Web, :model

  schema "category_groups" do
    field :name, :string
    has_many :categories, Money.Category, on_delete: :delete_all
    belongs_to :user, Money.User

    timestamps()
  end

  @required_fields [:name, :user_id]
  @optional_fields []

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
  end
end
