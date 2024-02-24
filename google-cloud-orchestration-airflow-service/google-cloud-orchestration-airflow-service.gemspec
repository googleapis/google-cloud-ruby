# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/orchestration/airflow/service/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-orchestration-airflow-service"
  gem.version       = Google::Cloud::Orchestration::Airflow::Service::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The client library for the Cloud Composer API, built on the popular Apache Airflow open source project. Cloud Composer is a fully managed workflow orchestration service, enabling you to create, schedule, monitor, and manage workflows that span across clouds and on-premises data centers."
  gem.summary       = "API Client library for the Cloud Composer API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-orchestration-airflow-service-v1", ">= 0.9", "< 2.a"
end
