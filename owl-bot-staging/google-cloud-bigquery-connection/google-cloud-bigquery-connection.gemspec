# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/bigquery/connection/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-bigquery-connection"
  gem.version       = Google::Cloud::Bigquery::Connection::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The BigQuery Connection API allows users to manage BigQuery connections to external data sources."
  gem.summary       = "API Client library for the BigQuery Connection API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-bigquery-connection-v1", ">= 0.17", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
