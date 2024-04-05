# hello-world

This simple Ruby app returns "Hello World".
It is a minimal app instrumented directly with the OpenTelemetry Ruby SDK.

## Prerequisites

You'll also need ...

## Running the example

Install the dependencies:

```bash
bundle install
```

Run the application with an exporter configured to display traces on stdout:

```bash
OTEL_TRACES_EXPORTER=console ruby ./app.rb
```
