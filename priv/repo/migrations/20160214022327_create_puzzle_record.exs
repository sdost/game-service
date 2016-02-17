defmodule GameService.Repo.Migrations.CreatePuzzleData do
  use Ecto.Migration

  def change do
    create table(:puzzle_data) do
      add :player_id, references(:players)
      add :puzzle, :integer
      add :score, :integer
      add :stars, :integer

      timestamps
    end
  end
end
