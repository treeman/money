defmodule Money.CategoryGroupView do
  use Money.Web, :view

  def render("index.json", %{category_groups: category_groups}) do
    %{data: render_many(category_groups, Money.CategoryGroupView, "category_group.json")}
  end

  def render("show.json", %{category_group: category_group}) do
    %{data: render_one(category_group, Money.CategoryGroupView, "category_group.json")}
  end

  def render("category_group.json", %{category_group: category_group}) do
    # FIXME this is a bit strange: we're creating the html for a budgeted
    # category group inside the category group view. Done here for simplicity...
    html_row = render_to_string Money.BudgetedCategoryGroupView,
                                    "row.html",
                                    group: %Money.BudgetedCategoryGroup{
                                      category_group_id: category_group.id,
                                      name: category_group.name,
                                    }

    %{id: category_group.id,
      html_row: html_row}
  end
end

