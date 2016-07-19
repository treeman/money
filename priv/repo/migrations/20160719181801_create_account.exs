defmodule Money.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :title, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:accounts, [:user_id])

  end
end
