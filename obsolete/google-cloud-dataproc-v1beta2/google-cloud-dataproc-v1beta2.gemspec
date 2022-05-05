# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/dataproc/v1beta2/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-dataproc-v1beta2"
  gem.version       = Google::Cloud::Dataproc::V1beta2::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Manages Hadoop-based clusters and jobs on Google Cloud Platform. Note that google-cloud-dataproc-v1beta2 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-dataproc instead. See the readme for more details."
  gem.summary       = "API Client library for the Cloud Dataproc V1beta2 API"
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      `git ls-files -- proto_docs/*`.split("\n") +
                      ["README.md", "LICENSE.md", "AUTHENTICATION.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.5"

  gem.add_dependency "gapic-common", ">= 0.7", "< 2.a"
  gem.add_dependency "google-cloud-errors", "~> 1.0"

  gem.add_development_dependency "google-style", "~> 1.25.1"
  gem.add_development_dependency "minitest", "~> 5.14"
  gem.add_development_dependency "minitest-focus", "~> 1.1"
  gem.add_development_dependency "minitest-rg", "~> 5.2"
  gem.add_development_dependency "rake", ">= 12.0"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.18"
  gem.add_development_dependency "yard", "~> 0.9"
end
