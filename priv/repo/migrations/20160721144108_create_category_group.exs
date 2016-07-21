defmodule Money.Repo.Migrations.CreateCategoryGroup do
  use Ecto.Migration

  def change do
    create table(:category_groups) do
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:category_groups, [:name])
  end
end
