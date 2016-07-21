defmodule Money.ViewHelpers do
  use Phoenix.HTML

  @doc """
  Create a link and tag it with "active" if it's pointing to
  the currently active path.
  """
  def active_link(conn, text, opts) do
    path = opts[:to]
    class = [opts[:class], active_class(conn, path)]
            |> Enum.filter(& &1)
            |> Enum.join(" ")
    opts = opts
           |> Keyword.put(:class, class)
           |> Keyword.put(:to, path)
    link text, opts
  end

  @doc """
  Return "active" if it's the currently active path.
  """
  def active_class(conn, path) do
    current_path = Path.join(["/" | conn.path_info])
    if path == current_path do
      "active"
    else
      nil
    end
  end
end

