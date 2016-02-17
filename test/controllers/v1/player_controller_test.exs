defmodule GameService.V1.PlayerControllerTest do
  use GameService.ConnCase

  doctest GameService.V1.PlayerController

  @valid_params %{
    player: %{
      name: "Real Name",
      email: "real@email.com",
      social_id: "9999999999999999",
      puzzle_data: %{
        puzzles: [1, 2, 3],
        scores: [500, 500, 500],
        stars: [3, 1, 1]
      },
      friends: []
    }
  }

  @invalid_params %{ player: %{} }


  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "Valid POST /player_data" do
    conn = post conn, v1_player_path(conn, :process_request), @valid_params
    assert json_response(conn, 200) == %{
      "player" => %{
        "social_id" => "9999999999999999",
        "puzzle_data" => %{
          "puzzles" => [1, 2, 3],
          "scores" => [500, 500, 500],
          "stars" => [3, 1, 1]
        },
        "name" => "Real Name",
        "high_scores" => %{
          "scores" => [],
          "puzzles" => [],
          "leaders" => []
        },
        "friends" => [],
        "email" => "real@email.com"
      }
    }
  end

  test "Invalid POST /player_data" do
    conn = post conn, v1_player_path(conn, :process_request), @invalid_params
    assert json_response(conn, 400)
  end
end