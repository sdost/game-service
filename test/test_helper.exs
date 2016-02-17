ExUnit.start

Mix.Task.run "ecto.create", ~w(-r GameService.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r GameService.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(GameService.Repo)

