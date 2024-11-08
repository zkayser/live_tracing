defmodule LiveTracingWeb.Live.Hooks.SpanContextInjection do
  @moduledoc """
  This module provides on on_mount/4 callback that will set
  an `$__otel_original_span_ctx` assign in a LiveView
  module's assigns, if there is an original span context to set.
  Otherwise, the on_mount/4 callback is effectively a no-op.

  The `$__otel_original_span_ctx` is the span context from
  the initial HTTP request (dead render) that loaded the LiveView
  initially. The assign is intended to be used specifically for
  tracing purposes by LiveView instrumentation code, where it will
  be used to associate things like `c:handle_event/3` and `c:handle_params/3`
  callback traces to the originating request.
  """
  require Record

  import Phoenix.Component, only: [assign: 3]

  def on_mount(_, _params, _session, socket) do
    case :otel_ctx.get_current() do
      span_ctx when Record.is_record(span_ctx, :span_ctx) ->
        {:cont, assign(socket, :"$__otel_original_span_ctx", span_ctx)}
      _ -> {:cont, socket}
    end
  end
end
