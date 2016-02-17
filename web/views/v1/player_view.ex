defmodule GameService.V1.PlayerView do
  use GameService.Web, :view

  def render("player.json", %{player: player, puzzle_data: puzzle_data, friend_data: friend_data, high_scores: high_scores}) do
    %{
      player: %{
        social_id: player.social_id,
        name: player.name,
        email: player.email,
        puzzle_data: puzzle_data,
        friends: friend_data,
        high_scores: high_scores
      }
    }
  end
end