defmodule Money.Repo.Migrations.DecimalPayments do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      modify :amount, :decimal
    end

    alter table(:budgeted_categories) do
      modify :budgeted, :decimal
    end
  end
end

