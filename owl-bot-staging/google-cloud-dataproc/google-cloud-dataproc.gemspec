# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/dataproc/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-dataproc"
  gem.version       = Google::Cloud::Dataproc::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Manages Hadoop-based clusters and jobs on Google Cloud Platform."
  gem.summary       = "API Client library for the Cloud Dataproc API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts", "MIGRATING.md"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-dataproc-v1", ">= 0.24", "< 2.a"
end
