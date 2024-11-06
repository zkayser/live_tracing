defmodule LiveTracing.ChannelsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LiveTracing.Channels` context.
  """

  @doc """
  Generate a thread.
  """
  def thread_fixture(attrs \\ %{}) do
    {:ok, thread} =
      attrs
      |> Enum.into(%{

      })
      |> LiveTracing.Channels.create_thread()

    thread
  end
end
