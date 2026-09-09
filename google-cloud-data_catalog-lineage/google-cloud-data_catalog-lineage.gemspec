# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/data_catalog/lineage/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-data_catalog-lineage"
  gem.version       = Google::Cloud::DataCatalog::Lineage::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Data lineage is a visual map that tracks the entire lifecycle of your data. It shows you where your data comes from (the origin), where it travels (the destinations), and all the changes or transformations that happen along the way."
  gem.summary       = "Data lineage is a visual map that tracks the entire lifecycle of your data. It shows you where your data comes from (the origin), where it travels (the destinations), and all the changes or transformations that happen along the way."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-data_catalog-lineage-v1", ">= 0.6", "< 2.a"
end
