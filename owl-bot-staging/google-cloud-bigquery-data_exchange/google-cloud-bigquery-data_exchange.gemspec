# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/bigquery/data_exchange/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-bigquery-data_exchange"
  gem.version       = Google::Cloud::Bigquery::DataExchange::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Analytics Hub is a data exchange that allows you to efficiently and securely exchange data assets across organizations to address challenges of data reliability and cost. Curate a library of internal and external assets, including unique datasets like Google Trends, backed by the power of BigQuery."
  gem.summary       = "API Client library for the Analytics Hub API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-bigquery-data_exchange-v1beta1", ">= 0.6", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
