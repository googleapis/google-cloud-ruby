# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/network_management/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-network_management"
  gem.version       = Google::Cloud::NetworkManagement::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Network Management API provides a collection of network performance monitoring and diagnostic capabilities."
  gem.summary       = "API Client library for the Network Management API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-network_management-v1", ">= 0.10", "< 2.a"
end
