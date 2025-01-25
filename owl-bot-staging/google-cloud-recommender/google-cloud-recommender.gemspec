# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/recommender/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-recommender"
  gem.version       = Google::Cloud::Recommender::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Recommender is a service on Google Cloud that provides usage recommendations for Cloud products and services."
  gem.summary       = "API Client library for the Recommender API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-recommender-v1", ">= 0.17", "< 2.a"
end
