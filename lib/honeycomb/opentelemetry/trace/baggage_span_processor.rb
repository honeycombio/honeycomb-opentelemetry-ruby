require "opentelemetry" # API for Baggage access

module Honeycomb
  module OpenTelemetry
    module Trace
      class BaggageSpanProcessor
        # Called when a {Span} is started, if the {Span#recording?}
        # returns true.
        #
        # This method is called synchronously on the execution thread, should
        # not throw or block the execution thread.
        #
        # @param [Span] span the {Span} that just started, expected to conform
        #  to the concrete {Span} interface from the SDK and respond to :add_attributes.
        # @param [Context] parent_context the parent {Context} of the newly
        #  started span.
        def on_start(span, parent_context)
          span.add_attributes(::OpenTelemetry::Baggage.values(context: parent_context))
        end


        # NO-OP method to satisfy the SpanProcessor duck type.
        #
        # @param [Span] span the {Span} that just ended.
        def on_finish(span); end

        # Export all ended spans to the configured `Exporter` that have not yet
        # been exported.
        #
        # @param [optional Numeric] timeout An optional timeout in seconds.
        # @return [Integer] 0 for success and there is nothing to flush so always successful.
        def force_flush(timeout: nil)
          0
        end

        # Called when {TracerProvider#shutdown} is called.
        #
        # @param [optional Numeric] timeout An optional timeout in seconds.
        # @return [Integer] 0 for success and there is nothing to stop so always successful.
        def shutdown(timeout: nil)
          0
        end
      end
    end
  end
end
