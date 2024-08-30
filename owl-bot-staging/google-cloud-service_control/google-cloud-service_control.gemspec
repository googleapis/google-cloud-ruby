# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/service_control/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-service_control"
  gem.version       = Google::Cloud::ServiceControl::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Service Control API provides control plane functionality to managed services, such as logging, monitoring, and status checks."
  gem.summary       = "API Client library for the Service Control API API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-service_control-v1", ">= 0.9", "< 2.a"
end
