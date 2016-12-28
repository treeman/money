defmodule Money.ViewHelpers do
  use Phoenix.HTML

  @doc """
  Create a link and tag it with "active" if it's pointing to
  the currently active path.
  """
  def active_link(conn, text, opts) do
    active_link_if(conn, &(&1 == opts[:to]), text, opts)
  end

  @doc """
  Create a link and tag it with "active" if it's starting with `prefix`.
  """
  def active_link_starts_with(conn, prefix, text, opts) do
    active_link_if(conn, &(String.starts_with?(&1, prefix)), text, opts)
  end

  @doc """
  Create a link and tag it with "active" if `f` returns true.
  """
  def active_link_if(conn, f, text, opts) do
    path = opts[:to]
    class = [opts[:class], active_class_if(conn, f)]
            |> Enum.filter(& &1)
            |> Enum.join(" ")
    opts = opts
           |> Keyword.put(:class, class)
           |> Keyword.put(:to, path)
    link text, opts
  end

  def active_class_if(conn, f) do
    current_path = Path.join(["/" | conn.path_info])
    if f.(current_path) do "active" else nil end
  end

  def awesomplete(form, field, options, opts \\ []) do
    id = field_id(form, field)
    list_id = id <> "-list"
    opts = Keyword.merge(opts, [id: id,
                                name: field_name(form, field),
                                class: "awesomplete",
                                list: list_id])

    options = Enum.map(options, fn {name, _value} ->
      #content_tag(:option, name, [value: value])
      content_tag(:option, name)
    end)

    [tag(:input, opts), content_tag(:datalist, options, [id: list_id])]
  end

  def date_input(form, field, opts \\ []) do
    opts = Keyword.merge(opts, [id: field_id(form, field),
                                name: field_name(form, field),
                                type: "text"])
    tag(:input, opts)
  end
end

