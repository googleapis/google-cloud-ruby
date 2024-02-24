# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/workflows/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-workflows"
  gem.version       = Google::Cloud::Workflows::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Workflows link series of serverless tasks together in an order you define. Combine the power of Google Cloud's APIs, serverless products like Cloud Functions and Cloud Run, and calls to external APIs to create flexible serverless applications. Workflows requires no infrastructure management and scales seamlessly with demand, including scaling down to zero."
  gem.summary       = "API Client library for the Workflows API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-workflows-v1", ">= 0.7", "< 2.a"
  gem.add_dependency "google-cloud-workflows-v1beta", ">= 0.8", "< 2.a"
end
