defmodule LiveTracingWeb.ThreadLive.Index do
  use LiveTracingWeb, :live_view

  alias LiveTracing.Channels
  alias LiveTracing.Channels.Thread

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :threads, Channels.list_threads())}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    Process.sleep(Enum.random(1..100))
    {:noreply, socket}
  end
end
