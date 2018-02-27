# -*- encoding: utf-8 -*-
require File.expand_path("../lib/google/cloud/logging/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-logging"
  gem.version       = Google::Cloud::Logging::VERSION

  gem.authors       = ["Mike Moore", "Chris Smith"]
  gem.email         = ["mike@blowmage.com", "quartzmo@gmail.com"]
  gem.description   = "google-cloud-logging is the official library for Stackdriver Logging."
  gem.summary       = "API Client library for Stackdriver Logging"
  gem.homepage      = "https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-logging"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.0.0"

  gem.add_dependency "google-cloud-core", "~> 1.2"
  gem.add_dependency "stackdriver-core", "~> 1.3"
  gem.add_dependency "google-gax", "~> 1.0"

  gem.add_development_dependency "minitest", "~> 5.10"
  gem.add_development_dependency "minitest-autotest", "~> 1.0"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "autotest-suffix", "~> 1.1"
  gem.add_development_dependency "rubocop", "~> 0.50.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "yard-doctest", "<= 0.1.8"
  gem.add_development_dependency "railties", "~> 4.0"
  gem.add_development_dependency "rack", ">= 0.1"
end
