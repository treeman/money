defmodule Money.Repo.Migrations.RenameExpenseWhere do
  use Ecto.Migration

  def change do
    rename table(:expenses), :where, to: :payee
  end
end

