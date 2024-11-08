defmodule LiveTracingWeb.ThreadLive.Index do
  use LiveTracingWeb, :live_view

  alias LiveTracing.Channels

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :threads, Channels.list_threads())}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    Process.sleep(Enum.random(1..100))
    {:noreply, socket}
  end

  @impl true
  def handle_event("add_message", _, socket) do
    random_id = :rand.uniform(10_000)
    thread_message = %{id: random_id, message: "You added message ID #{random_id}"}

    socket = stream_insert(socket, :threads, thread_message, limit: -10)
    {:noreply, socket}
  end
end
