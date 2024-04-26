# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/bigquery/data_policies/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-bigquery-data_policies"
  gem.version       = Google::Cloud::Bigquery::DataPolicies::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Data Policy Service provides APIs for managing the BigQuery label-policy bindings."
  gem.summary       = "API Client library for the BigQuery Data Policy Service V1beta1 API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-bigquery-data_policies-v1", ">= 0.7", "< 2.a"
  gem.add_dependency "google-cloud-bigquery-data_policies-v1beta1", ">= 0.4", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
