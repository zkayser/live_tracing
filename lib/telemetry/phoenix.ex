defmodule LiveTracing.Telemetry.Phoenix do
  @moduledoc """
  Modifications on top of OpenTelemetryPhoenix. Expands on LiveView instrumentation in novel ways.
  """
  alias LiveTracing.Telemetry.TraceparentExtractor
  alias OpenTelemetry.SemConv.Incubating.URLAttributes
  alias OpenTelemetry.Tracer
  alias Phoenix.LiveView

  require OpenTelemetry.Tracer

  @tracer_id __MODULE__

  @typedoc "Setup options"
  @type opts :: [endpoint_prefix() | adapter()]

  @typedoc "The endpoint prefix in your endpoint. Defaults to `[:phoenix, :endpoint]`"
  @type endpoint_prefix :: {:endpoint_prefix, [atom()]}

  @typedoc "The phoenix server adapter being used. Required"
  @type adapter :: {:adapter, :cowboy2 | :bandit}

  @doc """
  Initializes and configures the telemetry handlers.
  """
  @spec setup(opts()) :: :ok
  def setup(opts \\ []) do
    opts = if !opts[:endpoint_prefix], do: Keyword.put(opts, :endpoint_prefix, [:phoenix, :endpoint]), else: opts
    attach_endpoint_start_handler(opts)
    attach_router_start_handler(opts)
    attach_liveview_handlers()

    :ok
  end

  @doc false
  def attach_endpoint_start_handler(opts) do
    :telemetry.attach(
      {__MODULE__, :endpoint_start},
      opts[:endpoint_prefix] ++ [:start],
      &__MODULE__.handle_endpoint_start/4,
      %{adapter: opts[:adapter]}
    )
  end

  @doc false
  def attach_router_start_handler(_opts) do
    :telemetry.attach(
      {__MODULE__, :router_dispatch_start},
      [:phoenix, :router_dispatch, :start],
      &__MODULE__.handle_router_dispatch_start/4,
      %{}
    )
  end

  def attach_liveview_handlers do
    :telemetry.attach_many(
      {__MODULE__, :live_view},
      [
        [:phoenix, :live_view, :mount, :start],
        [:phoenix, :live_view, :mount, :stop],
        [:phoenix, :live_view, :mount, :exception],
        [:phoenix, :live_view, :handle_params, :start],
        [:phoenix, :live_view, :handle_params, :stop],
        [:phoenix, :live_view, :handle_params, :exception],
        [:phoenix, :live_view, :handle_event, :start],
        [:phoenix, :live_view, :handle_event, :stop],
        [:phoenix, :live_view, :handle_event, :exception],
        [:phoenix, :live_component, :handle_event, :start],
        [:phoenix, :live_component, :handle_event, :stop],
        [:phoenix, :live_component, :handle_event, :exception]
      ],
      &__MODULE__.handle_liveview_event/4,
      %{}
    )

    :ok
  end

  # TODO: do we still need exception handling? Only when cowboy?

  @doc false
  def handle_endpoint_start(_event, _measurements, _meta, %{adapter: :bandit}), do: :ok

  def handle_endpoint_start(_event, _measurements, _meta, %{adapter: :cowboy2}) do
    cowboy2_start()
  end

  defp cowboy2_start do
    OpentelemetryProcessPropagator.fetch_parent_ctx()
    |> OpenTelemetry.Ctx.attach()
  end

  @doc false
  def handle_router_dispatch_start(_event, _measurements, meta, _config) do
    attributes = %{
      :"phoenix.plug" => meta.plug,
      :"phoenix.action" => meta.plug_opts,
      URLAttributes.url_template() => meta.route
    }

    Tracer.update_name("#{meta.conn.method} #{meta.route}")
    Tracer.set_attributes(attributes)
  end

  def handle_liveview_event(
        [:phoenix, _live, :mount, :start],
        _measurements,
        %{socket: %{view: live_view} = socket} = meta,
        _handler_configuration
      ) do
    if LiveView.connected?(socket) do
      socket
      |> LiveView.get_connect_params()
      |> TraceparentExtractor.extract()
    end

    OpentelemetryTelemetry.start_telemetry_span(
      @tracer_id,
      "#{inspect(live_view)}.mount",
      meta,
      %{kind: :server}
    )
  end

  def handle_liveview_event(
        [:phoenix, _live, :handle_params, :start],
        _measurements,
        %{socket: %{view: live_view}} = meta,
        _handler_configuration
      ) do
    OpentelemetryTelemetry.start_telemetry_span(
      @tracer_id,
      "#{inspect(live_view)}.handle_params",
      meta,
      %{kind: :server}
    )
  end

  def handle_liveview_event(
        [:phoenix, _live, :handle_event, :start],
        _measurements,
        %{socket: %{view: live_view}, event: event} = meta,
        _handler_configuration
      ) do
    OpentelemetryTelemetry.start_telemetry_span(
      @tracer_id,
      "#{inspect(live_view)}.handle_event##{event}",
      meta,
      %{kind: :server}
    )
  end

  def handle_liveview_event(
        [:phoenix, _live, _event, :stop],
        _measurements,
        meta,
        _handler_configuration
      ) do
    OpentelemetryTelemetry.end_telemetry_span(@tracer_id, meta)
    end_originating_span()
  end

  def handle_liveview_event(
        [:phoenix, _live, _action, :exception],
        _,
        %{kind: kind, reason: reason, stacktrace: stacktrace} = meta,
        _
      ) do
    ctx = OpentelemetryTelemetry.set_current_telemetry_span(@tracer_id, meta)

    exception = Exception.normalize(kind, reason, stacktrace)

    OpenTelemetry.Span.record_exception(ctx, exception, stacktrace, [])
    OpenTelemetry.Span.set_status(ctx, OpenTelemetry.status(:error, ""))
    OpentelemetryTelemetry.end_telemetry_span(@tracer_id, meta)
    end_originating_span()
  end

  defp end_originating_span do
    case Tracer.current_span_ctx() do
      :undefined -> :ok
      token ->
        Tracer.end_span()
        :otel_ctx.detach(token)
    end
  end
end
