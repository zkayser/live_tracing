defmodule LiveTracing.ChannelsTest do
  use LiveTracing.DataCase

  alias LiveTracing.Channels

  describe "threads" do
    alias LiveTracing.Channels.Thread

    import LiveTracing.ChannelsFixtures

    @invalid_attrs %{}

    test "list_threads/0 returns all threads" do
      thread = thread_fixture()
      assert Channels.list_threads() == [thread]
    end

    test "get_thread!/1 returns the thread with given id" do
      thread = thread_fixture()
      assert Channels.get_thread!(thread.id) == thread
    end

    test "create_thread/1 with valid data creates a thread" do
      valid_attrs = %{}

      assert {:ok, %Thread{} = thread} = Channels.create_thread(valid_attrs)
    end

    test "create_thread/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Channels.create_thread(@invalid_attrs)
    end

    test "update_thread/2 with valid data updates the thread" do
      thread = thread_fixture()
      update_attrs = %{}

      assert {:ok, %Thread{} = thread} = Channels.update_thread(thread, update_attrs)
    end

    test "update_thread/2 with invalid data returns error changeset" do
      thread = thread_fixture()
      assert {:error, %Ecto.Changeset{}} = Channels.update_thread(thread, @invalid_attrs)
      assert thread == Channels.get_thread!(thread.id)
    end

    test "delete_thread/1 deletes the thread" do
      thread = thread_fixture()
      assert {:ok, %Thread{}} = Channels.delete_thread(thread)
      assert_raise Ecto.NoResultsError, fn -> Channels.get_thread!(thread.id) end
    end

    test "change_thread/1 returns a thread changeset" do
      thread = thread_fixture()
      assert %Ecto.Changeset{} = Channels.change_thread(thread)
    end
  end
end
