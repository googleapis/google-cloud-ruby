# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/kms/inventory/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-kms-inventory"
  gem.version       = Google::Cloud::Kms::Inventory::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "google-cloud-kms-inventory is the official client library for the KMS Inventory API."
  gem.summary       = "API Client library for the KMS Inventory API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-kms-inventory-v1", ">= 0.8", "< 2.a"
end
