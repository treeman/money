defmodule Money.Import.Swedbank do
  alias Money.Transaction
  require Logger

  def parse_transactions(data) do
    String.split(data, "\n")
    |> Enum.reduce([], fn x, acc ->
         case line_transaction(x) do
           {:ok, t} -> [t | acc]
           {:error, reason} -> 
           Logger.debug "Warning: #{reason} on '#{x}'"
           acc
         end
    end)
  end

  def line_transaction(line) do
    with [_, date, descr, amount, _] <- split(line),
         {:ok, date} <- to_date(date),
         {:ok, amount} <- to_num(amount) do
      {:ok, %Transaction{}
            |> Transaction.changeset(%{when: date,
                                       description: descr,
                                       amount: amount})}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "mismatch"}
    end
  end

  def split(line) do
    String.split(line, "\t")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn x -> x != "" end)
  end

  def to_date(x) do
    with [y, m, d] <- Regex.run(~r/^(\d{2,4})-(\d{2})-(\d{2})$/, x,
                                capture: :all_but_first),
         {:ok, dt} <- Ecto.DateTime.cast({{guess_year(y), m, d}, {0, 0, 0}}) do
      {:ok, dt}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "unknown date"}
    end
  end

  def guess_year(y) when is_binary(y) do
    if String.length(y) == 4 do
      y
    else
      curr = DateTime.utc_now.year
             |> Integer.to_string
             |> String.slice(2..3)
      if y > curr do "19" <> y else "20" <> y end
    end
  end

  def to_num(x) do
    x = x
        |> String.replace(" ", "")
        |> String.replace(",", ".")
    case Float.parse(x) do
      {n, rest} ->
        if rest != "", do: Logger.warn("unhandled rest: '#{rest}'")
        {:ok, Decimal.new(n)}
      _ -> {:error, "bad num: '#{x}'"}
    end
  end
end

