defmodule TracedGenServer do
  defmacro __using__(_opts) do
    quote do
      use GenServer

      def handle_call({:"$__otel_ctx", ctx, original_message}, from, state) do
        :otel_ctx.with_ctx(ctx, fn ->
          handle_call(original_message, from, state)
        end)
      end
    end
  end
end
