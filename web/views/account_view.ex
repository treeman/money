defmodule Money.AccountView do
  use Money.Web, :view

  def my_datetime_select(form, field, opts \\ []) do
    builder = fn b ->
      ~e"""
      <%= b.(:day, opts) %> <%= b.(:month, opts) %> <%= b.(:year, opts) %>
      <%= b.(:hour, opts) %> <%= b.(:minute, opts) %>
      """
    end

    datetime_select(form, field, [builder: builder] ++ opts)
  end
end

