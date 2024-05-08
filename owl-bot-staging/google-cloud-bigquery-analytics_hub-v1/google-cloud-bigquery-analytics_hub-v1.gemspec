# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/bigquery/analytics_hub/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-bigquery-analytics_hub-v1"
  gem.version       = Google::Cloud::Bigquery::AnalyticsHub::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Analytics Hub is a data exchange platform that enables you to share data and insights at scale across organizational boundaries with a robust security and privacy framework. With Analytics Hub, you can discover and access a data library curated by various data providers. Note that google-cloud-bigquery-analytics_hub-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-bigquery-analytics_hub instead. See the readme for more details."
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
  gem.add_dependency "grpc-google-iam-v1", "~> 1.1"
end
