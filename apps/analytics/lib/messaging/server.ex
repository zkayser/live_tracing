defmodule Analytics.Messaging.Server do
  require Record
  use TracedGenServer

  require OpenTelemetry.Tracer, as: Tracer

  # Generally don't use the global registry.
  # This is just for demonstration purposes.
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})
  end

  @impl GenServer
  def init(_) do
    {:ok, %{messages_received: 0}}
  end

  @impl GenServer
  def handle_call(:message_received, _from, state) do
    Tracer.with_span "#{inspect(__MODULE__)}.message_received/0",
                     %{attributes: %{:"peer.service" => "analytics"}, kind: :server} do
      new_state = Map.update!(state, :messages_received, &(&1 + 1))
      {:reply, new_state.messages_received, new_state}
    end
  end

  @impl GenServer
  def handle_cast({:message_received, span_ctx}, state) do
    Tracer.with_span(span_ctx, "#{inspect(__MODULE__)}.message_received/0",
                     %{attributes: %{:"peer.service" => "analytics"}, kind: :server}) do
      new_state = Map.update!(state, :messages_received, &(&1 + 1))
      {:noreply, new_state}
    end
  end
end
