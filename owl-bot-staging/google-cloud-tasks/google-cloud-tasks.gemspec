# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/tasks/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-tasks"
  gem.version       = Google::Cloud::Tasks::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Tasks is a fully managed service that allows you to manage the execution, dispatch and delivery of a large number of distributed tasks. You can asynchronously perform work outside of a user request. Your tasks can be executed on App Engine or any arbitrary HTTP endpoint."
  gem.summary       = "API Client library for the Cloud Tasks API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-tasks-v2", ">= 0.10", "< 2.a"
  gem.add_dependency "google-cloud-tasks-v2beta2", ">= 0.11", "< 2.a"
  gem.add_dependency "google-cloud-tasks-v2beta3", ">= 0.12", "< 2.a"
end
