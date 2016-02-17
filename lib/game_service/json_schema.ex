defmodule JsonSchema do
  @moduledoc ~S"""
  A service which validates objects according to types defined
  in `schema.json`.
  SRD -> Modified from https://gist.github.com/gamache/e8e24eee5bd3f190de23
  """
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [name: :json_schema])
  end

  @doc ~S"""
  Validates an object by type.  Returns a list of {msg, [columns]} tuples
  describing any validation errors, or [] if validation succeeded.
  """
  def validate(server \\ :json_schema, object, type) do
    GenServer.call(server, {:validate, object, type})
  end

  @doc ~S"""
  Returns true if the object is valid according to the specified type,
  false otherwise.
  """
  def valid?(server \\ :json_schema, object, type) do
    [] == validate(server, object, type)
  end

  @doc ~S"""
  Converts the output of `validate/3` into a JSON-compatible structure,
  a list of error messages.
  """
  def errors_to_json(errors) do
    errors |> Enum.map(fn ({msg, _cols}) -> msg end)
  end

  def init(_) do
    schema = File.read!(Application.app_dir(:game_service) <> "/priv/schema.json")
             |> Poison.decode!
             |> ExJsonSchema.Schema.resolve
    {:ok, schema}
  end

  def handle_call({:validate, object, type}, _from, schema) do
    errors = get_validation_errors(object, type, schema)
    {:reply, errors, schema}
  end

  defp get_validation_errors(object, type, schema) do
    type_string = type |> to_string
    type_schema = schema.schema["definitions"][type_string]

    not_a_struct = case object do
      %{__struct__: _} -> Map.from_struct(object)
      _ -> object
    end

    string_keyed_object = ensure_key_strings(not_a_struct)

    ## validate throws a BadMapError on certain kinds of invalid
    ## input; absorb it (TODO fix ExJsonSchema upstream)
    try do
      ExJsonSchema.Validator.validate(schema, type_schema, string_keyed_object)
    rescue
      _ -> [{"Failed validation", []}]
    end
  end

  @doc ~S"""
  Makes sure that all the keys in the map are strings and not atoms.
  Works on nested data structures.
  """
  defp ensure_key_strings(x) do
    cond do
      is_map x ->
        Enum.reduce x, %{}, fn({k,v}, acc) ->
          Map.put acc, to_string(k), ensure_key_strings(v)
        end
      is_list x ->
        Enum.map(x, fn (v) -> ensure_key_strings(v) end)
      true ->
        x
    end
  end

end