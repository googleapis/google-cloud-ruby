# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/bigquery/storage/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-bigquery-storage"
  gem.version       = Google::Cloud::Bigquery::Storage::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The BigQuery Storage API provides fast access to BigQuery managed storage."
  gem.summary       = "API Client library for the BigQuery Storage API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-bigquery-storage-v1", ">= 0.25", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
