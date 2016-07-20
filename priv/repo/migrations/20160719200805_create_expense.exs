defmodule Money.Repo.Migrations.CreateExpense do
  use Ecto.Migration

  def change do
    create table(:expenses) do
      add :amount, :integer, null: false
      add :when, :datetime, null: false
      add :where, :string
      add :category, :string
      add :description, :string
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end
    create index(:expenses, [:account_id])

  end
end
