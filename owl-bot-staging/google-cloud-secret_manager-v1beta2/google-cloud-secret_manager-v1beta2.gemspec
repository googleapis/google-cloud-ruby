# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/secret_manager/v1beta2/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-secret_manager-v1beta2"
  gem.version       = Google::Cloud::SecretManager::V1beta2::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Secret Manager Overview. Note that google-cloud-secret_manager-v1beta2 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-secret_manager instead. See the readme for more details."
  gem.summary       = "Stores sensitive data such as API keys, passwords, and certificates. Provides convenience while improving security."
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
  gem.add_dependency "google-cloud-location", ">= 0.7", "< 2.a"
  gem.add_dependency "grpc-google-iam-v1", "~> 1.1"
end
