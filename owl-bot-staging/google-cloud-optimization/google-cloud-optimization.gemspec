# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/optimization/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-optimization"
  gem.version       = Google::Cloud::Optimization::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Optimization API provides a portfolio of solvers to address common optimization use cases starting with optimal route planning for vehicle fleets."
  gem.summary       = "API Client library for the Cloud Optimization API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-optimization-v1", ">= 0.8", "< 2.a"
end
