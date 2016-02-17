defmodule GameService.V1.PlayerController do
  require Logger

  use GameService.Web, :controller
  alias GameService.Player
  alias GameService.PuzzleData

  plug :validate_params

  @doc ~S"""
  Request handler for the game service endpoint.

  Handles validation, player upsert, saving new puzzle state,
  gathering friend data, and formatting the output.
  """
  def process_request(conn, _params) do
    player_params = conn.assigns[:player_request]["player"]

    player =
      case Repo.get_by(Player, social_id: player_params["social_id"]) do
        nil -> %Player{}
        player -> player
      end

    changeset = Player.changeset(player, player_params)

    if changeset.valid? do
      {:ok, player} = Repo.insert_or_update(changeset)
    else
      send_400_error(conn, changeset.errors)
    end

    save_puzzle_data(player, player_params["puzzle_data"])

    raw_puzzle_data = get_puzzle_data( [player.social_id | player_params["friends"]] )

    puzzle_data = raw_puzzle_data
    |> Enum.group_by(fn {social_id, _, _, _} -> social_id end)
    |> Enum.map(fn {key, value} -> {key, value |> format_puzzle_data} end)
    |> Enum.into(%{})

    friend_data = puzzle_data
    |> Enum.filter(fn {social_id, _} -> social_id != player.social_id end)
    |> Enum.map(fn {social_id, puzzle_data} -> %{social_id: social_id, puzzle_data: puzzle_data} end)

    high_scores = raw_puzzle_data
    |> Enum.filter(fn {social_id, _, _, _} -> social_id != player.social_id end)
    |> Enum.group_by(fn {_, puzzle, _, _} -> puzzle end)
    |> Enum.map(fn {_, value} -> Enum.max_by(value, fn {_, _, score, _} -> score end) end)
    |> format_high_scores

    render conn, "player.json",
           player: player,
      puzzle_data: puzzle_data[player.social_id],
      friend_data: friend_data,
      high_scores: high_scores
  end

  @doc ~S"""
  Validate the incoming JSON params against the expected JSON Schema.
  """
  defp validate_params(conn, _params) do
    case JsonSchema.validate(conn.params, :player_request) do
      [] ->
        conn |> assign(:player_request, conn.params)
      errors ->
        json_errors = errors |> JsonSchema.errors_to_json
        send_400_error(conn, json_errors)
    end
  end

  @doc ~S"""
  Helper for returning a 400 error.
  """
  defp send_400_error(conn, error) do
    conn |> put_status(:bad_request) |> json(%{error: error}) |> halt
  end

  @doc ~S"""
  Save the new puzzle data to the DB
  """
  defp save_puzzle_data(player, puzzle_data) do
    puzzle_data
    |> Map.take(["puzzles", "scores", "stars"]) |> Map.values |> List.zip
    |> Enum.map(fn {puzzle, score, stars} -> %{puzzle: puzzle, score: score, stars: stars, player_id: player.id} end)
    |> Enum.each(fn m -> PuzzleData.changeset(%PuzzleData{}, m) |> Repo.insert end)
  end

  @doc ~S"""
  Request puzzle data for all included Social IDs as one SQL Query.
  """
  defp get_puzzle_data(social_ids) do
    PuzzleData
    |> PuzzleData.for_social_ids(social_ids)
    |> Repo.all
  end

  @doc ~S"""
  Convert the raw tuple from the DB results into our expected output for the "puzzle_data" field.

  ## Example

      iex> GameService.V1.PlayerController.format_puzzle_data([{"9999999999999", 1, 4000, 3}, {"9999999999999", 2, 5000, 2}])
      %{"puzzles" => [1, 2], "scores" => [4000, 5000], "stars" => [3, 2]}

  """
  def format_puzzle_data(puzzle_data) do
    puzzle_data
    |> Enum.map(fn {_, puzzle, score, stars} -> {puzzle, score, stars} end)
    |> Enum.sort_by(fn {puzzle, _, _} -> puzzle end)
    |> :lists.unzip3
    |> Tuple.to_list
    |> (&Enum.zip(["puzzles", "scores", "stars"], &1)).()
    |> Enum.into(%{})
  end

  @doc ~S"""
  Convert the raw tuple from the DB results into our expected output for the "high_scores" field.

  ## Example

      iex> GameService.V1.PlayerController.format_high_scores([{"9999999999999", 1, 4000, 3}, {"777777777777", 2, 5000, 2}])
      %{"puzzles" => [1, 2], "scores" => [4000, 5000], "leaders" => ["9999999999999", "777777777777"]}

  """
  def format_high_scores(high_score_data) do
    high_score_data
    |> Enum.map(fn {social_id, puzzle, score, _} -> {puzzle, score, social_id} end)
    |> :lists.unzip3
    |> Tuple.to_list
    |> (&Enum.zip(["puzzles", "scores", "leaders"], &1)).()
    |> Enum.into(%{})
  end
end