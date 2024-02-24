# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/storage_transfer/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-storage_transfer"
  gem.version       = Google::Cloud::StorageTransfer::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Storage Transfer Service allows you to quickly import online data into Cloud Storage. You can also set up a repeating schedule for transferring data, as well as transfer data within Cloud Storage, from one bucket to another."
  gem.summary       = "API Client library for the Storage Transfer Service API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-storage_transfer-v1", ">= 0.9", "< 2.a"
end
