# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/bigquery/data_transfer/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-bigquery-data_transfer"
  gem.version       = Google::Cloud::Bigquery::DataTransfer::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Schedules queries and transfers external data from SaaS applications to Google BigQuery on a regular basis."
  gem.summary       = "API Client library for the BigQuery Data Transfer Service API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-bigquery-data_transfer-v1", ">= 0.12", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
