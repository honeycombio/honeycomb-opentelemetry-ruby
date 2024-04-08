# frozen_string_literal: true

require_relative "lib/honeycomb/opentelemetry/version"

Gem::Specification.new do |spec|
  spec.name          = "honeycomb-opentelemetry"
  spec.version       = Honeycomb::OpenTelemetry::VERSION
  spec.authors       = ["The Honeycomb.io Team"]
  spec.email         = ["support@honeycomb.io"]

  spec.summary       = "Honeycomb's OpenTelemetry Ruby extras"
  spec.homepage      = "https://github.com/honeycombio/honeycomb-opentelemetry-ruby"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/honeycombio/honeycomb-opentelemetry-ruby"
  spec.metadata["bug_tracker_uri"] = "https://github.com/honeycombio/honeycomb-opentelemetry-ruby/issues"
  spec.metadata["changelog_uri"] = "https://github.com/honeycombio/honeycomb-opentelemetry-ruby/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "opentelemetry-api", ">= 1.0.0"
end
