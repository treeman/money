defmodule Money.BudgetedCategoryGroup do
  defstruct category_group_id: nil,
            name: nil,
            budgeted: Decimal.new(0),
            activity: Decimal.new(0),
            budgeted_categories: []
end

