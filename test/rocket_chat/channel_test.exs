defmodule RocketChat.ChannelTest do
  use ExUnit.Case
  doctest RocketChat.Channel

  import Mox

  setup :verify_on_exit!

  test "mocks" do
    stub(RocketMock.Channel, :create, fn _ -> {:ok, %{}} end)
    verify_on_exit!()

    {:ok, _} = RocketMock.Channel.create("foo")
  end

  test "create" do
    expect(RocketMock.API, :post, fn params, path ->
      assert params == %{"name" => "test", "members" => [], "readOnly" => false}
      assert path == "v1/channels.create"
      {:ok, %{body: Jason.encode!(%{"data" => %{"channel" => "_id"}})}}
    end)

    assert {:ok, _} = RocketChat.Channel.create("test")
  end
end
