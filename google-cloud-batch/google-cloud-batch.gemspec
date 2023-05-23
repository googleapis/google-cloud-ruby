# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/batch/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-batch"
  gem.version       = Google::Cloud::Batch::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Google Cloud Batch is a fully managed service used by scientists, VFX artists, developers to easily and efficiently run batch workloads on Google Cloud. This service manages provisioning of resources to satisfy the requirements of the batch jobs for a variety of workloads including ML, HPC, VFX rendering, transcoding, genomics and others."
  gem.summary       = "API Client library for the Batch API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_dependency "google-cloud-batch-v1", ">= 0.7", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"

  gem.add_development_dependency "google-style", "~> 1.26.1"
  gem.add_development_dependency "minitest", "~> 5.16"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 13.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
end
