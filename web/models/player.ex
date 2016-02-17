defmodule GameService.Player do
  use GameService.Web, :model

  schema "players" do
    field :email, :string
    field :name, :string
    field :social_id, :string

    timestamps
  end

  @required_fields ~w(email name social_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.
  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:social_id)
  end
end