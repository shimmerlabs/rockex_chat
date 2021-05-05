import Config

config :rockex_chat, :api,
  adapter: APIMock,
  api_url: "http://localhost:3000/api",
  user_id: "my_user_id",
  token: "my_token"
