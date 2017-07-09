defmodule Money.Repo.Migrations.BudgetedCategoryDeleteFromCategory do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE budgeted_categories DROP CONSTRAINT budgeted_categories_category_id_fkey"
    alter table(:budgeted_categories) do
      modify :category_id, references(:categories, on_delete: :delete_all)
    end
  end

  def down do
    execute "ALTER TABLE budgeted_categories DROP CONSTRAINT budgeted_categories_category_id_fkey"
    alter table(:budgeted_categories) do
      modify :category_id, references(:categories)
    end
  end
end
