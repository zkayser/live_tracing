defmodule LiveTracing.Telemetry.TraceparentExtractor do
  @moduledoc """
  This module provides functions for transparently pulling traceparent
  context out of a map safely, and setting traceparent context as the
  current Opentelemetry context.
  """

  def extract(carrier) when is_map(carrier) and is_map_key(carrier, "traceparent") do
    :otel_ctx.get_current()
    |> :otel_propagator_trace_context.extract(
      Map.put_new(carrier, "tracestate", ""),
      &Function.identity/1,
      fn key, carrier -> Map.get(carrier, key) end,
      []
    )
    |> :otel_ctx.attach()
  end

  def extract(_), do: :ok
end
