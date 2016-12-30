defmodule Money.HtmlParsers do

  def parse_table(html, identifier) do
    # Floki creates [{type, [classes], [subtypes]}]
    table = Floki.find(html, identifier)

    # Create a index->table_head map for use when traversing the table rows.
    headers =
      table
      |> Floki.find(".thead")
      |> Floki.find(".th")
    #IO.inspect(headers)
    # Need to keep nil for empty header stuff in budget
    {_, index2head} =
      headers
      |> Enum.map(fn {_, _, [title]} -> title
                     {_, _, []} -> nil
                  end)
      #|> Enum.filter(&(!is_nil(&1)))
      |> Enum.reduce({0, %{}}, fn(x, {i, map}) -> {i + 1, Map.put(map, i, x)} end)

    # End result is a list where each row is a map with the header title used as keys.
    #
    # [%{"Activity" => 122, "Balance" => 1459, "Budgeted" => 1337,
      # "Category" => "Essentials"},
    # %{"Activity" => 122, "Balance" => 1459, "Budgeted" => 1337,
      # "Category" => "Food"}]
    trs = Floki.find(table, ".tbody") |> Floki.find(".tr")

    Enum.map(trs, fn {_, _, cols} ->
      {_, mapped} = Enum.reduce(cols, {0, %{}}, fn(
        {_, _, [val]}, {i, map}) ->
          head = Map.get(index2head, i)

          if Kernel.is_nil(head) do
            {i + 1, map}
          else
            # Just a convenience conversion.
            val = case Float.parse(val) do
              {v, ""} -> v
              _ -> val
            end

            {i + 1, Map.put(map, head, val)}
          end
        {_, _, _}, {i, map} ->
          {i + 1, map}
      end)

      mapped
    end)
  end
end

