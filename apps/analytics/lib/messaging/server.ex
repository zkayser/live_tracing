defmodule Analytics.Messaging.Server do
  require Record
  use GenServer

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
  def handle_call({:message_received, span_ctx}, _from, state) do
    :otel_propagator_text_map.extract(span_ctx)

    Tracer.with_span "#{inspect(__MODULE__)}.message_received/0",
                     %{attrs: %{"peer.service" => "analytics", kind: :server}} do
      new_state = Map.update!(state, :messages_received, &(&1 + 1))
      {:reply, new_state.messages_received, new_state}
    end
  end
end
