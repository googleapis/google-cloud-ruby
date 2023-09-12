# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/bigtable/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-bigtable"
  gem.version       = Google::Cloud::Bigtable::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "google-cloud-bigtable is the official library for Cloud Bigtable API."
  gem.summary       = "API Client library for Cloud Bigtable API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-bigtable"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["OVERVIEW.md", "AUTHENTICATION.md", "EMULATOR.md", "LOGGING.md", "CONTRIBUTING.md",
                       "TROUBLESHOOTING.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "concurrent-ruby", "~> 1.0"
  gem.add_dependency "google-cloud-bigtable-admin-v2", "~> 0.0"
  gem.add_dependency "google-cloud-bigtable-v2", "~> 0.14"
  gem.add_dependency "google-cloud-core", "~> 1.5"

  gem.add_development_dependency "google-style", "~> 1.26.1"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "yard-doctest", "~> 0.1.13"
end
