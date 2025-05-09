# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/run/v2/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-run-v2"
  gem.version       = Google::Cloud::Run::V2::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Run deploys and manages user provided container images that scale automatically based on incoming requests. Note that google-cloud-run-v2 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-run-client instead. See the readme for more details."
  gem.summary       = "Deploy and manage user provided container images that scale automatically based on incoming requests. The Cloud Run Admin API v1 follows the Knative Serving API specification, while v2 is aligned with Google Cloud AIP-based API standards, as described in https://google.aip.dev/."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.1"

  gem.add_dependency "gapic-common", "~> 1.0"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
  gem.add_dependency "google-cloud-location", "~> 1.0"
  gem.add_dependency "grpc-google-iam-v1", "~> 1.11"
end
