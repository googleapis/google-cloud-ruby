# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/memorystore/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-memorystore"
  gem.version       = Google::Cloud::Memorystore::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Memorystore for Valkey is a fully managed Valkey service for Google Cloud which supports both Cluster Mode Enabled and Cluster Mode Disabled instances."
  gem.summary       = "Memorystore for Valkey is a fully managed Valkey service for Google Cloud which supports both Cluster Mode Enabled and Cluster Mode Disabled instances."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-memorystore-v1", "~> 1.0"
end
