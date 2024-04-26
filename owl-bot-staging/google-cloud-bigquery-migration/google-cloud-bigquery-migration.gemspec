# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/bigquery/migration/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-bigquery-migration"
  gem.version       = Google::Cloud::Bigquery::Migration::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The BigQuery Migration Service is a comprehensive solution for migrating your data warehouse to BigQuery."
  gem.summary       = "API Client library for the BigQuery Migration API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-bigquery-migration-v2", ">= 0.9", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
