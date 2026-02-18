# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/database_center/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-database_center"
  gem.version       = Google::Cloud::DatabaseCenter::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Database Center API provides access to an organization-wide, cross-product database fleet health platform. It aggregates health, security, and compliance signals from various Google Cloud databases, offering a single pane of glass to identify and manage issues."
  gem.summary       = "Database Center offers a comprehensive, organization-wide platform for monitoring database fleet health across various products. It simplifies management and reduces risk by automatically aggregating and summarizing key health signals, removing the need for custom dashboards. The platform provides a unified view through its dashboard and API, enabling teams focused on reliability, compliance, security, cost, and administration to quickly identify and address relevant issues within their database fleets."
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
