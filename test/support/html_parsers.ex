defmodule Money.HtmlParsers do

  def parse_table(html, identifier) do
    # Floki creates [{type, [classes], [subtypes]}]
    table = Floki.find(html, identifier)

    # Create a index->table_head map for use when traversing the table rows.
    headers =
      table
      |> Floki.find("thead")
      |> Floki.find("th")

    {_, index2head} =
      headers
      |> Enum.map(fn {"th", _class, [title]} -> title end)
      |> Enum.reduce({0, %{}}, fn(x, {i, map}) -> {i + 1, Map.put(map, i, x)} end)
    IO.inspect(index2head)

    # End result is a list where each row is a map with the header title used as keys.
    #
    # [%{"Activity" => 122, "Balance" => 1459, "Budgeted" => 1337,
      # "Category" => "Essentials"},
    # %{"Activity" => 122, "Balance" => 1459, "Budgeted" => 1337,
      # "Category" => "Food"}]
    trs = Floki.find(table, "tbody") |> Floki.find("tr")

    rows = Enum.map(trs, fn {"tr", _class, tds} ->
      {_, mapped} = Enum.reduce(tds, {0, %{}}, fn({"td", _class, [val]}, {i, map}) ->
        head = Map.get(index2head, i)

        # Just a convenience conversion.
        # FIXME need to be changed when we allow fraction calculations.
        val = case Integer.parse(val) do
          {int, ""} -> int
          _ -> val
        end

        {i + 1, Map.put(map, head, val)}
      end)

      mapped
    end)
  end
end

