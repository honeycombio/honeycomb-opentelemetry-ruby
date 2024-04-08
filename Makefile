# A Makefile? For a Ruby project?!? What about a Rakefile?
# Yes, a Makefile. We've standardized on Makefiles as a portable way to automate tasks
# across our polyglot projects.

# set shell to bash to make shell builtin behaviour consistent
SHELL := /usr/bin/env bash

#: run the unit tests
test:
	@echo "+++ Running tests"
	bundle exec rake spec

#: run the lint checks
lint:
	@echo "+++ Running the linter"
	bundle exec rubocop --lint

#: run all the lint/format/style checks
style: rubocop
rubocop:
	@echo "+++ Running all style checks"
	bundle exec rubocop

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

JOB ?= test
#: run a CI job in docker locally, set JOB to override default 'run_tests'
local_ci_exec: local_ci_prereqs
	circleci local execute $(JOB) --config .circleci/process.yml

### Utilities

# ^(a_|b_|c_) :: name starts with any of 'a_', 'b_', or 'c_'
# [^=]        :: [^ ] is inverted set, so any character that isn't '='
# +           :: + is 1-or-more of previous thing
#
# So the match the prefixes, then chars up-to-but-excluding the first '='.
#   example: OTEL_VAR=HEY -> OTEL_VAR
#
# egrep to get the extended regex syntax support.
# --only-matching to output only what matches, not the whole line.
OUR_CONFIG_ENV_VARS := $(shell env | egrep --only-matching "^(HONEYCOMB_|OTEL_)[^=]+")

# To use the circleci CLI to run jobs on your laptop.
circle_cli_docs_url = https://circleci.com/docs/local-cli/
local_ci_prereqs: forbidden_in_real_ci circle_cli_available .circleci/process.yml

# the config must be processed to do things like expand matrix jobs.
.circleci/process.yml: circle_cli_available .circleci/config.yml
	circleci config process .circleci/config.yml > .circleci/process.yml

circle_cli_available:
ifneq (, $(shell which circleci))
	@echo "🔎:✅ circleci CLI available"
else
	@echo "🔎:💥 circleci CLI command not available for local run."
	@echo ""
	@echo "   ❓ Is it installed? For more info: ${circle_cli_docs_url}\n\n" && exit 1
endif

forbidden_in_real_ci:
ifeq ($(CIRCLECI),) # if not set, safe to assume not running in CircleCI compute
	@echo "🔎:✅ not running in real CI"
else
	@echo "🔎:🛑 CIRCLECI environment variable is present, a sign that we're running in real CircleCI compute."
	@echo ""
	@echo "   🙈 circleci CLI can't local execute in Circle. That'd be 🍌🍌🍌."
	@echo "" && exit 1
endif
