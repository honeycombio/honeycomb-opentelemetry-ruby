# A Makefile? For a Ruby project?!? What about a Rakefile?
# Yes, a Makefile. We've standardized on Makefiles as a portable way to automate tasks
# across our polyglot projects.

# set shell to bash to make shell builtin behaviour consistent
SHELL := /usr/bin/env bash

#: clean up the dev environment
clean: clean-smoke-tests

#: run the smoke tests
smoke: smoke-app smoke-sinatra

#: cleanup the smoke and smoke it again
resmoke: unsmoke smoke

#: run the smoke test for a simple, instrumented Ruby script
smoke-app: smoke-tests/collector/data.json
	@echo ""
	@echo "+++ Running example app smoke tests."
	@echo ""
	cd smoke-tests && bats ./smoke-example-app.bats --report-formatter junit --output ./

#: run the smoke test for a simple, instrumented Ruby script
smoke-sinatra: smoke-tests/collector/data.json
	@echo ""
	@echo "+++ Running example sinatra smoke tests."
	@echo ""
	cd smoke-tests && bats ./smoke-example-app-sinatra.bats --report-formatter junit --output ./

#: clear data from smoke tests
smoke-tests/collector/data.json:
	@echo ""
	@echo "+++ Zhuzhing smoke test's Collector data.json"
	@touch $@ && chmod o+w $@

#: cleans up smoke test output
clean-smoke-tests:
	rm -rf ./smoke-tests/collector/data.json
	rm -rf ./smoke-tests/collector/data-results/*.json
	rm -rf ./smoke-tests/report.*

#: tear down the smoke test environment
unsmoke:
	@echo ""
	@echo "+++ Spinning down the smokers."
	@echo ""
	cd smoke-tests && docker-compose down --volumes
