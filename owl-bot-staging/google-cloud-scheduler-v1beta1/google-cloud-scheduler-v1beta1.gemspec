# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/scheduler/v1beta1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-scheduler-v1beta1"
  gem.version       = Google::Cloud::Scheduler::V1beta1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Scheduler is a fully managed enterprise-grade cron job scheduler. It allows you to schedule virtually any job, including batch, big data jobs, cloud infrastructure operations, and more. You can automate everything, including retries in case of failure to reduce manual toil and intervention. Cloud Scheduler even acts as a single pane of glass, allowing you to manage all your automation tasks from one place. Note that google-cloud-scheduler-v1beta1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-scheduler instead. See the readme for more details."
  gem.summary       = "Creates and manages jobs run on a regular recurring schedule."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "gapic-common", ">= 0.21.1", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
  gem.add_dependency "google-cloud-location", ">= 0.7", "< 2.a"
end
