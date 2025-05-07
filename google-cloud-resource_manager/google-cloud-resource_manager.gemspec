# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/resource_manager/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-resource_manager"
  gem.version       = Google::Cloud::ResourceManager::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Creates, reads, and updates metadata for Google Cloud Platform resource containers."
  gem.summary       = "Creates, reads, and updates metadata for Google Cloud Platform resource containers."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-resource_manager-v3", "~> 1.2"
end
