# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/vm_migration/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-vm_migration"
  gem.version       = Google::Cloud::VMMigration::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Migrate for Compute Engine enables you to migrate (Lift and Shift) your virtual machines (VMs), with minor automatic modifications, from your source environment to Google Compute Engine."
  gem.summary       = "API Client library for the Migrate for Compute Engine API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-vm_migration-v1", ">= 0.8", "< 2.a"
end
