defmodule Money.UserView do
  use Money.Web, :view
  alias Money.User

  def first_name(%User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end
end

