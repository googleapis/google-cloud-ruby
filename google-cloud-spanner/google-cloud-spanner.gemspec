# -*- encoding: utf-8 -*-
require File.expand_path("../lib/google/cloud/spanner/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-spanner"
  gem.version       = Google::Cloud::Spanner::VERSION

  gem.authors       = ["Mike Moore", "Chris Smith"]
  gem.email         = ["mike@blowmage.com", "quartzmo@gmail.com"]
  gem.description   = "google-cloud-spanner is the official library for Google Cloud Spanner API."
  gem.summary       = "API Client library for Google Cloud Spanner API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-spanner"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["OVERVIEW.md", "AUTHENTICATION.md", "LOGGING.md", "CONTRIBUTING.md", "TROUBLESHOOTING.md", "CHANGELOG.md", "CODE_OF_CONDUCT.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "google-cloud-core", "~> 1.5"
  gem.add_dependency "google-cloud-spanner-admin-database-v1", "~> 0.1"
  gem.add_dependency "google-cloud-spanner-admin-instance-v1", "~> 0.1"
  gem.add_dependency "google-cloud-spanner-v1", "~> 0.2"
  gem.add_dependency "concurrent-ruby", "~> 1.0"

  gem.add_development_dependency "gapic-common", ">= 0.11.0"
  gem.add_development_dependency "google-style", "~> 1.26.1"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-autotest", "~> 1.0"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "autotest-suffix", "~> 1.1"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "yard-doctest", "~> 0.1.13"
  gem.add_development_dependency "grpc", "~> 1.36"
  gem.add_development_dependency "grpc-tools", "~> 1.36"
end
