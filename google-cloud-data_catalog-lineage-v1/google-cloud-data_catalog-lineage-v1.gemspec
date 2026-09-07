# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/data_catalog/lineage/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-data_catalog-lineage-v1"
  gem.version       = Google::Cloud::DataCatalog::Lineage::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Data lineage is a visual map that tracks the entire lifecycle of your data. It shows you where your data comes from (the origin), where it travels (the destinations), and all the changes or transformations that happen along the way. Note that google-cloud-data_catalog-lineage-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-data_catalog-lineage instead. See the readme for more details."
  gem.summary       = "Data lineage is a visual map that tracks the entire lifecycle of your data. It shows you where your data comes from (the origin), where it travels (the destinations), and all the changes or transformations that happen along the way."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "gapic-common", "~> 1.3"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
