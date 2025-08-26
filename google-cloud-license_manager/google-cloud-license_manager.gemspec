# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/license_manager/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-license_manager"
  gem.version       = Google::Cloud::LicenseManager::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "License Manager is a tool to manage and track third-party licenses on Google Cloud."
  gem.summary       = "License Manager is a tool to manage and track third-party licenses on Google Cloud."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-license_manager-v1", ">= 0.0", "< 2.a"
end
