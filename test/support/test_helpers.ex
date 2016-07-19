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
end

