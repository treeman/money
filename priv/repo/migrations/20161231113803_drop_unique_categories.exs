defmodule Money.Repo.Migrations.DropUniqueCategories do
  use Ecto.Migration

  def change do
    drop unique_index(:category_groups, [:name])
    drop unique_index(:categories, [:name])
  end
end
