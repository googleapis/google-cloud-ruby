# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/metastore/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-metastore"
  gem.version       = Google::Cloud::Metastore::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "The Dataproc Metastore API is used to manage the lifecycle and configuration of metastore services."
  gem.summary       = "The Dataproc Metastore API is used to manage the lifecycle and configuration of metastore services."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-metastore-v1", "~> 2.0"
end
