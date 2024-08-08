# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/memcache/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-memcache"
  gem.version       = Google::Cloud::Memcache::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Google Cloud Memorystore for Memcached API is used for creating and managing Memcached instances in GCP."
  gem.summary       = "API Client library for the Google Cloud Memorystore for Memcached API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-memcache-v1", ">= 0.8", "< 2.a"
  gem.add_dependency "google-cloud-memcache-v1beta2", ">= 0.8", "< 2.a"
end
