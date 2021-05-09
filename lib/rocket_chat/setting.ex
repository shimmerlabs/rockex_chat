defmodule RocketChat.Setting do
  use RocketChat.Utils

  @doc """
  Returns a list of all the configured private settings.  Takes count, page,
  search options (defaults to 0, which is "all" if configured to allow that).

  API Ref:  https://developer.rocket.chat/api/rest-api/methods/settings/get
  """
  @callback list() :: tuple()
  @callback list(keyword()) :: tuple()
  def list(opts \\ []) do
    %{count: 0}
    |> Map.merge(Map.new(opts))
    |> adapter().get("v1/settings")
  end

  @doc """
  Gets the setting information for the given setting ID.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/settings/get-by-id
  """
  @callback get(String.t()) :: tuple()
  def get(key), do: adapter().get(%{}, "v1/settings/#{key}")

  @doc """
  Sets the given key to the value given.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/settings/update
  """
  @callback set(String.t(), any()) :: tuple()
  def set(key, val), do: adapter().post(%{value: val}, "v1/settings/#{key}")
end
