defmodule GameService.PlayerTest do
  use GameService.ModelCase

  alias GameService.Player

  @valid_attrs %{email: "email@example.com", name: "player name", social_id: "85938593029289503938592"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Player.changeset(%Player{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Player.changeset(%Player{}, @invalid_attrs)
    refute changeset.valid?
  end
end