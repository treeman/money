defmodule Money.Repo.Migrations.DropCategories do
  use Ecto.Migration

  def up do
    alter table(:transactions) do
      remove :category
    end
  end

  def down do
    alter table(:transactions) do
      add :category, :string
    end
  end
end

