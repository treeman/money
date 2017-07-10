defmodule Money.Repo.Migrations.BudgetedCategoryUniqueConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:budgeted_categories, [:year, :month, :category_id])
  end
end
