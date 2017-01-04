defmodule Money.LayoutView do
  use Money.Web, :view

  # view specific js module name generation
  # https://blog.diacode.com/page-specific-javascript-in-phoenix-framework-pt-1
  def js_view_name(conn, view_template) do
    [view_name(conn), template_name(view_template)]
    |> Enum.reverse
    |> List.insert_at(0, "view")
    |> Enum.map(&String.capitalize/1)
    |> Enum.reverse
    |> Enum.join("")
  end

  defp view_name(conn) do
    conn
    |> view_module
    |> Phoenix.Naming.resource_name
    |> String.replace("_view", "")
  end

  defp template_name(template) when is_binary(template) do
    template
    |> String.split(".")
    |> Enum.at(0)
  end
end

