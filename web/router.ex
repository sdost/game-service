defmodule GameService.Router do
  use GameService.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GameService do
    pipe_through :api

    scope "/v1", V1, as: :v1 do
      post "/player_data", PlayerController, :process_request
    end
  end
end
