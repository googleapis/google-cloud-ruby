# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/workflows/executions/v1beta/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-workflows-executions-v1beta"
  gem.version       = Google::Cloud::Workflows::Executions::V1beta::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Workflows link series of serverless tasks together in an order you define. Combine the power of Google Cloud's APIs, serverless products like Cloud Functions and Cloud Run, and calls to external APIs to create flexible serverless applications. Workflows requires no infrastructure management and scales seamlessly with demand, including scaling down to zero.. Note that google-cloud-workflows-executions-v1beta is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-workflows instead. See the readme for more details."
  gem.summary       = "Manages user-provided workflows."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.21.1", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
