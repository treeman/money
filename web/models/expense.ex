defmodule Money.Expense do
  use Money.Web, :model

  schema "expenses" do
    field :amount, :integer
    field :when, Ecto.DateTime
    field :where, :string # TODO rename
    field :category, :string
    field :description, :string
    belongs_to :account, Money.Account

    timestamps
  end

  @required_fields [:amount, :when, :where]
  @optional_fields [:category, :description]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
  end
end

