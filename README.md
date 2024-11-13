# LiveTracing

This repo contains examples for distributed tracing on the BEAM in the context of the following scenarios:

1. Server + browser cooperative distributed traces, with examples using LiveView
2. Tracing `gen_*` processes (which may be running on a different Erlang node all together, but not necessarily)

The project is structured as an umbrella app. The examples for scenario 1) are contained within the `apps/live_tracing`
directory. The examples for scenario 2) are spread across the `apps/analytics` and `apps/otp_trace_tools` directories. 

Files containing the notable examples would be:

- apps/live_tracing/lib/telemetry/phoenix.ex
- apps/live_tracing/lib/telemetry/trace_parent_extractor.ex
- apps/live_tracing/lib/live_tracing_web/plugs/trace_parent_injector.ex
- apps/live_tracing/assets/js/telemetry/index.js (For Opentelemetry JS instrumentation setup)
- apps/live_tracing/assets/js/telemetry/phoenixSocket.ts (For barebones Phoenix Socket JS instrumentation)
- apps/otp_trace_tools/lib/distributed_client.ex (GenServer client that injects span context into messages)
- apps/otp_trace_tools/lib/traced_gen_server.ex (A wrapper on GenServers that extracts span context)