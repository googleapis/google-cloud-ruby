# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/bigquery/reservation/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-bigquery-reservation"
  gem.version       = Google::Cloud::Bigquery::Reservation::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The BigQuery Reservation API provides the mechanisms by which enterprise users can provision and manage dedicated resources such as slots and BigQuery BI Engine memory allocations."
  gem.summary       = "API Client library for the BigQuery Reservation API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-bigquery-reservation-v1", ">= 0.11", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
