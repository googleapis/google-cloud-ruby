# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/batch/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-batch"
  gem.version       = Google::Cloud::Batch::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "An API to manage the running of Batch resources on Google Cloud Platform."
  gem.summary       = "An API to manage the running of Batch resources on Google Cloud Platform."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-batch-v1", "~> 1.0"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
