# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/dataform/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-dataform"
  gem.version       = Google::Cloud::Dataform::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Dataform is a service for data analysts to develop, test, version control, and schedule complex SQL workflows for data transformation in BigQuery."
  gem.summary       = "API Client library for the Dataform API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-dataform-v1beta1", ">= 0.6", "< 2.a"
end
