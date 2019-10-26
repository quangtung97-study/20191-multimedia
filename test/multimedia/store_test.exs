defmodule Multimedia.StoreTest do
  use ExUnit.Case

  alias Multimedia.Store

  test "cleanup pids" do
    Store.start_link()
    Store.register(self(), 12, 33)

    pid1 = self()

    task =
      Task.async(fn ->
        pid2 = self()
        Store.register(pid2, 22, 44)
      end)

    Task.await(task)

    assert Store.all_pids() == [{pid1, {12, 33}}]
  end

  test "join group" do
    Store.start_link()
    Store.register(self(), 12, 33)
    assert Store.join(12, 33, 101) == {:ok, [12]}

    task =
      Task.async(fn ->
        Store.register(self(), 22, 44)
        assert Store.join(22, 44, 101) == {:ok, [12, 22]}
      end)

    Task.await(task)

    assert Store.group_sessons(101) == [12]

    assert Store.join(12, 33, 101) == {:error, :already_joined}
  end
end
