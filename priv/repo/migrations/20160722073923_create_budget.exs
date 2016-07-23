defmodule Money.Repo.Migrations.CreateBudgetedCategory do
  use Ecto.Migration

  def change do
    create table(:budgeted_categories) do
      add :amount, :integer, null: false
      add :year, :integer, null: false
      add :month, :integer, null: false
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps()
    end
  end
end

