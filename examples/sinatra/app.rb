require 'sinatra'
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/instrumentation/sinatra'

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'otel-ruby-example' unless ENV['OTEL_SERVICE_NAME']
  c.use_all()
end
at_exit { OpenTelemetry.tracer_provider.shutdown(timeout: 5) }

class AnApp < Sinatra::Base
  configure do
    set :bind, '0.0.0.0' # for use in docker
  end

  # We'll need a tracer for our custom instrumentation
  Tracer = OpenTelemetry.tracer_provider.tracer('sinatra_tracer', '0.1.0')

  get '/' do
    OpenTelemetry::Trace
      .current_span
      .set_attribute("custom_field", "important value")

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
end

AnApp.run!
