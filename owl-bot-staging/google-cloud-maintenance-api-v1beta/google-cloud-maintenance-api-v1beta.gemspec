# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/maintenance/api/v1beta/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-maintenance-api-v1beta"
  gem.version       = Google::Cloud::Maintenance::Api::V1beta::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Maintenance API provides a centralized view of planned disruptive maintenance events across supported Google Cloud products. It offers users visibility into upcoming, ongoing, and completed maintenance, along with controls to manage certain maintenance activities, such as mainteance windows, rescheduling, and on-demand updates. Note that google-cloud-maintenance-api-v1beta is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-maintenance-api instead. See the readme for more details."
  gem.summary       = "The Maintenance API provides a centralized view of planned disruptive maintenance events across supported Google Cloud products. It offers users visibility into upcoming, ongoing, and completed maintenance, along with controls to manage certain maintenance activities, such as mainteance windows, rescheduling, and on-demand updates."
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
  gem.add_dependency "google-cloud-location", "~> 1.0"
end
