# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/asset/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-asset-v1"
  gem.version       = Google::Cloud::Asset::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "A metadata inventory service that allows you to view, monitor, and analyze all your GCP and Anthos assets across projects and services. Note that google-cloud-asset-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-asset instead. See the readme for more details."
  gem.summary       = "The Cloud Asset API manages the history and inventory of Google Cloud resources."
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
  gem.add_dependency "google-cloud-os_config-v1", "> 0.0", "< 2.a"
  gem.add_dependency "google-identity-access_context_manager-v1", "> 0.0", "< 2.a"
  gem.add_dependency "grpc-google-iam-v1", "~> 1.1"
end
