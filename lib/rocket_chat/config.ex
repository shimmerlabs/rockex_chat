defmodule RocketChat.Config do
  @app :rockex_chat

  def api_url() do
    Application.get_env(@app, :api, [])
    |> Keyword.get(:api_url, "http://localhost:3000")
  end

  def user_id() do
    Application.get_env(@app, :api, [])
    |> Keyword.get(:user_id)
  end

  def token() do
    Application.get_env(@app, :api, [])
    |> Keyword.get(:token)
  end

  def adapter() do
    Application.get_env(@app, :api, [])
    |> Keyword.get(:adapter, RocketChat.API)
  end
end
