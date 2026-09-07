# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/datastream/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-datastream"
  gem.version       = Google::Cloud::Datastream::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Datastream is a serverless and easy-to-use change data capture (CDC) and replication service that lets you synchronize data reliably, and with minimal latency."
  gem.summary       = "Datastream is a serverless and easy-to-use change data capture (CDC) and replication service that lets you synchronize data reliably, and with minimal latency."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 3.2"

  gem.add_dependency "google-cloud-core", "~> 1.6"
  gem.add_dependency "google-cloud-datastream-v1", "~> 1.0"
end
