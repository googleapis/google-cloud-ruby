# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/os_config/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-os_config"
  gem.version       = Google::Cloud::OsConfig::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud OS Config provides OS management tools that can be used for patch management, patch compliance, and configuration management on VM instances."
  gem.summary       = "API Client library for the Cloud OS Config API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-os_config-v1", ">= 0.15", "< 2.a"
end
