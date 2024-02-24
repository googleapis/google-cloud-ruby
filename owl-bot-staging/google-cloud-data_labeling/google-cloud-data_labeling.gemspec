# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/data_labeling/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-data_labeling"
  gem.version       = Google::Cloud::DataLabeling::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "AI Platform Data Labeling Service lets you work with human labelers to generate highly accurate labels for a collection of data that you can use in machine learning models."
  gem.summary       = "API Client library for the AI Platform Data Labeling Service API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-data_labeling-v1beta1", ">= 0.7", "< 2.a"
end
