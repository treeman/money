defmodule Money.HtmlParsers do

  def parse_grid(html, identifier) do
    # Floki creates [{type, [classes], [subtypes]}]
    grid = Floki.find(html, identifier)

    # Create a index->table_head map for use when traversing the table rows.
    headers =
      grid
      |> Floki.find(".grid-header")
      |> Floki.find(".grid-header-cell")

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
    trs = Floki.find(grid, ".grid-body") |> Floki.find(".grid-row")

    Enum.map(trs, fn {_, _, cols} ->
      cols = cols |> Floki.find(".grid-cell")
      {_, mapped} = Enum.reduce(cols, {0, %{}}, fn
        x, {i, map} ->
          head = Map.get(index2head, i)
          val = cellVal(head, x)

          if Kernel.is_nil(val) do
            {i + 1, map}
          else
            {i + 1, Map.put(map, head, val)}
          end
      end)

      mapped
    end)
  end

  defp cellVal(header, x) when is_binary(header) do
    x
    |> Floki.filter_out(".hidden")
    |> Floki.text
    |> formatText
  end
  defp cellVal(_, _) do
    nil
  end

  # Ignore empty cells, avoids cluttered tests
  defp formatText("") do
    nil
  end
  defp formatText(val) do
    # Just a convenience conversion.
    case Float.parse(val) do
      {v, ""} -> v
      _ -> val
    end
  end
end

