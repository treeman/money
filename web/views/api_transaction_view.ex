defmodule Money.ApiTransactionView do
  use Money.Web, :view

  def render("create.json", transaction) do
    %{data: "stuff"}
  end
end

