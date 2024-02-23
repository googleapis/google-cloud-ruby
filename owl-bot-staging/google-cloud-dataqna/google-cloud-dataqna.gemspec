# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/dataqna/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-dataqna"
  gem.version       = Google::Cloud::DataQnA::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Data QnA is a natural language question and answer service for BigQuery data."
  gem.summary       = "API Client library for the BigQuery Data QnA API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-dataqna-v1alpha", ">= 0.6", "< 2.a"
end
