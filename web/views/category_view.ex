defmodule Money.CategoryView do
  use Money.Web, :view

  def render("index.json", %{categories: categories}) do
    %{data: render_many(categories, Money.CategoryView, "category.json")}
  end

  def render("show.json", %{category: category}) do
    %{data: render_one(category, Money.CategoryView, "category.json")}
  end

  def render("category.json", %{category: category}) do
    %{id: category.id}
  end

  def render("delete.json", %{groups: groups, categories: categories}) do
    %{data: %{groups: groups, categories: categories}}
  end
end
