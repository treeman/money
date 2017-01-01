defmodule Money.CategoryGroupView do
  use Money.Web, :view

  def render("index.json", %{category_groups: category_groups}) do
    %{data: render_many(category_groups, Money.CategoryGroupView, "category_group.json")}
  end

  def render("show.json", %{category_group: category_group}) do
    %{data: render_one(category_group, Money.CategoryGroupView, "category_group.json")}
  end

  def render("category_group.json", %{category_group: category_group}) do
    %{id: category_group.id}
  end
end
