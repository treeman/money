defmodule Money.Repo.Migrations.UserCategories do
  use Ecto.Migration

  def change do
    alter table(:category_groups) do
      add :user_id, references(:users)
    end
  end
end

