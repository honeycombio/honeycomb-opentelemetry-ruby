# frozen_string_literal: true

require "sinatra"
require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/sinatra"
require "honeycomb/opentelemetry"

OpenTelemetry::SDK.configure do |c|
  c.service_name = "otel-ruby-example" unless ENV["OTEL_SERVICE_NAME"]
  c.use_all()

  # Add the BaggageSpanProcessor to the collection of span processors
  c.add_span_processor(Honeycomb::OpenTelemetry::Trace::BaggageSpanProcessor.new)

  # Because the span processor list is no longer empty, the SDK will not use
  # the values in OTEL_TRACES_EXPORTER to instantiate exporters. We'll set up our own.
  #
  # Emit traces in batches to an OTLP receiver
  c.add_span_processor(
    # these constructors without arguments will pull config from the environment
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new()
    )
  )
end
at_exit { OpenTelemetry.tracer_provider.shutdown(timeout: 5) }

# a minimally instrumented Sinatra app
class AnApp < Sinatra::Base
  configure do
    set :bind, "0.0.0.0" # for use in docker
  end

  # We'll need a tracer for our custom instrumentation
  Tracer = OpenTelemetry.tracer_provider.tracer("sinatra_tracer", "0.1.0")

  get "/" do
    OpenTelemetry::Trace
      .current_span
      .set_attribute("custom_field", "important value")

    context_for_the_children = OpenTelemetry::Baggage.set_value("for_the_children", "another important value")

    OpenTelemetry::Context.with_current(context_for_the_children) do
      "Hello, World!"
        .tap do |message|
          Tracer.in_span("hello") do |_hello_span|
            Tracer.in_span("world") do |world_span|
              world_span.set_attribute("message", message)
              puts(message)
            end
          end
        end
    end
  end
end

AnApp.run!
