defmodule Money.BudgetedCategoryTest do
  use Money.ModelCase

  alias Money.BudgetedCategory

  test "changeset with valid attributes" do
    assert BudgetedCategory.changeset(%BudgetedCategory{},
                                      %{budgeted: 42, year: 1999, month: 12}).valid?
    assert BudgetedCategory.changeset(%BudgetedCategory{},
                                      %{budgeted: 0, year: 0, month: 1}).valid?
  end

  test "changeset with invalid attributes" do
    refute BudgetedCategory.changeset(%BudgetedCategory{},
                                      %{budgeted: 10, year: 2000, month: 13}).valid?
    refute BudgetedCategory.changeset(%BudgetedCategory{},
                                      %{budgeted: 10, year: -1, month: 4}).valid?
    refute BudgetedCategory.changeset(%BudgetedCategory{},
                                      %{budgeted: 10, year: 2000, month: 0}).valid?
    refute BudgetedCategory.changeset(%BudgetedCategory{},
                                      %{budgeted: -10, year: 0, month: 1}).valid?
  end
end

