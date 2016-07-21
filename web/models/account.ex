defmodule Money.Account do
  use Money.Web, :model

  schema "accounts" do
    field :title, :string
    belongs_to :user, Money.User
    has_many :transactions, Money.Transaction, on_delete: :delete_all

    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title])
    |> validate_required([:title])
  end
end

