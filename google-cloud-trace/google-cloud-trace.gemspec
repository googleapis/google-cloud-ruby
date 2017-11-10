# -*- encoding: utf-8 -*-
require File.expand_path("../lib/google/cloud/trace/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-trace"
  gem.version       = Google::Cloud::Trace::VERSION

  gem.authors       = ["Daniel Azuma"]
  gem.email         = ["dazuma@google.com"]
  gem.description   = "google-cloud-trace is the official library for Stackdriver Trace."
  gem.summary       = "Application Instrumentation and API Client library for Stackdriver Trace"
  gem.homepage      = "https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-trace"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.0.0"

  gem.add_dependency "google-cloud-core", "~> 1.0"
  gem.add_dependency "stackdriver-core", "~> 1.2"
  gem.add_dependency "google-gax", "~> 0.9.1"

  gem.add_development_dependency "minitest", "~> 5.10"
  gem.add_development_dependency "minitest-autotest", "~> 1.0"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "autotest-suffix", "~> 1.1"
  gem.add_development_dependency "faraday", "~> 0.8"
  gem.add_development_dependency "railties", "~> 4.0"
  gem.add_development_dependency "rubocop", "<= 0.35.1"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "yard-doctest", "~> 0.1.6"
  gem.add_development_dependency "activerecord", ">= 4.0"
end
