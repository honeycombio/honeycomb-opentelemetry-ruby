# Sinatra

This simple Ruby Sinatra app that returns "Hello World".
It is a minimal web app instrumented directly with the OpenTelemetry Ruby SDK and with OpenTelemetry libraries for Rack and Sinatra.

## Prerequisites

You'll also need ...

## Running the example

Install the dependencies:

```bash
bundle install
```

Run the application (will export spans to an OTLP receiver at localhost:4318):

```bash
bundle exec ruby ./app.rb
```
