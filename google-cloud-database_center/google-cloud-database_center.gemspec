# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/database_center/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-database_center"
  gem.version       = Google::Cloud::DatabaseCenter::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Database Center API provides access to an organization-wide, cross-product database fleet health platform. It aggregates health, security, and compliance signals from various Google Cloud databases, offering a single pane of glass to identify and manage issues."
  gem.summary       = "Database Center provides an organization-wide, cross-product fleet health platform to eliminate the overhead, complexity, and risk associated with aggregating and summarizing health signals through custom dashboards. Through Database Center’s fleet health dashboard and API, database platform teams that are responsible for reliability, compliance, security, cost, and administration of database fleets will now have a single pane of glass that pinpoints issues relevant to each team."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-database_center-v1beta", ">= 0.0", "< 2.a"
end
