defmodule RocketChat.Config do
  def api_url() do
    Application.get_env(:rockex_chat, :api, api_url: "http://localhost:3000")
    |> Keyword.get(:api_url)
  end

  def user_id() do
    Application.get_env(:rockex_chat, :api, [])
    |> Keyword.get(:user_id)
  end

  def token() do
    Application.get_env(:rockex_chat, :api, [])
    |> Keyword.get(:token)
  end
end
