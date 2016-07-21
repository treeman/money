defmodule Money.Repo.Migrations.AssociateTransactionsAndCategories do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :category_id, references(:categories, on_delete: :nothing)
    end

    create index(:transactions, [:category_id])
  end
end

