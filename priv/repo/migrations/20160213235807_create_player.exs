defmodule GameService.Repo.Migrations.CreatePlayer do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :social_id, :string
      add :email, :string
      add :name, :string

      timestamps
    end

    create unique_index(:players, [:social_id])
  end
end
