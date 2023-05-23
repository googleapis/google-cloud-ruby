# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/asset/v1beta1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-asset-v1beta1"
  gem.version       = Google::Cloud::Asset::V1beta1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "A metadata inventory service that allows you to view, monitor, and analyze all your GCP and Anthos assets across projects and services."
  gem.summary       = "API Client library for the Cloud Asset V1beta1 API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.4"

  gem.add_dependency "gapic-common", "~> 0.3"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
  gem.add_dependency "grpc-google-iam-v1", "~> 1.1"

  gem.add_development_dependency "google-style", "~> 1.24.0"
  gem.add_development_dependency "minitest", "~> 5.14"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 12.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.18"
  gem.add_development_dependency "yard", "~> 0.9"
end
