defmodule Money.TestHelpers do
  alias Money.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "Some User",
      username: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}",
      password: "supersecret",
    }, attrs)

  %Money.User{}
  |> Money.User.registration_changeset(changes)
  |> Repo.insert!()
  end

  def insert_account(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:accounts, attrs)
    |> Repo.insert!()
  end

  def insert_transaction(account, attrs \\ %{}) do
    changes = Dict.merge(%{
      amount: 13,
      when: Ecto.DateTime.utc,
      payee: "Unknown"
    }, attrs)

    account
    |> Ecto.build_assoc(:transactions, changes)
    |> Repo.insert!()
  end

  def insert_category(attrs \\ %{}) do
    changes = Dict.merge(%{name: "Rent"}, attrs)

    %Money.Category{}
    |> Money.Category.changeset(changes)
    |> Repo.insert!()
  end
end

