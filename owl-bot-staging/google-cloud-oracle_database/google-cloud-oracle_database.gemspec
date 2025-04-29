# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/oracle_database/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-oracle_database"
  gem.version       = Google::Cloud::OracleDatabase::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Oracle Database@Google Cloud API provides a set of APIs to manage Oracle database services, such as Exadata and Autonomous Databases."
  gem.summary       = "The Oracle Database@Google Cloud API provides a set of APIs to manage Oracle database services, such as Exadata and Autonomous Databases."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-oracle_database-v1", ">= 0.0", "< 2.a"
end
