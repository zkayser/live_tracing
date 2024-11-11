defmodule DistributedClient do
  def call(process, message, timeout \\ 5000) do
    GenServer.call(process, {:"$__otel_ctx", OpenTelemetry.Ctx.get_current(), message})
  end
end
