# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/monitoring/metrics_scope/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-monitoring-metrics_scope-v1"
  gem.version       = Google::Cloud::Monitoring::MetricsScope::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Monitoring collects metrics, events, and metadata from Google Cloud, Amazon Web Services (AWS), hosted uptime probes, and application instrumentation. The Metrics Scopes API manages the list of monitored projects and accounts. Note that google-cloud-monitoring-metrics_scope-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-monitoring instead. See the readme for more details."
  gem.summary       = "Manages your Cloud Monitoring data and configurations. Most projects must be associated with a Workspace, with a few exceptions as noted on the individual method pages. The table entries below are presented in alphabetical order, not in order of common use. For explanations of the concepts found in the table entries, read the Cloud Monitoring documentation."
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
end
