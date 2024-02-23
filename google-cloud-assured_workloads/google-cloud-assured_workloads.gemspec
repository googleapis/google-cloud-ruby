# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/assured_workloads/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-assured_workloads"
  gem.version       = Google::Cloud::AssuredWorkloads::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Assured Workloads for Government secures government workloads and accelerates the path to running compliant workloads on Google Cloud."
  gem.summary       = "API Client library for the Assured Workloads for Government API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-assured_workloads-v1", ">= 0.9", "< 2.a"
  gem.add_dependency "google-cloud-assured_workloads-v1beta1", ">= 0.17", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
