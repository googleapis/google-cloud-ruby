# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/monitoring/metrics_scope/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-monitoring-metrics_scope"
  gem.version       = Google::Cloud::Monitoring::MetricsScope::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Cloud Monitoring collects metrics, events, and metadata from Google Cloud, Amazon Web Services (AWS), hosted uptime probes, and application instrumentation."
  gem.summary       = "API Client library for the Cloud Monitoring Metrics Scopes API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.0"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-monitoring-metrics_scope-v1", ">= 0.5", "< 2.a"
end
