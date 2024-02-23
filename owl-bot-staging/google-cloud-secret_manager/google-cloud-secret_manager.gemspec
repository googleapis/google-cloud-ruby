# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/secret_manager/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-secret_manager"
  gem.version       = Google::Cloud::SecretManager::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Secret Manager is a secure and convenient storage system for API keys, passwords, certificates, and other sensitive data. Secret Manager provides a central place and single source of truth to manage, access, and audit secrets across Google Cloud."
  gem.summary       = "API Client library for the Secret Manager API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-secret_manager-v1", ">= 0.19", "< 2.a"
  gem.add_dependency "google-cloud-secret_manager-v1beta1", ">= 0.3", "< 2.a"
end
