# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/kms/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-kms"
  gem.version       = Google::Cloud::Kms::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Manages keys and performs cryptographic operations in a central cloud service, for direct use by other cloud resources and applications."
  gem.summary       = "API Client library for the Cloud Key Management Service (KMS) API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-kms-v1", ">= 0.24", "< 2.a"
end
