# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/container_analysis/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-container_analysis-v1"
  gem.version       = Google::Cloud::ContainerAnalysis::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Container Analysis API is an implementation of Grafeas. It stores, and enables querying and retrieval of, critical metadata about all of your software artifacts. Note that google-cloud-container_analysis-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-container_analysis instead. See the readme for more details."
  gem.summary       = "An implementation of the Grafeas API, which stores, and enables querying and retrieval of critical metadata about all of your software artifacts."
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
  gem.add_dependency "grafeas-v1", ">= 0.4", "< 2.a"
  gem.add_dependency "grpc-google-iam-v1", "~> 1.1"
end
