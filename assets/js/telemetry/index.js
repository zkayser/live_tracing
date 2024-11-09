import { WebTracerProvider, BatchSpanProcessor } from "@opentelemetry/sdk-trace-web";
import { DocumentLoadInstrumentation } from "@opentelemetry/instrumentation-document-load";
import { UserInteractionInstrumentation } from "@opentelemetry/instrumentation-user-interaction";
import { ZoneContextManager } from "@opentelemetry/context-zone";
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-proto";
import { registerInstrumentations } from "@opentelemetry/instrumentation";
import { Resource } from "@opentelemetry/resources";
import { ATTR_SERVICE_NAME } from "@opentelemetry/semantic-conventions";

const collectorOptions = {
    url: 'http://localhost:4318/v1/traces'
};

const onSpanStart = (span) => {
    span.setAttribute('application', 'live_tracing_js');
}

export const initInstrumentations = () => {
    console.log('initializing instrumentations');
    const provider = new WebTracerProvider({ resource: new Resource({ [ATTR_SERVICE_NAME]: 'live_tracing_js' }) });
    const exporter = new OTLPTraceExporter(collectorOptions);
    provider.addSpanProcessor({
        forceFlush: () => Promise.resolve(),
        onEnd: () => { },
        shutdown: () => Promise.resolve(),
        onStart: onSpanStart,
    });
    provider.addSpanProcessor(new BatchSpanProcessor(exporter));

    provider.register({
        contextManager: new ZoneContextManager()
    });

    registerInstrumentations({
        instrumentations: [
            new DocumentLoadInstrumentation(),
            new UserInteractionInstrumentation(),
        ]
    });
}