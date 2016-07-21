defmodule Money.Repo.Migrations.RenameExpenseToTransaction do
  use Ecto.Migration

  def change do
    rename table(:expenses), to: table(:transactions)
  end
end
