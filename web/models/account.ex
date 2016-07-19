defmodule Money.Account do
  use Money.Web, :model

  schema "accounts" do
    field :title, :string
    belongs_to :user, Money.User

    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title])
    |> validate_required([:title])
  end
end

