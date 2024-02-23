# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/cloud_dms/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-cloud_dms"
  gem.version       = Google::Cloud::CloudDMS::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Database Migration Service makes it easier for you to migrate your data to Google Cloud. Database Migration Service helps you lift and shift your MySQL and PostgreSQL workloads into Cloud SQL. Database Migration Service streamlines networking workflow, manages the initial snapshot and ongoing replication, and provides a status of the migration operation."
  gem.summary       = "API Client library for the Cloud Database Migration Service API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-cloud_dms-v1", ">= 0.7", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
