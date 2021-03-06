defmodule RocketChat.User do
  defstruct [
    :email,
    :name,
    :password,
    :username,
    :active,
    :join_default_channels,
    :require_password_change,
    :send_welcome_email,
    :verified,
    roles: [],
    custom_fields: %{}
  ]

  use RocketChat.Utils

  @doc """
  Calls the create user endpoint with the User module struct given.
  Does not pass fields that are nil/empty/blank at all.  Required fields
  are email, name, username, password.  Returns {:ok, HTTPoison.Response}
  on success.

  API Ref:  https://developer.rocket.chat/api/rest-api/methods/users/create
  """
  @callback create(%__MODULE__{}) :: tuple()
  def create(%__MODULE__{} = user) do
    user
    |> Map.from_struct()
    |> Enum.reject(fn
      {_k, v} when is_nil(v) -> true
      {_k, v} when is_list(v) or is_map(v) -> Enum.empty?(v)
      {_k, v} when is_binary(v) -> String.trim(v) == ""
      {_, _} -> false
    end)
    |> Enum.into(%{}, fn {k, v} ->
      {camelcase(k), v}
    end)
    |> adapter().post("v1/users.create")
  end

  @doc """
  Calls the create user token endpoint.  Required keyword option :username
  or :user_id to know what argument to use to pass to the API.

  NOTE:  (from docs) the CREATE_TOKENS_FOR_USERS=true env var must be set.

  API Ref:  https://developer.rocket.chat/api/rest-api/methods/users/createtoken
  """
  @callback create_token(keyword(user_id: String.t()) | keyword(username: String.t())) :: tuple()
  def create_token(id_or_name) when is_list(id_or_name) do
    id_or_name
    |> user_id_or_name()
    |> adapter().post("v1/users.createToken")
  end

  @doc """
  Log the user in to RocketChat.  First arg is username or email, then use
  Keyword list to indicate :password or :resume (which uses a token)

  API Ref: https://developer.rocket.chat/api/rest-api/methods/authentication/login
  """
  @callback login(String.t()) :: tuple()
  @callback login(String.t(), keyword()) :: tuple()
  def login(username, opts \\ []) do
    case Keyword.get(opts, :resume) do
      nil -> %{"user" => username, "password" => Keyword.get(opts, :password)}
      token -> %{"user" => username, "resume" => token}
    end
    |> adapter().post("v1/login")
  end

  @doc """
  Retrieve user record data by username or user_id.

  API Ref: https://developer.rocket.chat/api/rest-api/methods/users/info
  """
  @callback info(keyword(user_id: String.t()) | keyword(username: String.t())) :: tuple()
  def info(id_or_name) when is_list(id_or_name) do
    id_or_name
    |> user_id_or_name()
    |> adapter().get("v1/users.info")
  end

  defp user_id_or_name(opts) do
    case Keyword.get(opts, :user_id) do
      nil -> %{"username" => Keyword.get(opts, :username)}
      id -> %{"userId" => id}
    end
  end
end
