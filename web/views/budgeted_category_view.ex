defmodule Money.BudgetedCategoryView do
  use Money.Web, :view

  def render("index.json", %{budgeted_categories: budgeted_categories}) do
    %{data: render_many(budgeted_categories, Money.BudgetedCategoryView, "budgeted_category.json")}
  end

  def render("show.json", %{budgeted_category: budgeted_category}) do
    %{data: render_one(budgeted_category, Money.BudgetedCategoryView, "budgeted_category.json")}
  end

  def render("budgeted_category.json", %{budgeted_category: budgeted_category}) do
    %{id: budgeted_category.id}
  end
end
