require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'

OpenTelemetry::SDK.configure do |c|
  unless ENV['OTEL_SERVICE_NAME']
    c.service_name = 'otel-ruby-example'
  end
end

# for this simple command-and-exit example, we can safely set an at_exit() hook
# to ensure that spans are flushed through the exporter before the process exits
at_exit { OpenTelemetry.tracer_provider.shutdown(timeout: 5) }

# We'll need a tracer for our custom instrumentation
Tracer = OpenTelemetry.tracer_provider.tracer('hello_world_tracer', '0.1.0')

def hello_world
  "Hello, World!"
    .tap do |message|
      Tracer.in_span('hello') do |span|
        Tracer.in_span('world') do |span|
          span.set_attribute("message", message)
          puts(message)
        end
      end
    end
end

hello_world
