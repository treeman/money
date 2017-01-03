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
    |> transform_date(params)
    |> validate_required(@required_fields)
  end

  defp transform_date(changeset, %{"when" => date_string} = params) when is_binary(date_string) do
    %{changes: changes, errors: errors} = changeset
    errors = Keyword.delete(errors, :when)

    case Date.from_iso8601(date_string) do
      {:ok, date} ->
        dt = Ecto.DateTime.from_date(Ecto.Date.cast!(date))
        %{changeset | changes: Map.put_new(changes, :when, dt),
                      errors: errors,
                      valid?: length(errors) == 0}
      {:error, reason} ->
        %{changeset | errors: [{:when, {"does not match YYYY-MM-DD", []}} | errors],
                      valid?: false}
    end
  end
  defp transform_date(changeset, _), do: changeset
end

