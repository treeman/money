defmodule Money.Transaction do
  use Money.Web, :model

  schema "transactions" do
    field :amount, :decimal
    field :when, Ecto.DateTime
    field :payee, :string
    field :description, :string
    belongs_to :account, Money.Account
    belongs_to :category, Money.Category

    timestamps
  end

  @required_fields [:amount, :when, :payee, :account_id]
  @optional_fields [:description, :category_id]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
  end
end

