defmodule RocketChat.API do
  alias RocketChat.Config

  @doc """
  Takes the partial path given and prepends the API endpoint to it.  API
  endpoint should be like "http://localhost:3000/api" and then calls need
  only give the remaining path:  "v1/users.create" for example.
  """
  def complete_url(path) do
    "#{String.trim_trailing(Config.api_url(), "/")}/#{String.trim_leading(path, "/")}"
  end

  @doc """
  Given {:ok, HTTPoisonResponse}, parses the body out from JSON string and
  returns {:ok, payload}.  Any tuple passed in is passed through unchanged.
  """
  def decode_success({:ok, response}, true) do
    {:ok, Jason.decode!(response.body)}
  rescue
    Jason.DecodeError ->
      {:error, "JSON Decode Error, got: #{String.slice(response.body, 0, 20)}..."}
  end

  def decode_success(response, _), do: response

  @callback post(map() | String.t(), String.t()) :: tuple()
  @callback post(map() | String.t(), String.t(), keyword()) :: tuple()
  def post(payload, path, opts \\ [])

  def post(%{} = payload, path, opts) do
    payload
    |> Jason.encode!()
    |> post(path, opts)
  end

  def post(payload, path, opts) when is_binary(payload) do
    complete_url(path)
    |> HTTPoison.post(payload, get_headers())
    |> decode_success(Keyword.get(opts, :raw, false) != true)
  end

  @callback get(map(), String.t()) :: tuple()
  @callback get(map(), String.t(), keyword()) :: tuple()
  def get(%{} = payload, path, opts \\ []) do
    complete_url(path)
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(payload))
    |> URI.to_string()
    |> HTTPoison.get(get_headers())
    |> decode_success(Keyword.get(opts, :raw, false) != true)
  end

  def get_headers() do
    [
      {"X-Auth-Token", Config.token()},
      {"X-User-Id", Config.user_id()},
      {"Content-type", "application/json"}
    ]
  end
end
