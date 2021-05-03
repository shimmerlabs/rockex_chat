defmodule RocketChat.User do
  defstruct [:email, :name, :password, :username, :active,
             :join_default_channels, :require_password_change,
             :send_welcome_email, :verified, roles: [], custom_fields: %{}]

  import RocketChat.Utils
  alias RocketChat.API

  @doc """
  Calls the create user endpoint with the User module struct given.
  Does not pass fields that are nil/empty/blank at all.  Required fields
  are email, name, username, password.  Returns {:ok, HTTPoison.Response}
  on success.

  API Ref:  https://developer.rocket.chat/api/rest-api/methods/users/create
  """
  def create(%__MODULE__{}=user) do
    user
    |> Map.from_struct()
    |> Enum.reject(fn
      {_k, v} when is_list(v) or is_map(v) -> Enum.empty?(v)
      {_k, v} when is_binary(v) -> String.trim(v) == ""
      {_k, v} -> is_nil(v)
      {_, _} -> false
    end)
    |> Enum.into(%{}, fn {k, v} ->
      {camelcase(k), v}
    end)
    |> API.post("v1/users.create")
  end

  @doc """
  Calls the create user token endpoint.  Required keyword option :username
  or :user_id to know what argument to use to pass to the API.

  NOTE:  (from docs) the CREATE_TOKENS_FOR_USERS=true env var must be set.

  API Ref:  https://developer.rocket.chat/api/rest-api/methods/users/createtoken
  """
  def create_token(opts \\ []) do
    case Keyword.get(opts, :user_id) do
      nil -> %{"username" => Keyword.get(opts, :username)}
      id -> %{"userId" => id}
    end
    |> API.post("v1/users.createToken")
    |> decode_success()
  end

  @doc """
  Log the user in to RocketChat.  First arg is username or email, then use
  Keyword list to indicate :password or :resume (which uses a token)

  API Ref: https://developer.rocket.chat/api/rest-api/methods/authentication/login
  """
  def login(username, opts \\ []) do
    case Keyword.get(opts, :resume) do
      nil -> %{"user" => username, "password" => Keyword.get(opts, :password)}
      token -> %{"user" => username, "resume" => token}
    end
    |> API.post("v1/login")
    |> decode_success()
  end

  defp decode_success({:ok, response}) do
    {:ok, Jason.decode!(response.body)}
  end
  defp decode_success(not_success), do: not_success


end
