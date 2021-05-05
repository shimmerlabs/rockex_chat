defmodule RocketChat.API do
  alias RocketChat.Config

  def complete_url(path) do
    "#{String.trim_trailing(Config.api_url(), "/")}/#{String.trim_leading(path, "/")}"
  end

  @callback post(map(), String.t()) :: tuple()
  def post(%{} = payload, path) do
    payload
    |> Jason.encode!()
    |> post(path)
  end

  @callback post(String.t(), String.t()) :: tuple()
  def post(payload, path) when is_binary(payload) do
    complete_url(path)
    |> HTTPoison.post(payload, get_headers())
  end

  @callback get(map(), String.t()) :: tuple()
  def get(%{} = payload \\ %{}, path) do
    complete_url(path)
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(payload))
    |> URI.to_string()
    |> HTTPoison.get(get_headers())
  end

  def get_headers() do
    [
      {"X-Auth-Token", Config.token()},
      {"X-User-Id", Config.user_id()},
      {"Content-type", "application/json"}
    ]
  end
end
