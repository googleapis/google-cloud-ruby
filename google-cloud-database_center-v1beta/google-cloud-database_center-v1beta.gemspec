# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/database_center/v1beta/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-database_center-v1beta"
  gem.version       = Google::Cloud::DatabaseCenter::V1beta::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Database Center API provides access to an organization-wide, cross-product database fleet health platform. It aggregates health, security, and compliance signals from various Google Cloud databases, offering a single pane of glass to identify and manage issues. Note that google-cloud-database_center-v1beta is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-database_center instead. See the readme for more details."
  gem.summary       = "Database Center offers a comprehensive, organization-wide platform for monitoring database fleet health across various products. It simplifies management and reduces risk by automatically aggregating and summarizing key health signals, removing the need for custom dashboards. The platform provides a unified view through its dashboard and API, enabling teams focused on reliability, compliance, security, cost, and administration to quickly identify and address relevant issues within their database fleets."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.1"

  gem.add_dependency "gapic-common", "~> 1.2"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
end
