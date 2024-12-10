# -*- ruby -*-
# encoding: utf-8

require File.expand_path("lib/google/cloud/connectors/version", __dir__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-connectors"
  gem.version       = Google::Cloud::Connectors::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "Enables users to create and manage connections to Google Cloud services and third-party business applications using the Connectors interface."
  gem.summary       = "Enables users to create and manage connections to Google Cloud services and third-party business applications using the Connectors interface."
  gem.homepage      = "https://github.com/googleapis/google-cloud-ruby"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE.md", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.7"

  gem.add_dependency "google-cloud-connectors-v1", ">= 0.0", "< 2.a"
  gem.add_dependency "google-cloud-core", "~> 1.6"
end
