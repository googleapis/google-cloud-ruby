# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/workload_manager/v1/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-workload_manager-v1"
  gem.version       = Google::Cloud::WorkloadManager::V1::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Workload Manager is a service that provides tooling for enterprise workloads to automate the deployment and validation of your workloads against best practices and recommendations. Note that google-cloud-workload_manager-v1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-workload_manager instead. See the readme for more details."
  gem.summary       = "Workload Manager is a service that provides tooling for enterprise workloads to automate the deployment and validation of your workloads against best practices and recommendations."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "gapic-common", "~> 1.2"
  gem.add_dependency "google-cloud-errors", "~> 1.0"
  gem.add_dependency "google-cloud-location", "~> 1.0"
end
