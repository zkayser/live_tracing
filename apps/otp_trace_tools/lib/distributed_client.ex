defmodule DistributedClient do

  def call(process, original_message, timeout \\ 5000) do
    GenServer.call(process, {:"$__otel_ctx", :otel_ctx.get_current(), original_message}, timeout)
  end

end
