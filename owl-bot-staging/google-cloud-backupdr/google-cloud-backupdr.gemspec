# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/backupdr/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-backupdr"
  gem.version       = Google::Cloud::BackupDR::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "google-cloud-backupdr is the official client library for the Backup and DR Service API."
  gem.summary       = "API Client library for the Backup and DR Service API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-backupdr-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
