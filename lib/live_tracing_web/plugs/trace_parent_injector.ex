defmodule LiveTracing.Plugs.TraceParentInjector do
  @moduledoc """
  Plug for injecting trace parent into conn assigns.
  For use in passing trace context to client-side code.
  """

  alias Plug.Conn

  def init(_), do: :ok

  def call(conn, _opts) do
    case :otel_propagator_trace_context.inject(
           :otel_ctx.get_current(),
           %{},
           &carrier_set_fun/3,
           []
         ) do
      %{"traceparent" => traceparent} -> Conn.assign(conn, :traceparent, traceparent)
      _ -> Conn.assign(conn, :traceparent, nil)
    end
  end

  def carrier_set_fun(key, value, carrier), do: Map.put(carrier, key, value)
end
