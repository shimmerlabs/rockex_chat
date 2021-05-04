defmodule RocketChat.Utils do
  @doc """
  Converts the string/atom into a camelCased string.

    iex> RocketChat.Utils.camelcase("foo_bar")
    "fooBar"
  """
  def camelcase(str) when is_binary(str) do
    [first | rest] = String.split(str, ~r/_+/, parts: 2)
    String.downcase(first) <> pascalcase(Enum.at(rest, 0))
  end

  def camelcase(atom) when is_atom(atom), do: camelcase(to_string(atom))
  def camelcase(nil), do: ""

  @doc """
  Converts string/atom into a PascalCase string.

    iex> RocketChat.Utils.pascalcase("foo_bar")
    "FooBar"
  """
  def pascalcase(str) when is_binary(str) do
    String.split(str, ~r/_+/)
    |> Enum.map(&String.capitalize/1)
    |> Enum.join("")
  end

  def pascalcase(atom) when is_atom(atom), do: pascalcase(to_string(atom))
  def pascalcase(nil), do: ""

  @doc """
  Given {:ok, HTTPoisonResponse}, parses the body out from JSON string and
  returns {:ok, payload}.  Any tuple passed in is passed through unchanged.
  """
  def decode_success({:ok, response}) do
    {:ok, Jason.decode!(response.body)}
  end

  def decode_success(not_success), do: not_success

  def query_opts_to_fields(opts), do: query_opts_to_fields(opts, %{})
  def query_opts_to_fields([], acc), do: acc

  def query_opts_to_fields([{key, value} | rest], acc) do
    query_opts_to_fields(rest, Map.put(acc, camelcase(key), value))
  end
end
