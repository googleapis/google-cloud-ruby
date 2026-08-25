# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/automl/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-automl"
  gem.version       = Google::Cloud::AutoML::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Train high-quality custom machine learning models with minimum effort and machine learning expertise."
  gem.summary       = "Train high-quality custom machine learning models with minimum effort and machine learning expertise."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-automl-v1", "~> 1.2"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
