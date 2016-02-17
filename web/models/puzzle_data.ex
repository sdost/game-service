defmodule GameService.PuzzleData do
  use GameService.Web, :model

  schema "puzzle_data" do
    field :puzzle, :integer
    field :score, :integer
    field :stars, :integer

    belongs_to :player, GameService.Player

    timestamps
  end

  def for_social_ids(query, social_ids) do
    from d in query,
        join: p in assoc(d, :player),
       where: p.social_id in ^social_ids,
    group_by: [p.social_id, d.puzzle],
      select: {p.social_id, d.puzzle, max(d.score), max(d.stars)}
  end

  @required_fields ~w(puzzle score stars player_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.
  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:social_id)
  end
end