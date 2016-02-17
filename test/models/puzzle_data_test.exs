defmodule GameService.PuzzleDataTest do
  use GameService.ModelCase

  alias GameService.PuzzleData

  @valid_attrs %{puzzle: 42, score: 9001, stars: 3, player_id: 0}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PuzzleData.changeset(%PuzzleData{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PuzzleData.changeset(%PuzzleData{}, @invalid_attrs)
    refute changeset.valid?
  end
end