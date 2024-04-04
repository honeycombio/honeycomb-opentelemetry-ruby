#!/usr/bin/env bats

load test_helpers/utilities

CONTAINER_NAME="app"
COLLECTOR_NAME="collector"
OTEL_SERVICE_NAME="otel-ruby-example"
TRACER_NAME="hello_world_tracer"

setup_file() {
	echo "# 🚧" >&3
	docker-compose up --build --detach collector
	wait_for_ready_collector ${COLLECTOR_NAME}
	docker-compose up --build --detach ${CONTAINER_NAME}
	wait_for_traces
}

teardown_file() {
	cp collector/data.json collector/data-results/data-${CONTAINER_NAME}.json
	docker-compose stop ${CONTAINER_NAME}
	docker-compose restart collector
	wait_for_flush
}

# TESTS

@test "Manual instrumentation produces parent and child spans with names of spans" {
	result=$(span_names_for ${TRACER_NAME})
	assert_equal "$result" '"world"
"hello"'
}

@test "Manual instrumentation adds custom attribute" {
	result=$(span_attributes_for "${TRACER_NAME}" | jq "select(.key == \"message\").value.stringValue")
	assert_equal "$result" '"Hello, World!"'
}
