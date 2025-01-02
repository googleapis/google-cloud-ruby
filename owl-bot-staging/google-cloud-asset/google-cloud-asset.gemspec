# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/asset/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-asset"
  gem.version       = Google::Cloud::Asset::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "A metadata inventory service that allows you to view, monitor, and analyze all your GCP and Anthos assets across projects and services."
  gem.summary       = "API Client library for the Cloud Asset API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-asset-v1", ">= 0.29", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
