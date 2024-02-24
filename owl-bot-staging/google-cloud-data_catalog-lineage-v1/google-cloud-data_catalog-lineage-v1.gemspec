# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/data_catalog/lineage/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-data_catalog-lineage-v1"
  gem.version       = Google::Cloud::DataCatalog::Lineage::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "DataCatalog is a centralized and unified data catalog service for all your Cloud resources, where users and systems can discover data, explore and curate its semantics, understand how to act on it, and help govern its usage. Lineage is used to track data flows between assets over time. You can create Lineage Events to record lineage between multiple sources and a single target, for example, when table data is based on data from multiple tables. Note that google-cloud-data_catalog-lineage-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-data_catalog-lineage instead. See the readme for more details."
  gem.summary       = "API Client library for the Data Lineage V1 API"
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
end
