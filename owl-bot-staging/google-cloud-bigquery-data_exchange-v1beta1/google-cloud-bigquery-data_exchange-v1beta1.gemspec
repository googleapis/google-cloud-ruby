# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/bigquery/data_exchange/v1beta1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-bigquery-data_exchange-v1beta1"
  gem.version       = Google::Cloud::Bigquery::DataExchange::V1beta1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Analytics Hub is a data exchange that allows you to efficiently and securely exchange data assets across organizations to address challenges of data reliability and cost. Curate a library of internal and external assets, including unique datasets like Google Trends, backed by the power of BigQuery. Note that google-cloud-bigquery-data_exchange-v1beta1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-bigquery-data_exchange instead. See the readme for more details."
  gem.summary       = "Exchange data and analytics assets securely and efficiently."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.21.1", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
  gem.add_dependency "google-cloud-location", ">= 0.7", "< 2.a"
  gem.add_dependency "grpc-google-iam-v1", "~> 1.1"
end
