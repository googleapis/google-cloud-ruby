# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/metastore/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-metastore"
  gem.version       = Google::Cloud::Metastore::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Dataproc Metastore is a fully managed, highly available within a region, autohealing serverless Apache Hive metastore (HMS) on Google Cloud for data analytics products. It supports HMS and serves as a critical component for managing the metadata of relational entities and provides interoperability between data processing applications in the open source data ecosystem."
  gem.summary       = "API Client library for the Dataproc Metastore API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-metastore-v1", ">= 0.6", "< 2.a"
  gem.add_dependency "google-cloud-metastore-v1beta", ">= 0.6", "< 2.a"

  gem.add_development_dependency "google-style", "~> 1.26.1"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 13.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
end
