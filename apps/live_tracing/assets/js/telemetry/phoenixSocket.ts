import { propagation, ROOT_CONTEXT, trace, SpanKind, Span, SpanStatus, SpanStatusCode } from "@opentelemetry/api"
import {
  InstrumentationBase,
  InstrumentationConfig,
} from '@opentelemetry/instrumentation';
import { Socket } from "phoenix";

type MessageRef = string;
export class PhoenixSocketInstrumentation extends InstrumentationBase<InstrumentationConfig> {
  private _socketMem = new WeakMap<any, Span>();
  private _messageMem = new Map<MessageRef, Span>();

  constructor(config: InstrumentationConfig = {}) {
    super('PhoenixSocketInstrumentation', '0.0.1', config);
  }

  private _patchConnect() {
    return (original) => {
      const plugin = this;
      const traceparent = plugin.getTraceParent();
      return function patchConnect(this, ...args) {
        const ctx = propagation.extract(ROOT_CONTEXT, { traceparent })

        const span = plugin.tracer.startSpan('phoenix.socket.connect', { kind: SpanKind.CLIENT }, ctx);

        plugin._socketMem.set(this, span);
        return original.apply(this, args);
      }
    }
  }

  private _patchOnOpen() {
    return (original) => {
      const plugin = this;
      return function patchOnOpen(this, ...args) {
        const span = plugin._socketMem.get(this);
        plugin._socketMem.delete(this);
        span?.addEvent('socket.connection.opened')
        if (span) { span.end() }

        return original.apply(this, args);
      }
    }
  }

  private _patchPush() {
    return (original) => {
      const plugin = this;
      const traceparent = plugin.getTraceParent();
      return function patchPush(this, ...args) {
        const ctx = propagation.extract(ROOT_CONTEXT, { traceparent })

        const data = args[0]
        const ref = data?.ref || "0"
        const payload = data?.payload
        const eventType = payload?.event || data?.event || "socket_event"
        // Do not create spans for heartbeat messages;
        if (eventType !== "heartbeat") {
          const span = plugin.tracer.startSpan(`phoenix.socket.push:${eventType}`, { kind: SpanKind.CLIENT }, ctx);

          plugin._messageMem.set(ref, span)
        }
        return original.apply(this, args);
      }
    }
  }

  private _patchOnConnMessage() {
    return (original) => {
      const plugin = this;
      return function patchOnConnMessage(this, ...args) {
        const rawData = args[0].data;
        return this.decode(rawData, (msg) => {
          const span = plugin._messageMem.get(msg?.ref);
          if (span) {
            const result = original.apply(this, args);
            span.end();
            return result
          } else {
            return original.apply(this, args)
          }
        });
      }
    }
  }

  private getTraceParent() {
    const tag = document.querySelector("meta[name='traceparent']")
    return tag?.getAttribute('content') || '';
  }

  public init() { }

  public enable() {
    this._wrap(Socket.prototype, 'connect', this._patchConnect());
    this._wrap(Socket.prototype, 'onOpen', this._patchOnOpen());
    this._wrap(Socket.prototype, 'push', this._patchPush());
    this._wrap(Socket.prototype, 'onConnMessage', this._patchOnConnMessage());
  }

  public disable() {
    this._unwrap(Socket.prototype, 'connect');
    this._unwrap(Socket.prototype, 'onOpen');
    this._unwrap(Socket.prototype, 'push');
    this._unwrap(Socket.prototype, 'onConnMessage')
  }
}