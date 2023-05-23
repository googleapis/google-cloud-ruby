# -*- encoding: utf-8 -*-
require File.expand_path("../lib/google/cloud/trace/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-trace"
  gem.version       = Google::Cloud::Trace::VERSION

  gem.authors       = ["Daniel Azuma"]
  gem.email         = ["dazuma@google.com"]
  gem.description   = "google-cloud-trace is the official library for Stackdriver Trace."
  gem.summary       = "Application Instrumentation and API Client library for Stackdriver Trace"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-trace"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["OVERVIEW.md", "AUTHENTICATION.md", "INSTRUMENTATION.md", "LOGGING.md", "CONTRIBUTING.md", "TROUBLESHOOTING.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "google-cloud-core", "~> 1.5"
  gem.add_dependency "stackdriver-core", "~> 1.3"
  gem.add_dependency "concurrent-ruby", "~> 1.1"
  gem.add_dependency "google-cloud-trace-v1", "~> 0.0"
  gem.add_dependency "google-cloud-trace-v2", "~> 0.0"

  gem.add_development_dependency "google-style", "~> 1.26.1"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-autotest", "~> 1.0"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "autotest-suffix", "~> 1.1"
  gem.add_development_dependency "faraday", "~> 1.3"
  gem.add_development_dependency "railties", "~> 5.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "yard-doctest" #, "~> 0.1.6"
  gem.add_development_dependency "activerecord", "~> 5.0"
end
