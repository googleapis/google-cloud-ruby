# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/container/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-container"
  gem.version       = Google::Cloud::Container::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Builds and manages container-based applications, powered by the open source Kubernetes technology."
  gem.summary       = "API Client library for the Kubernetes Engine API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-container-v1", ">= 0.33", "< 2.a"
  gem.add_dependency "google-cloud-container-v1beta1", ">= 0.34", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
