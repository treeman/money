defmodule Money.Repo.Migrations.CreateCategory do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :category_group_id, references(:category_groups, on_delete: :nothing)

      timestamps()
    end

    create index(:categories, [:category_group_id])
    create unique_index(:categories, [:name])
  end
end

