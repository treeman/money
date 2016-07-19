defmodule Money.Repo do
  use Ecto.Repo, otp_app: :money

  #alias Money.User

  #def all(User) do
    #[%User{id: "1", name: "Jose", username: "josevalim", password: "elixir"},
     #%User{id: "2", name: "Bruce", username: "redrapids", password: "elixir"},
     #%User{id: "3", name: "Chris", username: "josevalirismccord", password: "elixir"}]
  #end
  #def all(_module), do: []

  #def get(module, id) do
    #Enum.find all(module), fn map -> map.id == id end
  #end

  #def get_by(module, params) do
    #Enum.find all(module), fn map ->
      #Enum.all?(params, fn {key, val} -> Map.get(map, key) == val end)
    #end
  #end
end

