defmodule Money.Repo.Migrations.CategoryDeleteFromGroup do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE categories DROP CONSTRAINT categories_category_group_id_fkey"
    alter table(:categories) do
      modify :category_group_id, references(:category_groups, on_delete: :delete_all)
    end
  end

  def down do
    execute "ALTER TABLE categories DROP CONSTRAINT categories_category_group_id_fkey"
    alter table(:categories) do
      modify :category_group_id, references(:category_groups)
    end
  end
end

