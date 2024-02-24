# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/service_usage/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-service_usage"
  gem.version       = Google::Cloud::ServiceUsage::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Service Usage is an infrastructure service of Google Cloud that lets you list and manage other APIs and services in your Cloud projects. You can list and manage Google Cloud services and their APIs, as well as services created using Cloud Endpoints."
  gem.summary       = "API Client library for the Service Usage API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-service_usage-v1", ">= 0.6", "< 2.a"
end
