# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/managed_identities/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-managed_identities"
  gem.version       = Google::Cloud::ManagedIdentities::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Managed Service for Microsoft Active Directory API is used for managing a highly available, hardened service running Microsoft Active Directory."
  gem.summary       = "API Client library for the Managed Service for Microsoft Active Directory API API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-managed_identities-v1", ">= 0.7", "< 2.a"
end
