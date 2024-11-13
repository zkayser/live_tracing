defmodule TracedGenServer do
  defmacro __using__(_opts) do
    quote do
      use GenServer

      @impl GenServer
      def handle_call({:"$__otel_ctx", ctx, original_message}, from, state) do
        :otel_ctx.with_ctx(ctx, fn ->
          handle_call(original_message, from, state)
        end)
        |> case do
          {reply, _ctx} -> reply
          reply -> reply
        end
      end
    end

    @impl GenServer
    def handle_cast({:"$__otel_ctx", ctx, original_message}, state) do
      :otel_ctx.with_ctx(ctx, fn ->
        handle_cast(original_message, state)
      end)
      |> case do
        {reply, _ctx} -> reply
        reply -> reply
      end
    end
  end
end
