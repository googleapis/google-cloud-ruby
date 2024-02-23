# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/analytics/admin/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-analytics-admin"
  gem.version       = Google::Analytics::Admin::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Analytics Admin API allows for programmatic access to the Google Analytics App+Web configuration data. You can use the Google Analytics Admin API to manage accounts and App+Web properties."
  gem.summary       = "API Client library for the Google Analytics Admin API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-analytics-admin-v1alpha", ">= 0.27", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
