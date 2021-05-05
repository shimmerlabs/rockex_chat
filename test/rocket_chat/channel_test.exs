defmodule RocketChat.ChannelTest do
  use ExUnit.Case
  doctest RocketChat.Channel

  import Mox

  test "mocks" do
    stub(RocketMock.Channel, :create, fn _ -> {:ok, %{}} end)
    verify_on_exit!()

    {:ok, _} = RocketMock.Channel.create("foo")
  end
end
