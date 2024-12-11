# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/container_analysis/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-container_analysis"
  gem.version       = Google::Cloud::ContainerAnalysis::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Container Analysis API is an implementation of Grafeas. It stores, and enables querying and retrieval of, critical metadata about all of your software artifacts."
  gem.summary       = "API Client library for the Container Analysis API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-container_analysis-v1", ">= 0.9", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
