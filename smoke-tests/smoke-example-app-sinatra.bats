#!/usr/bin/env bats

load test_helpers/utilities

CONTAINER_NAME="app-sinatra"
COLLECTOR_NAME="collector"
OTEL_SERVICE_NAME="otel-sinatra-example"
TRACER_NAME="sinatra_tracer"

setup_file() {
	docker-compose up --build --detach collector ${CONTAINER_NAME}
	wait_for_ready_app ${CONTAINER_NAME}
	curl --silent localhost:4567
	wait_for_traces
}

teardown_file() {
 	cp collector/data.json collector/data-results/data-${CONTAINER_NAME}.json
	docker-compose stop ${CONTAINER_NAME}
	docker-compose restart collector # clears/flushes the Collector output file
	wait_for_flush
}

# TESTS

@test "Auto instrumentation produces a Rack span" {
  result=$(span_names_for "OpenTelemetry::Instrumentation::Rack")
  assert_equal "$result" '"GET /"'
}

@test "Manual instrumentation adds custom attribute" {
	result=$(span_attributes_for "OpenTelemetry::Instrumentation::Rack" | jq "select(.key == \"custom_field\").value.stringValue")
	assert_equal "$result" '"important value"'
}

@test "Manual instrumentation produces parent and child spans with names of spans" {
	result=$(span_names_for ${TRACER_NAME})
	assert_equal "$result" '"world"
"hello"'
}
