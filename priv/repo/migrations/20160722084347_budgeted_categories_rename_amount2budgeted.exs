defmodule Money.Repo.Migrations.BudgetedCategoriesRenameAmount2budgeted do
  use Ecto.Migration

  def change do
    rename table(:budgeted_categories), :amount, to: :budgeted
  end
end

