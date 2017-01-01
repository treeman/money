defmodule Money.Repo.Migrations.UserbasedUniqueCategories do
  use Ecto.Migration

  def change do
    create unique_index(:category_groups, [:name, :user_id])
    create unique_index(:categories, [:name, :category_group_id])
  end
end

