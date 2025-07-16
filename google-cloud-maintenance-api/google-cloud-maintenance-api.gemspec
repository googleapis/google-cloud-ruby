# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/maintenance/api/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-maintenance-api"
  gem.version       = Google::Cloud::Maintenance::Api::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Maintenance API provides a centralized view of planned disruptive maintenance events across supported Google Cloud products. It offers users visibility into upcoming, ongoing, and completed maintenance, along with controls to manage certain maintenance activities, such as mainteance windows, rescheduling, and on-demand updates."
  gem.summary       = "The Maintenance API provides a centralized view of planned disruptive maintenance events across supported Google Cloud products. It offers users visibility into upcoming, ongoing, and completed maintenance, along with controls to manage certain maintenance activities, such as mainteance windows, rescheduling, and on-demand updates."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-maintenance-api-v1beta", ">= 0.0", "< 2.a"
end
