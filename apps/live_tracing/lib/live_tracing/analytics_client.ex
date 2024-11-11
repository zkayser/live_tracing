defmodule AnalyticsClient do
  @moduledoc """
  Barebones client to call GenServer on other node
  """

  def increment_message do
    current_context = :otel_propagator_text_map.inject([])
    GenServer.call({:global, Analytics.Messaging.Server}, {:message_received, current_context}, 50)
  end
end
