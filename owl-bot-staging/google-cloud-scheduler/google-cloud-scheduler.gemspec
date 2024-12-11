# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/scheduler/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-scheduler"
  gem.version       = Google::Cloud::Scheduler::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Scheduler is a fully managed enterprise-grade cron job scheduler. It allows you to schedule virtually any job, including batch, big data jobs, cloud infrastructure operations, and more. You can automate everything, including retries in case of failure to reduce manual toil and intervention. Cloud Scheduler even acts as a single pane of glass, allowing you to manage all your automation tasks from one place."
  gem.summary       = "API Client library for the Cloud Scheduler API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-scheduler-v1", ">= 0.10", "< 2.a"
  gem.add_dependency "google-cloud-scheduler-v1beta1", ">= 0.10", "< 2.a"
end
