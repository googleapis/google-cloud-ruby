# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/api_keys/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-api_keys"
  gem.version       = Google::Cloud::ApiKeys::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "An API key is a simple encrypted string that you can use when calling Google Cloud APIs. The API Keys service manages the API keys associated with developer projects."
  gem.summary       = "API Client library for the API Keys API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-api_keys-v2", ">= 0.5", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
